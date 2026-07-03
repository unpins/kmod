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
        unpins-lib.lib.withAliases pkgs
          {
            primary = "kmod";
            aliasesFromSymlinksIn = "bin";
          }
          pkgs.pkgsStatic.kmod;
    };
}
