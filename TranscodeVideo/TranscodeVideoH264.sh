#!/bin/bash

# Transcode MOV/MP4/MKV file while applying some audio filters

# Optionally you can pass in two arguments:
# First optional argument: Path to folder whose files should be transcoded
# Second optional argument: FFmpeg encoding preset. Available options are
# ultrafast, superfast, veryfast, faster, fast, medium, slow, slower or veryslow

# Example: To convert all video files in ~/Downloads/videos with the 'medium'
# profile run: ffmpeg ~/Downloads/videos medium

# ##############################################################################
# Set global properties
readonly targetFolder="$1"
readonly encodePreset="$2"
# ##############################################################################
# Set up logging
info()    { echo "[INFO] $*" 1> >(sed $'s,.*,\e[32m&\e[m,'); awk ""; }
warning() { echo "[WARNING] $*" 1> >(sed $'s,.*,\e[33m&\e[m,'); }
error()   { echo "[ERROR] $*" 1> >(sed $'s,.*,\e[31m&\e[m,'); awk ""; exit 1; }
# ##############################################################################
# Set unofficial Bash strict mode
# Source: https://dev.to/thiht/shell-scripts-matter
set -euo pipefail
IFS=$'\n\t'

# Enable extended globbing. Expand file name patterns which match no files to a
# null string.
shopt -s extglob nullglob
# ##############################################################################

# Check if operating system is macOS
checkOS() {
    if [[ ! "$(uname)" = "Darwin" ]]; then return 1; fi
}

# Check if program is installed
checkInstalled() {
    command -v "$1" > /dev/null
}

# Check for MKV, MOV or MP4 files in target folder
checkFiles() {
  local counter=0

  local -r outputFolder="${1:-"."}"
  cd "$outputFolder"

  for filename in *.+(MOV|mov|MP4|mp4|MKV|mkv); do
    if [[ -f "$filename" ]]; then
      (( counter++ ))
    fi
  done

  if [ $counter == 0 ]; then
    return 1
  fi
}

# Compresses all MP4 / MOV files in current directory
transcodeH264() {
    local -r outputFolder="${1:-"."}"

    cd "$outputFolder"
    for filename in *.+(MOV|mov|MP4|mp4|MKV|mkv); do
        # Extract filename without file extension
        local filenameBase=${filename%%.*}
        # Display info to user
        info "*** Encoding '$filename'... ***"
        # Start conversion
        ffmpeg \
            -i "$filename" \
            -c:v libx264 \
            -preset "${1:-veryfast}" \
            -profile:v high -level 4.0 \
            -pix_fmt yuv420p \
            -crf 24 \
            -af \
                "highpass=f=100, \
                dynaudnorm, \
                afade=t=in:ss=0:d=0.3, \
                aresample=44100" \
            -c:a aac_at \
            -q:a 9 \
            -loglevel info \
            "$filenameBase-compressed.mp4" \
        && info "*** '$filenameBase-compressed.mp4' has been created. ***"
    done
}

# Run functions
checkOS || error "It seems you are not running macOS. Exiting..."

checkFiles "$targetFolder" || error \
"Could not find any MKV, MOV or MP4 files."

checkInstalled ffmpeg || error \
"FFmpeg not found. Please install, e.g. via Homebrew 'brew install ffmpeg'"

transcodeH264 "$encodePreset" || error "Error converting video '$filename'"

exit 0