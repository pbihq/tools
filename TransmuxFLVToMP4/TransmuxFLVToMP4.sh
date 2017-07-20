#!/bin/bash

# Transmux FLV files to MP4 without re-encoding.

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

# Enable extended globbing. Expand file name patterns which match no files to a null string.
shopt -s extglob nullglob

# #################################################################################################

# Check if operating system is macOS
function checkOS() {
  if [[ ! "$(uname)" = "Darwin" ]]; then return 1; fi
}

# Check if FFmpeg is installed
function checkFFmpegInstalled() {
	which -s ffmpeg
}

# Transmuxes FLV files to MP4
function transmuxFLVToMP4 {
  for filename in *.+(flv|FLV); do
    # Extract filename without file extension
    local filenameBase=${filename%%.*}
    # Display info to user
    info "*** Transmuxing '$filename'... ***"
    "$(which ffmpeg)" \
      -i "$filename" \
      -codec copy \
      "$filenameBase.mp4" \
    && info "*** '$filename' has been successfully transmuxed to '$filenameBase.mp4'. ***"
  done
  return 0
}

# Run functions
checkOS || { fatal "It seems you are not running macOS. Exiting..."; }
checkFFmpegInstalled || { fatal "FFmpeg not found. Please install FFmpeg on your machine. See: https://trac.ffmpeg.org/wiki/CompilationGuide/MacOSX#ffmpegthroughHomebrew"; }
transmuxFLVToMP4 || { fatal "Error transmuxing '$filename' to MP4"; }

exit 0
