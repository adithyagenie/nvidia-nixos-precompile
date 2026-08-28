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
          version = "610.57.04";
          sha256_64bit = "sha256-suk1xmuDuwDAyFe8jg7g/VLekoa0DJzB7sKafOfrEW0=";
          sha256_aarch64 = "sha256-QCefrMBCmpOwuOyXv1k5Gj0iB2CYlPgnG3JToUw/j54=";
          openSha256 = "sha256-rQHOOOY4KL92Ww3KDwh+j4eGU7oNAH8LutZC5wmFnPo=";
          settingsSha256 = "sha256-ZEMo8I8Zc2Tq6RVDNYpAH+f094dUaZiBqO+5f6lIjRI=";
          persistencedSha256 = "sha256-aXmD2VY1RLlgAnlHhOUMWzvMyhI6JTClcFLm4imF/mA=";
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
