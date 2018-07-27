#!/bin/bash

# #################################################################################################
# Create Point Blank Puppet Bootstrapper package
# #################################################################################################
# Set up logging
info()    { echo "[INFO] $*" 1> >(sed $'s,.*,\e[32m&\e[m,'); }
warning() { echo "[WARNING] $*" 1> >(sed $'s,.*,\e[33m&\e[m,'); }
error()   { echo "[ERROR] $*" 1> >(sed $'s,.*,\e[35m&\e[m,'); }
fatal()   { echo "[FATAL] $*" 1> >(sed $'s,.*,\e[31m&\e[m,'); exit 1; }
# #################################################################################################
# Set unofficial Bash strict mode
# Source: https://dev.to/thiht/shell-scripts-matter
set -euo pipefail
IFS=$'\n\t'

# Set working directory so that script can be run independent of location
DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
# #################################################################################################

# Check if operating system is macOS
function checkOS() {
  if [[ ! "$(uname)" = "Darwin" ]]; then return 1; fi
}

# Build package
function buildPKG() {
  # Name of the package.
  PKGName="Remove Flashplayer"

  # Once installed the identifier is used as the filename for a receipt files in /var/db/receipts/.
  PKGIdentifier="net.point-blank.removeflash"

  # Package version number.
  PKGVersion="2.0"

  # Remove any unwanted .DS_Store files.
  find "$DIR" -name '*.DS_Store' -type f -delete

  # Remove any extended attributes (ACEs).
  xattr -rc "$DIR"

  # Make scripts executable
  chmod +x "$DIR"/scripts/*

  # Build package.
  pkgbuild \
    --root "$DIR/payload" \
    --scripts "$DIR/scripts" \
    --identifier "$PKGIdentifier" \
    --version "$PKGVersion" \
    "$DIR/build/${PKGName}-v${PKGVersion}.pkg"
}

checkOS || fatal "It seems you are not running macOS. Exiting..."
buildPKG || error "Something went wrong while running buildPKG()"

exit 0
