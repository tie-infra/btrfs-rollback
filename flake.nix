{
  description = "A program to rollback btrfs subvolume to a snapshot";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    systems.url = "systems";
    flake-parts.url = "flake-parts";
    minimal-shell.url = "github:tie-infra/minimal-shell";
  };

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } {
    systems = import inputs.systems;

    flake.overlays.default = import ./overlay.nix;

    perSystem = { lib, pkgs, ... }: {
      apps = lib.mkIf (pkgs.stdenv.isLinux) {
        default.program =
          (pkgs.extend inputs.self.overlays.default).btrfs-rollback;
      };
      checks = lib.mkIf (pkgs.stdenv.isLinux) {
        default = inputs.nixpkgs.lib.nixos.runTest {
          imports = [ ./test.nix ];
          hostPkgs = pkgs;
          defaults.nixpkgs.overlays = [ inputs.self.overlays.default ];
        };
      };
    };
  };
}
