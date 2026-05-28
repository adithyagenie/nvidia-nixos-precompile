{
  description = "Pre-compiled Nvidia Driver";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    flake-parts.url = "github:hercules-ci/flake-parts";
    systems = {
      url = "github:nix-systems/default";
      flake = false;
    };
  };

  outputs = inputs @ { self, nixpkgs, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [];

      systems = [ "x86_64-linux" ];

      perSystem = { system, pkgs, ... }:
      let
        kernelPackages = pkgs.linuxPackages_6_18;

        nvidia-driver = kernelPackages.nvidiaPackages.mkDriver {
          version = "610.43.02";
          sha256_64bit = "sha256-MDSgVLtM33dS/43CclZMsQVROAS/9TU4lFkBsWyndGM=";
          sha256_aarch64 = "sha256-isWTnokUA/dzWocFBLalnk4+O5gSExVjs3dVpdYTU88=";
          openSha256 = "sha256-hP5NVZZ4vGsACHLmUDKq4uckpd/kn1GxCSYnnJfAuBs=";
          settingsSha256 = "sha256-0YAhufRgjDW+uR+kjaTb154fibpcDw8QowfrucoZsKE=";
          persistencedSha256 = "sha256-Whgv9X+v2fRhzliOl2LzltY9v1SxDafFfv3IUPqj/hk=";
          usePersistenced = true;
        };
      in {
        _module.args.pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
          config.cudaSupport = true;
        };
        packages = {
          inherit nvidia-driver;
          default = nvidia-driver;
          nvidia-driver-base = nvidia-driver;
          nvidia-driver-open = nvidia-driver.open;
          nvidia-settings = nvidia-driver.settings;

          # dont parallelize builds - we build in sync.
          garnix-ci = pkgs.linkFarm "garnix-ci" [
            { name = "base"; path = nvidia-driver; }
            { name = "open"; path = nvidia-driver.open; }
            { name = "settings"; path = nvidia-driver.settings; }
          ];
        };
      };
    };
}
