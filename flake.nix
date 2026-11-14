{
  description = "kmod as a single self-contained binary";

  nixConfig = {
    extra-substituters = [ "https://unpins.cachix.org" ];
    extra-trusted-public-keys = [ "unpins.cachix.org-1:DDaShjbZ8VvcqxeTcAU3kV9vxZQBlyb7V/uLBHfTynI=" ];
  };

  inputs.unpins-lib.url = "github:unpins/nix-lib";

  # Upstream kmod already dispatches on the program name (`tools/kmod.c`).
  # The names in `multicall.programs[].aliases` are the commands
  # `unpin install` creates.
  #
  # nixpkgs `meta.platforms` for kmod is *-linux only; the tool reads
  # /sys/module, /proc/modules and uses init_module/finit_module/
  # delete_module syscalls — no Darwin equivalent.
  outputs = { self, unpins-lib }:
    unpins-lib.lib.mkStandaloneFlake {
      inherit self;
      name = "kmod";
      smoke = [ "--version" ];
      smokePattern = "^kmod version [0-9]+";

      # Build via the unpin-llvm engine + emit a bitcode multicall module.
      engine = "unpin-llvm";
      multicall = {
        programs = [{ name = "kmod"; aliases = [ "insmod" "rmmod" "lsmod" "modprobe" "modinfo" "depmod" ]; }];
      };
      # nixpkgs lists every component (LGPL libkmod, …); the shipped tools
      # (modprobe/depmod/…) are GPL-2.0-or-later — pin that as the effective license.
      license = "GPL-2.0-or-later";
      linuxOnly = true;
      # nixpkgs' kmod only wires xz+zstd; upstream also supports zlib
      # (load gzip-compressed `.ko.gz` modules — CONFIG_MODULE_COMPRESS_GZIP)
      # and openssl/libcrypto (PKCS#7 module-signature parsing in
      # libkmod-signature / `modinfo --signature`). Add both (the
      # experimental tools stay off, as upstream and nixpkgs ship them).
      # `pkgs.pkgsStatic.openssl` is already the
      # retargeted/static-fixed one the engine auto-wires (autoWiredFixes) —
      # incl. the arm32 `-latomic` strip from its .pc — so kmod's
      # `pkg-config --static libcrypto` links clean on armv7l with no
      # per-consumer stub. openssl (not the project's default mbedtls)
      # because kmod's signature code is openssl-API-specific.
      build = pkgs:
        pkgs.pkgsStatic.kmod.overrideAttrs (old: {
          buildInputs = (old.buildInputs or [ ]) ++ [ pkgs.pkgsStatic.zlib pkgs.pkgsStatic.openssl ];
          configureFlags = (old.configureFlags or [ ]) ++ [ "--with-zlib" "--with-openssl" ];
          # Off, and measured rather than inherited. Four walls, in the order
          # they appear: `make check` first builds test kernel modules against
          # /lib/modules/`uname -r`/build, which the sandbox does not have and
          # which would tie the result to this host's kernel;
          # `--disable-test-modules` gets past that (cached .ko) and lands on
          # setup-rootfs.sh, fixable with patchShebangs plus zstd/xz at check
          # time; past THAT the harness does not compile against musl —
          # testsuite.c calls `basename()` with no <libgen.h>, which only
          # glibc's <string.h> declares. And the wall behind all of them is the
          # design: the suite works by LD_PRELOADing path.so/uname.so into the
          # tools under test, and a static binary has no dynamic loader to
          # honour it. Every step above was run; the last one is what the
          # harness is.
          doCheck = false;
        });
    };
}
