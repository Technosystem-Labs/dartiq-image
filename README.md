
# Dockerized ARTIQ Image Repository

This repository provides Docker image with ARTIQ. It uses Nix package manager
to build image with all dependencies from scratch. Scripts that define ARTIQ
environment are provided by M-Labs in 
[nix-scripts](https://git.m-labs.hk/M-Labs/nix-scripts) repository.





This repository contains files necessary to build Docker image for DARTIQ script.

Images are built for mirrored ARTIQ and nix-scripts repositories and pushed to local GitLab Docker registry.

CI pipelines can be triggered by:

* API trigger - this option is forseen for `repo-mirror-service` that will trigger DARTIQ image rebuild every time an update to ARTIQ or nix-scripts appears on original repositories. Frequency of the pipeline execution will be dictated by `repo-mirror-service` execution cycle.

* Web trigger - for manually rebuilding DARTIQ image.


