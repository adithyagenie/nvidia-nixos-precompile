{
  description = "Pre-compiled Nvidia Driver";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
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
          version = "595.45.04";
          sha256_64bit = "sha256-zUllSSRsuio7dSkcbBTuxF+dN12d6jEPE0WgGvVOj14=";
          sha256_aarch64 = "sha256-jl6lQWsgF6ya22sAhYPpERJ9r+wjnWzbGnINDpUMzsk=";
          openSha256 = "sha256-uqNfImwTKhK8gncUdP1TPp0D6Gog4MSeIJMZQiJWDoE=";
          settingsSha256 = "sha256-Y45pryyM+6ZTJyRaRF3LMKaiIWxB5gF5gGEEcQVr9nA=";
          persistencedSha256 = "sha256-5FoeUaRRMBIPEWGy4Uo0Aho39KXmjzQsuAD9m/XkNpA=";
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
          obs-studio-cuda = pkgs.obs-studio.override { cudaSupport = true; };
        };
      };
    };
}
