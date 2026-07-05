{
  description = "kmod as a single self-contained binary";

  nixConfig = {
    extra-substituters = [ "https://unpins.cachix.org" ];
    extra-trusted-public-keys = [ "unpins.cachix.org-1:DDaShjbZ8VvcqxeTcAU3kV9vxZQBlyb7V/uLBHfTynI=" ];
  };

  inputs.unpins-lib.url = "github:unpins/nix-lib";

  # Upstream kmod ships a single multicall binary (`tools/kmod.c` does
  # argv[0] dispatch) plus a symlink per tool (depmod, insmod, lsmod,
  # modinfo, modprobe, rmmod). Mirrors the coreutils pattern: ship only
  # the multicall, embed the applet names as an UNPIN_META block so
  # unpin's installer can recreate the argv[0]-dispatch shims at install
  # time.
  #
  # nixpkgs `meta.platforms` for kmod is *-linux only; the tool reads
  # /sys/module, /proc/modules and uses init_module/finit_module/
  # delete_module syscalls — no Darwin equivalent.
  outputs = { self, unpins-lib }:
    unpins-lib.lib.mkStandaloneFlake {
      inherit self;
      name = "kmod";

      # Build via the unpin-llvm engine + emit a bitcode multicall module.
      engine = "unpin-llvm";
      multicall = {
        programs = [{ name = "kmod"; aliases = [ "insmod" "rmmod" "lsmod" "modprobe" "modinfo" "depmod" ]; }];
      };
      # nixpkgs lists every component (LGPL libkmod, …); the shipped tools
      # (modprobe/depmod/…) are GPL-2.0-or-later — pin that as the effective license.
      license = "GPL-2.0-or-later";
      linuxOnly = true;
      build = pkgs:
        let
          # 32-bit ARM (armv7l/armv6): static `libcrypto.pc` lists `-latomic` in
          # Libs.private, so kmod's own link inherits it via pkg-config — but a
          # static-musl + compiler-rt toolchain ships no `libatomic.a` (the
          # `__atomic_*` libcalls live in compiler-rt builtins). nix-lib's
          # native-overlay/openssl.nix stubs this for openssl's *own* app links,
          # but that stub is scoped to the openssl derivation and doesn't reach
          # kmod. Provide an empty `libatomic.a` here (as a buildInput so the
          # cc-wrapper adds its `-L`); `-latomic` then resolves to the empty
          # archive while the real symbols come from builtins. Empty ar = the
          # arch-independent 8-byte `!<arch>\n`. 64-bit targets never emit
          # `-latomic`, hence the isAarch32 gate.
          libatomicStub = pkgs.runCommand "libatomic-stub" { } ''
            mkdir -p "$out/lib"
            printf '!<arch>\n' > "$out/lib/libatomic.a"
          '';
        in
        unpins-lib.lib.withAliases pkgs
          {
            primary = "kmod";
            aliasesFromSymlinksIn = "bin";
          }
          # nixpkgs' kmod only wires xz+zstd; upstream also supports zlib
          # (load gzip-compressed `.ko.gz` modules — CONFIG_MODULE_COMPRESS_GZIP)
          # and openssl/libcrypto (PKCS#7 module-signature parsing in
          # libkmod-signature / `modinfo --signature`). Ship every upstream
          # feature: add both. `pkgs.pkgsStatic.openssl` is already the
          # retargeted/static-fixed one the engine auto-wires (autoWiredFixes),
          # so no by-hand roll. openssl (not the project's default mbedtls)
          # because kmod's signature code is openssl-API-specific.
          (pkgs.pkgsStatic.kmod.overrideAttrs (old: {
            buildInputs = (old.buildInputs or [ ]) ++ [ pkgs.pkgsStatic.zlib pkgs.pkgsStatic.openssl ]
              ++ pkgs.lib.optional pkgs.stdenv.hostPlatform.isAarch32 libatomicStub;
            configureFlags = (old.configureFlags or [ ]) ++ [ "--with-zlib" "--with-openssl" ];
          }));
    };
}
