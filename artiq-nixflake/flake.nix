{
  description = "Dockerized ARTIQ";

  inputs = {
    artiq.url = "github:m-labs/artiq?ref=release-7"; 
    mozilla-overlay = { url = github:mozilla/nixpkgs-mozilla; flake = false; };
    src-artiq-netboot = { type = "git"; url = "https://git.m-labs.hk/m-labs/artiq-netboot.git"; flake = false; };
  };

  outputs = { self, mozilla-overlay, artiq, src-artiq-netboot }:
    let
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
      inherit artiqShellbuildInputs  artiqVivado artiqContents;
      dockerLatest = pkgs.dockerTools.buildImage {
        name = "technosystem/dartiq";
        contents = artiqContents ++ [
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
        ];
        tag = "${artiqVersionId}";
        created = "now";
        config = {
            Env = [
                "TARGET_AR=llvm-ar"
                "PS1=\\e[32;4m[DARTIQ]\\e[0m \\e[34m\\w\\e[0m \$ "
                "HOME=/home"
            ];
            Entrypoint = [
                "${pkgs.bashInteractive}/bin/bash"
            ];
            WorkingDir = "/workspace";
        };
      };
    };
}
