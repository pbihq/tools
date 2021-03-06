#!/bin/bash

# Join MOV files generated by a Zoom (Q2n) camera.

# This script generates an output file using the following naming scheme: "YearMonthDay-HourMinuteSecond"
# The timestamp used for this file name is based on the original file's date of creation

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

# Declare FFmpegInputList name variable
umask 077
readonly FFmpegInputList=$(mktemp)

# Check if operating system is macOS
function checkOS() {
  if [[ ! "$(uname)" = "Darwin" ]]; then return 1; fi
}

# Check if FFmpeg is installed
function checkFFmpegInstalled() {
	which -s ffmpeg
}

# Create input list file for FFmpeg.
function createFFmpegInputList() {
	# First add file names starting with "ZOOM"
	for firstFile in +(ZOOM)*.+(MOV|mov); do
		echo "file '${PWD}/${firstFile}'" >> $FFmpegInputList
	done

	# Then add subsequent file names starting with "ZO0"
	for followingFile in +(ZO)+([0-9][0-9]).+(MOV|mov); do
		echo "file '${PWD}/${followingFile}'" >> $FFmpegInputList
	done

  # Check if FFmpegInputList has been created
  if [[ ! -f $FFmpegInputList ]]; then
    fatal "FFmpegInputList not found / no MOV files in current directory. Exiting..."
  fi
}

# Delete temporary file list if it exists
function deleteFFmpegInputList() {
	if [[ -f $FFmpegInputList ]]; then
		rm -f $FFmpegInputList
	fi
}

# Join video files using FFmpeg's concat demuxer. See: https://trac.ffmpeg.org/wiki/Concatenate
function joinMOVs() {
  info "*** Joining MOV files... ***"
	# Generate time stamp for output file based on date of first input file (ZOOM*.MOV)
	timeStamp=$(stat -f "%Sm" -t "%y%m%d-%H%M%S" +(ZOOM)*.+(MOV|mov))
	# Run FFmpeg
	ffmpeg \
		-loglevel error \
		-stats \
		-f concat \
		-safe 0 \
		-i $FFmpegInputList \
		-c copy \
		"${timeStamp}.mov" \
	&& info "Completed. '${timeStamp}.mov' has been created."
}

# Clean up step in case of errors and at the end
function cleanUp() {
  deleteFFmpegInputList
}

# Run functions
trap cleanUp EXIT
checkOS || { fatal "It seems you are not running macOS. Exiting..."; }
checkFFmpegInstalled || { fatal "FFmpeg not found. Please install FFmpeg on your machine. See: https://trac.ffmpeg.org/wiki/CompilationGuide/MacOSX#ffmpegthroughHomebrew"; }
deleteFFmpegInputList || { fatal "Error running deleteFFmpegInputList()"; }
createFFmpegInputList || { fatal "Error running createFFmpegInputList()"; }
joinMOVs || { fatal "Error joining MOV files"; }

exit 0
