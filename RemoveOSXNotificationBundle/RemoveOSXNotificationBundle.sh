#!/bin/bash
# This small script looks for the OSXNotification.bundle (that prompts users to upgrade their machine) and removes it.
# See: https://eclecticlight.co/2017/11/09/apple-is-nudging-us-to-upgrade-to-flagging-high-sierra/
# Run it with sudo or as root in Apple Remote Desktop.

readonly bundle="/Library/Bundles/OSXNotification.bundle"

# Check if script is being run with root privileges
if [[ "$EUID" -ne 0 ]]; then
  echo "Error: Please run script with 'sudo' or as root"; exit 1
fi

# Check and delete if installer app exists
if [[ -d "$bundle" ]]; then
  rm -rf "$bundle" \
    && echo "OSXNotification.bundle has been deleted."; exit 0 \
    || echo "Error: OSXNotification.bundle could not be removed."; exit 1
else
  echo "OSXNotification.bundle not found."
  exit 0
fi
