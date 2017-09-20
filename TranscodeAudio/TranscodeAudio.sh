#!/bin/bash

# Transcode WAV/AIF to MP3 file while applying some audio filters

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

# Transcodes all WAV / AIF files in current directory to MP3
function transcodeMP3 {
  for filename in *.+(WAV|wav|AIF|aif); do
    # Extract filename without file extension
    local filenameBase=${filename%%.*}
    # Display info to user
    info "*** Compressing '$filename'... ***"
    # Start conversion
    "$(which ffmpeg)" \
      -i "$filename" \
      -af \
        "highpass=f=100, \
        dynaudnorm, \
        afade=t=in:ss=0:d=0.3, \
        aresample=44100" \
      -c:a libmp3lame \
      -q:a 4 \
      -loglevel info \
      "$filenameBase.mp3" \
    && info "*** '$filenameBase.mp3' has been created. ***"
  done
}

# Run functions
checkOS || { fatal "It seems you are not running macOS. Exiting..."; }
checkFFmpegInstalled || { fatal "FFmpeg not found. Please install FFmpeg on your machine. See: https://trac.ffmpeg.org/wiki/CompilationGuide/MacOSX#ffmpegthroughHomebrew"; }
transcodeMP3 || { fatal "Error converting video '$filename'"; }

exit 0
