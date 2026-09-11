# Pre-compiled Nvidia Driver for NixOS

Pre-compiled Nvidia drivers for NixOS with Linux 6.18.x, built with GitHub Actions and distributed via Cachix.

[![Build](https://github.com/adithyagenie/nvidia-nixos-precompile/actions/workflows/ci.yml/badge.svg)](https://github.com/adithyagenie/nvidia-nixos-precompile/actions/workflows/ci.yml)

> [!NOTE]
> The kernel module only loads against the kernel it was built for (`linuxPackages_6_18` from `nixos-26.05`), and only `x86_64-linux` is pre-built. Other kernels (`linuxPackages_latest`, `-zen`, `kernelPatches`, …) miss the cache and build locally.

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

Flake `nixConfig` only applies if the flake is trusted (interactive prompt or `--accept-flake-config`). Otherwise add the substituter system-wide via `nix.settings`.

### 2. Add Flake Input
Add this repository to your `flake.nix` inputs:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05"; # keep on this branch; see note above
    nvidia-driver.url = "github:adithyagenie/nvidia-nixos-precompile";
  };
}
```

### 3. Configure Hardware

Refer to [the NixOS wiki](https://nixos.wiki/wiki/Nvidia) for the various options available.
Set `hardware.nvidia.package` to use the pre-compiled driver in your configuration:


#### For proprietary drivers:
```nix
{ pkgs, inputs, config, ... }:

let
  nvidiaPkgs = inputs.nvidia-driver.packages.${pkgs.stdenv.hostPlatform.system};
in
{
  config = {
    boot.kernelPackages = pkgs.linuxPackages_6_18; # must match the kernel this flake was built against

    services.xserver.videoDrivers = [ "nvidia" ];

    hardware.nvidia = {
      package = nvidiaPkgs.default; # proprietary modules
      open = false;

      nvidiaSettings = true; # Optional, provides GUI settings app
      nvidiaPersistenced = true; # The flake compiles with persistenced support enabled
    };
  };
}
```

#### For [nvidia open drivers](https://github.com/NVIDIA/open-gpu-kernel-modules):

```nix
{ pkgs, inputs, config, ... }:

let
  nvidiaPkgs = inputs.nvidia-driver.packages.${pkgs.stdenv.hostPlatform.system};
in
{
  config = {
    boot.kernelPackages = pkgs.linuxPackages_6_18; # must match the kernel this flake was built against

    services.xserver.videoDrivers = [ "nvidia" ];

    hardware.nvidia = {
      # For open modules (Turing and newer)
      package = nvidiaPkgs.nvidia-driver-open;
      open = true;

      nvidiaSettings = true; # Optional, provides GUI settings app
      nvidiaPersistenced = true; # The flake compiles with persistenced support enabled
    };
  };
}
```
