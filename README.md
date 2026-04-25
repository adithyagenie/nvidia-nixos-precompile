# Caching NVIDIA Driver builds

This repository provides a Nix flake to build NVIDIA Drivers for Linux 6.18.24 using NixOS 25.11 packages.
I just use GHA to build the package and upload it to Cachix, since compiling locally is tasking.

## Usage

Fork and set your `CACHIX_AUTH_TOKEN` in Github Secrets!
