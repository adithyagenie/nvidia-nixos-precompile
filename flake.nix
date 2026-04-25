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
          version = "595.58.03";
          sha256_64bit = "sha256-jA1Plnt5MsSrVxQnKu6BAzkrCnAskq+lVRdtNiBYKfk=";
          sha256_aarch64 = "sha256-hzzIKY1Te8QkCBWR+H5k1FB/HK1UgGhai6cl3wEaPT8=";
          openSha256  = "sha256-6LvJyT0cMXGS290Dh8hd9rc+nYZqBzDIlItOFk8S4n8=";
          settingsSha256 = "sha256-2vLF5Evl2D6tRQJo0uUyY3tpWqjvJQ0/Rpxan3NOD3c=";
          persistencedSha256 = "sha256-AtjM/ml/ngZil8DMYNH+P111ohuk9mWw5t4z7CHjPWw=";
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
