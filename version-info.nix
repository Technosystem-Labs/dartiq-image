{ stdenv, git, fetchgit, artiqVersion }:

stdenv.mkDerivation {
    name = "dartiq-version";
    src = builtins.path { path = ./.; name = "dartiq-version"; };
    buildPhase = ''
      DARTIQ_IMAGE_REPO=`${git}/bin/git remote get-url origin`
      DARTIQ_IMAGE_REPO_REV=`${git}/bin/git describe --always`

      ARTIQ_VERSION=${artiqVersion}
      ARTIQ_REPO=`cd artiq; ${git}/bin/git remote get-url origin`

      NIX_SCRIPTS_REPO=`cd nix-scripts; ${git}/bin/git remote get-url origin`
      NIX_SCRIPTS_REPO_REV=`cd nix-scripts; ${git}/bin/git describe --always`
    '';
    installPhase = ''
    mkdir -p "$out/bin"
    echo "#! ${stdenv.shell}
    echo DARTIQ Image Repo:     $DARTIQ_IMAGE_REPO
    echo DARTIQ Image Repo Rev: $DARTIQ_IMAGE_REPO_REV
    echo
    echo ARTIQ Repo:    $ARTIQ_REPO
    echo ARTIQ Version: $ARTIQ_VERSION
    echo
    echo Nix-Scripts Repo:     $NIX_SCRIPTS_REPO
    echo Nix-Scripts Repo Rev: $NIX_SCRIPTS_REPO_REV" >> $out/bin/version-info
    chmod +x $out/bin/version-info
    '';
}
