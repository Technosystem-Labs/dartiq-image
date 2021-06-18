
# Dockerized ARTIQ Image Repository

This repository provides Docker image with ARTIQ. It uses Nix package manager
and `dockerTools.buildImage` to build image with all dependencies from scratch. 
Scripts that define ARTIQ environment are provided by M-Labs in 
[nix-scripts](https://git.m-labs.hk/M-Labs/nix-scripts) repository.

This image is designed to be used with 
[DARTIQ script](https://github.com/Technosystem-Labs/dartiq).

## Prebuilt image

Prebuilt image can be pulled from Docker Hub:

```bash
docker pull technosystem/dartiq:latest
```

## Building image

You can also build an image on your own using `build_script`. This will use
`nixos/nix` image to build your Dockerized ARTIQ environment. Please note 
that the script runs container with your host system Docker daemon socket 
mounted and will copy outcome image directly to your local Docker image store.

Build process is configured with the following environment variables:
* `ARTIQ_REV`: revision of ARTIQ repository URL, currently defaults to `6.0`.
* `ARTIQ_REPO`: ARTIQ repository, defaults to official ARTIQ repository: 
  `https://github.com/m-labs/artiq`.
* `NIX_SCRIPTS_REV`: revision of Nix Scripts repository, currently defaults to
  `a1d134ad`.
* `NIX_SCRIPTS_REPO`: Nix Scripts repository URL, dafults to M-Labs Nix Scripts.
  repo: `https://git.m-labs.hk/m-labs/nix-scripts.git`
* `EXTRA_BINARY_CACHE`: URLs for extra binary caches, when not set
  `https://cache.nixos.org` and `https://nixbld.m-labs.hk` are used.
* `EXTRA_CACHE_SIGNATURES`: signatures for extra binary caches.
* `NIX_PACKAGES`: URL for `nixpkgs` to be used, currently defaults to 
  `https://nixos.org/channels/nixpkgs-20.03-darwin`.
* `IMAGE_TAG`: tag for the output image.
* `TARGET`: variant to build, either `dartiq` (~5.3GB) or `dartiq_mini` 
  (~2.2GB), defaults to `dartiq`.

Beware that you can't choose `NIX_PACKAGES` and Nix Script revision arbitrarly,
so until you know what you're doing, it's better to refer to the example
configurations:
* `artiq6.env`: for stable ARTIQ 6.0 (full-featured)
* `artiq6_mini.env`: for stable ARTIQ 6.0 (minimal image)
* `artiq_dev.env`: for latest version from repository (full-featured)
* `artiq_dev_mini.env`: for latest version from repository (minimal image)
