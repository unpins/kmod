{
  description = "Standalone build of kmod";

  nixConfig = {
    extra-substituters = [ "https://unpins.cachix.org" ];
    extra-trusted-public-keys = [ "unpins.cachix.org-1:DDaShjbZ8VvcqxeTcAU3kV9vxZQBlyb7V/uLBHfTynI=" ];
  };

  inputs.unpins-lib.url = "github:unpins/nix-lib";

  outputs = { self, unpins-lib }:
    unpins-lib.lib.mkStandaloneFlake {
      inherit self;
      name = "kmod";
      # nixpkgs `meta.platforms` for kmod is *-linux only; the tool reads
      # /sys/module, /proc/modules and uses init_module/finit_module/
      # delete_module syscalls — no Darwin equivalent.
      linuxOnly = true;
    };
}
