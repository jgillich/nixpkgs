#! /usr/bin/env nix-shell
#! nix-shell -i bash -p git curl jq

set -e
export SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt

rustPackages() {
  VERSION=`date +%Y-%m-%d`
  sed -i -r "s/version = \"[0-9\-]+\"/version = \"$VERSION\"/" ../../pkgs/top-level/rust-packages.nix

  REV=`curl -k "https://api.github.com/repos/rust-lang/crates.io-index/git/refs/heads/master" | jq '.object.sha'`
  sed -i -r "s/rev = \"[A-Fa-f0-9]{40}\"/rev = $REV/" ../../pkgs/top-level/rust-packages.nix

  SHA=`nix-prefetch-url ../../ -A rustPlatform.rustRegistry.src | tail -1`
  sed -i -r "s/sha256 = \"[A-Za-z0-9]{52}\"/sha256 = \"$SHA\"/" ../../pkgs/top-level/rust-packages.nix

  nix-build ../../ -A rustPlatform.rustRegistry
}

rustPackages
