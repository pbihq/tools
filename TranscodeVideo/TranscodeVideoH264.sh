#!/bin/bash

# Transcode MOV/MP4/MKV file while applying some audio filters

# #################################################################################################
# Set up logging
info()    { echo "[INFO] $*" 1> >(sed $'s,.*,\e[32m&\e[m,'); }
warning() { echo "[WARNING] $*" 1> >(sed $'s,.*,\e[33m&\e[m,'); }
error()   { echo "[ERROR] $*" 1> >(sed $'s,.*,\e[31m&\e[m,'); exit 1; }
# #################################################################################################
# Set unofficial Bash strict mode
# Source: https://dev.to/thiht/shell-scripts-matter
set -euo pipefail
IFS=$'\n\t'

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

# Transmuxes all FLV files in current directory to MP4
transmuxFLVToMP4() {
    for filename in *.+(flv|FLV); do
        # Extract filename without file extension
        local filenameBase=${filename%%.*}
        # Display info to user
        info "*** Transmuxing '$filename'... ***"
        ffmpeg \
            -i "$filename" \
            -codec copy \
            "$filenameBase.mp4" \
        && info \
        "*** '$filename' has been successfully transmuxed to '$filenameBase.mp4'. ***"
    done
}

# Compresses all MP4 / MOV files in current directory
compressH264() {
    for filename in *.+(MOV|mov|MP4|mp4|MKV|mkv); do
        # Extract filename without file extension
        local filenameBase=${filename%%.*}
        # Display info to user
        info "*** Compressing '$filename'... ***"
        # Start conversion
        ffmpeg \
            -i "$filename" \
            -c:v libx264 \
            -preset veryfast \
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

checkInstalled ffmpeg || error \
"FFmpeg not found. Please install, e.g. via Homebrew 'brew install ffmpeg'"

transmuxFLVToMP4 || error "Error transmuxing '$filename' to MP4"

compressH264 || error "Error converting video '$filename'"

exit 0