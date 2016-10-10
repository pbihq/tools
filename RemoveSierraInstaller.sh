#!/bin/bash
# This sall script looks for the macOS Sierra installer and if found removes it.

if [[ -d /Applications/Install\ macOS\ Sierra.app/ ]] ; then
  rm -rf /Applications/Install\ macOS\ Sierra.app/
  if [[ -d /Applications/Install\ macOS\ Sierra.app/ ]] ; then
    echo "Error: macOS Sierra installer could not be removed."
    exit 1
  else
  echo "macOS Sierra installer has been deleted."
  exit 0
  fi
else
  echo "macOS Sierra installer not found."
  exit 0
fi
