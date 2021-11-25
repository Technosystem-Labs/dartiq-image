{ imageTag, pkgs ? import <nixpkgs> {} }:
with pkgs;
let
    artiqShell = import /tmp/nix-scripts/artiq-fast/shell.nix { inherit pkgs; };
    artiq6 = pkgs.lib.strings.versionAtLeast mainPackages.artiq.version "6.0";
    pythonDeps = import /tmp/nix-scripts/artiq-fast/pkgs/python-deps.nix { inherit (pkgs) lib fetchgit fetchFromGitHub python3Packages; misoc-new = artiq6; };
    artiqVersion = import /tmp/nix-scripts/artiq-fast/pkgs/artiq-version.nix { inherit stdenv fetchgit git; };
    versionInfo = import ./version-info.nix { inherit stdenv fetchgit git artiqVersion; };
in
    pkgs.dockerTools.buildImage {
        name = "dartiq_mini";
        contents = [
            versionInfo
            pkgs.bashInteractive
            pkgs.coreutils
            pkgs.git
            pythonDeps.artiq-netboot
        ] ++ artiqShell.buildInputs;
        tag = imageTag;
        created = "now";
        config = {
            Env = [
                "TARGET_AR=or1k-linux-ar"
                "PS1=\\e[32;4m[DARTIQ]\\e[0m \\e[34m\\w\\e[0m \$ "
                "HOME=/home"
            ];
            Entrypoint = [
                "${pkgs.bashInteractive}/bin/bash"
            ];
            WorkingDir = "/workspace";
        };
    }
