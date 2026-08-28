# Pre-compiled Nvidia Driver

Pre-compiled Nvidia drivers for NixOS, built with GitHub Actions and distributed via Cachix.

## Usage

### 1. Add Cachix Cache
Add the Cachix binary cache to your `flake.nix` so Nix downloads the binaries instead of building them:

```nix
{
  nixConfig = {
    extra-substituters = [ "https://nvidia-nixos-precompile.cachix.org" ];
    extra-trusted-public-keys = [ "nvidia-nixos-precompile.cachix.org-1:ccc05gMjXr5QcbNVbBxHUD1utFDoYZm219vmW6yjRc8=" ];
  };
}
```

### 2. Add Flake Input
Add this repository to your `flake.nix` inputs:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nvidia-driver.url = "github:adithyagenie/nvidia";
  };
}
```

### 3. Configure Hardware

Refer [here](https://nixos.wiki/wiki/Nvidia) for the various options available.
Set `hardware.nvidia.package` to use the pre-compiled driver in your configuration:

```nix
{ pkgs, inputs, config, ... }:

let
  nvidiaPkgs = inputs.nvidia-driver.packages.${pkgs.stdenv.hostPlatform.system};
in
{
  config = {
    services.xserver.videoDrivers = [ "nvidia" ];

    hardware.nvidia = {
      # Use the pre-compiled package
      package = nvidiaPkgs.default; # or nvidiaPkgs.nvidia-driver-open for open-source modules
      
      open = true; # Set to false if using the proprietary package
      nvidiaSettings = true; # Optional, provides GUI settings app
      nvidiaPersistenced = true; # The flake compiles with persistenced support enabled
    };
  };
}
```
