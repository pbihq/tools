#!/bin/bash
# This small script looks for the macOS High Sierra installer and if found removes it.
# Run it with sudo or as root in Apple Remote Desktop.

readonly installerApp="/Applications/Install macOS High Sierra.app/"
readonly user=$(whoami)

# Check if script is being run with root privileges
if [[ "$user" != "root" ]]; then
  echo "Error: Please run script with 'sudo' or as root"; exit 1
fi

# Check and delete if installer app exists
if [[ -d "$installerApp" ]]; then
  rm -rf "$installerApp" \
    && echo "macOS High Sierra installer has been deleted."; exit 0 \
    || echo "Error: macOS High Sierra installer could not be removed."; exit 1
else
  echo "macOS High Sierra installer not found."
  exit 0
fi
