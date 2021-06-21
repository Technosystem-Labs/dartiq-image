
# Dockerized ARTIQ Image Repository

This repository provides Docker image with ARTIQ. It uses Nix package manager
and its `dockerTools.buildImage` package to build the image with all dependencies from scratch.
Scripts that define ARTIQ environment are provided by M-Labs in 
[nix-scripts](https://git.m-labs.hk/M-Labs/nix-scripts) repository.

This image is designed to be used with 
[DARTIQ script](https://github.com/Technosystem-Labs/dartiq).

## Prebuilt image

Prebuilt image can be pulled from Docker Hub:

```bash
# Full-featured ~5GB, based on repo head
docker pull technosystem/dartiq:latest       
# Full-featured ~5GB, stable 6.0
docker pull technosystem/dartiq:6.0
# Minimal version ~2.5GB, based on repo head
docker pull technosystem/dartiq:latest_mini
# Minimal version ~2.5GB, stable 6.0
docker pull technosystem/dartiq:6.0_mini 
```

Alternatively you can build your own image locally. The process is described in the following section.

## Building image

You can also build an image on your own using `build_script`. This will use
`nixos/nix` Docker image to build your Dockerized ARTIQ environment. Please note
that the script runs container with your host system Docker daemon socket 
mounted, thus it will copy the outcome image directly into your local Docker image store.

### Essential configuration
Build process is configured with the following environment variables:
* `ARTIQ_REV`: revision of ARTIQ repository (ex. `6.0`);
* `ARTIQ_REPO`: ARTIQ repository URL (ex. `https://github.com/m-labs/artiq`);
* `NIX_SCRIPTS_REV`: revision of the Nix Scripts repository (ex. `a1d134ad`);
* `NIX_SCRIPTS_REPO`: Nix Scripts repository URL (ex. `https://git.m-labs.hk/m-labs/nix-scripts.git`);
* `NIX_PACKAGES`: URL for `nixpkgs` to be used (ex. `https://nixos.org/channels/nixpkgs-20.03-darwin`);
* `IMAGE_TAG`: tag for the output image.
* `TARGET`: variant to build, either `dartiq` (~5.3GB) or `dartiq_mini` (~2.2GB).

You don't need to set the configuration variables by hand.
Repository contains example configurations that you can source:

* `artiq6.env`: for stable ARTIQ 6.0 (full-featured)
* `artiq6_mini.env`: for stable ARTIQ 6.0 (minimal image)
* `artiq_dev.env`: for latest version from repository (full-featured)
* `artiq_dev_mini.env`: for latest version from repository (minimal image)

Beware that you can't choose `NIX_PACKAGES` and Nix Script revision arbitrarily,
so until you know what you're doing, it's better to refer to the example
configurations.
### Extra variables
Additionally, you can set the following variables:
* `EXTRA_BINARY_CACHE`: URLs for extra binary caches, when not set
  `https://cache.nixos.org` and `https://nixbld.m-labs.hk` are used;
* `EXTRA_CACHE_SIGNATURES`: signatures for extra binary caches.

### Example usage
For example, if you want to build `dartiq:6.0` stable image, run:

```bash
source artiq6.env
./build_script
```

The process is pretty time-consuming, it can take over half an hour.

To check DARTIQ images available on your machine, you can type:
```bash
docker images | grep dartiq
```
The result should look similar to the following:
```
technosystem/dartiq     6.0   96d465208b80   31 minutes ago   5.34GB
```
