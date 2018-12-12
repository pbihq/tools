#!/bin/bash

# Transmux FLV files to MP4 without re-encoding.

# ##############################################################################
# Set global properties
readonly targetFolder="$1"
# #################################################################################################
# Set up logging
info()    { echo "[INFO] $*" 1> >(sed $'s,.*,\e[32m&\e[m,'); awk ""; }
warning() { echo "[WARNING] $*" 1> >(sed $'s,.*,\e[33m&\e[m,'); awk ""; }
error()   { echo "[ERROR] $*" 1> >(sed $'s,.*,\e[35m&\e[m,'); awk ""; exit 1; }
# #################################################################################################
# Set unofficial Bash strict mode
# Source: https://dev.to/thiht/shell-scripts-matter
set -euo pipefail
IFS=$'\n\t'

# Set working directory so that script can be run independent of location
DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi

# Enable extended globbing. Expand file name patterns which match no files to a null string.
shopt -s extglob nullglob

# #################################################################################################

# Check if operating system is macOS
checkOS() {
  if [[ ! "$(uname)" = "Darwin" ]]; then return 1; fi
}

# Check if program is installed
checkInstalled() {
  command -v "$1" > /dev/null
}

# Check for FLV files in target folder
checkFiles() {
  local counter=0

  local -r outputFolder="${1:-"."}"
  cd "$outputFolder"

  for filename in *.+(flv|FLV); do
    if [[ -f "$filename" ]]; then
      (( counter++ ))
    fi
  done

  if [ $counter == 0 ]; then
    return 1
  fi
}

# Transmuxes FLV files to MP4
transmuxFLVToMP4() {
  local -r outputFolder="${1:-"."}"
  cd "$outputFolder"
  for filename in *.+(flv|FLV); do
    # Extract filename without file extension
    local filenameBase=${filename%%.*}
    # Display info to user
    info "*** Transmuxing '$filename'... ***"
    ffmpeg \
      -i "$filename" \
      -codec copy \
      -loglevel error \
      "$filenameBase.mp4" \
    && info "*** '$filename' has been successfully transmuxed to '$filenameBase.mp4'. ***"
  done
  return 0
}

# Run functions
trap exit 0 SIGINT # Press Ctrl+C to exit

checkOS || error \
"It seems you are not running macOS. Exiting..."

checkInstalled ffmpeg || error \
"FFmpeg not found. Please install, e.g. via Homebrew 'brew install ffmpeg'"

checkFiles "$targetFolder" || error \
"Could not find any FLV files."

transmuxFLVToMP4 "$targetFolder" || error \
"Error transmuxing '$filename' to MP4"

exit 0
