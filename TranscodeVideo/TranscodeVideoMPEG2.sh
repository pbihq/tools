#!/bin/bash

# Transcode MOV/MP4/MKV file to MPEG2 while applying some audio filters

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

# Transmuxes all FLV files in current directory to MP4
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
}

# Compresses all MP4 / MOV files in current directory
function compressH264 {
  for filename in *.+(MOV|mov|MP4|mp4|MKV|mkv); do
    # Extract filename without file extension
    local filenameBase=${filename%%.*}
    # Display info to user
    info "*** Compressing '$filename'... ***"
    # Start conversion
    "$(which ffmpeg)" \
      -i "$filename" \
      -shortest \
      -qscale:v 2 \
      -c:v mpeg2video \
      -af \
        "highpass=f=100, \
        compand=attacks=0:points=-80/-80|-12.4/-12.4|-6/-8|0/-6.8|20/-2.8, \
        afade=t=in:ss=0:d=0.3, \
        loudnorm, \
        aresample=44100" \
      -c:a mp2 \
      -b:a 192k \
      -loglevel info \
      "$filenameBase.mpg" \
    && info "*** '$filenameBase.mpg' has been created. ***"
  done
}

# Run functions
checkOS || { fatal "It seems you are not running macOS. Exiting..."; }
checkFFmpegInstalled || { fatal "FFmpeg not found. Please install FFmpeg on your machine. See: https://trac.ffmpeg.org/wiki/CompilationGuide/MacOSX#ffmpegthroughHomebrew"; }
transmuxFLVToMP4 || { fatal "Error transmuxing '$filename' to MPG"; }
compressH264 || { fatal "Error converting video '$filename'"; }

exit 0
