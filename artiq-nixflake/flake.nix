{
  description = "Dockerized ARTIQ";

  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-22.11;
    artiq.url = "github:m-labs/artiq?ref=release-7";
    mozilla-overlay = { url = github:mozilla/nixpkgs-mozilla; flake = false; };
    src-artiq-netboot = { type = "git"; url = "https://git.m-labs.hk/m-labs/artiq-netboot.git"; flake = false; };
  };

  outputs = { self, mozilla-overlay, artiq, src-artiq-netboot, nixpkgs }:
    let
      pkgs_clean = import nixpkgs { system = "x86_64-linux"; };
      pkgs = import artiq.inputs.nixpkgs { system = "x86_64-linux"; overlays = [ (import mozilla-overlay) ]; };

      artiq-netboot = pkgs.python3Packages.buildPythonPackage {
        name = "artiq-netboot";
        src = src-artiq-netboot;
      };

      artiqVersionMajor = 7;
      artiqVersionMinor = artiq.sourceInfo.revCount or 0;
      artiqVersionId = artiq.sourceInfo.shortRev or "unknown";
      artiqVersion = (builtins.toString artiqVersionMajor) + "." + (builtins.toString artiqVersionMinor) + "." + artiqVersionId + ".beta";
      artiqRev = artiq.sourceInfo.rev or "unknown";

      artiq-version = pkgs.stdenv.mkDerivation {
        name = "artiq-version";
        src = self;
        installPhase = ''
          mkdir -p $out/bin;
          echo "#!/bin/bash" >> $out/bin/version-info
          echo 'echo "ARTIQ version: ${artiqVersion} rev: ${artiqRev}"' >> $out/bin/version-info
          chmod +x $out/bin/version-info
          '';
      };

      vivadoDeps = pkgs: with pkgs; [
        ncurses5
        zlib
        libuuid
        xorg.libSM
        xorg.libICE
        xorg.libXrender
        xorg.libX11
        xorg.libXext
        xorg.libXtst
        xorg.libXi
        freetype
        fontconfig
      ];

      vivado = pkgs.buildFHSUserEnv {
        name = "vivado";
        targetPkgs = vivadoDeps;
        profile = "set -e; source /opt/Xilinx/Vivado/settings64.sh";
        runScript = "vivado";
      };

      artiqShellbuildInputs = artiq.devShell.x86_64-linux.buildInputs;
      artiqVivado = artiq.packages.x86_64-linux.vivado;
      artiqContents = builtins.filter (x: x != artiqVivado) artiqShellbuildInputs;      
    in rec {    
      inherit artiqShellbuildInputs  artiqVivado artiqContents pkgs;
      dockerLatest = pkgs_clean.dockerTools.buildImage {
        name = "technosystem/dartiq";
        contents = pkgs.buildEnv {
            name = "image-root";
            paths = artiqContents ++ [
                pkgs.llvmPackages_11.clang-unwrapped
                pkgs.bashInteractive
                pkgs.coreutils
                pkgs.git
                pkgs.cacert
                pkgs.gnumake
                pkgs.stdenv.cc
                # Urukul programming support
                pkgs.xc3sprog
                pkgs.fxload
                pkgs.yosys
                pkgs.nextpnr
                pkgs.icestorm
                # Additional tools
                artiq-netboot
                artiq-version
                vivado
                pkgs.findutils
            ];
        };
        tag = "${artiqVersionId}";
        created = "now";
        config = {
            Env = [
                "PS1=\\[\\e[32m\\][\\[\\e[m\\]\\[\\e[32m\\]DARTIQ\\[\\e[m\\]\\[\\e[32m\\]]\\[\\e[m\\] \\[\\e[34m\\]\\W\\[\\e[m\\] \\\\$  "
                "HOME=/home"
            ];
            Entrypoint = [
                "${pkgs.bashInteractive}/bin/bash"
            ];
            WorkingDir = "/workspace";
        };
        runAsRoot = ''
          #!{pkgs.stdenv.shell}
          set -euo pipefail
          for file in $(find /nix/store -maxdepth 3 -type f -executable -regex '.*bin/.*'); do
            ln -s --force "$file" "/bin/$(basename "$file")"
          done
          ln -s /bin/lld /bin/ld.lld
        '';

        diskSize = 10240;
        buildVMMemorySize = 4096;
      };
    };
}
