#!/bin/bash
# Uninstall Adobe Flash Player from the command line

# Run the uninstaller
if [[ -d /Applications/Adobe\ Flash\ Player\ Uninstaller.app/ ]] ; then
/Applications/Adobe\ Flash\ Player\ Uninstaller.app/Contents/MacOS/Adobe\ Flash\ Player\ Install\ Manager -uninstall

# Remove uninstaller app
rm -rf /Applications/Adobe\ Flash\ Player\ Uninstaller.app

  if [[ -d /Applications/Adobe\ Flash\ Player\ Uninstaller.app/ ]] ; then
    echo "Error: Adobe Flash Player Uninstaller app could not be removed."
    exit 1
  else
    echo "Adobe Flash Player has been removed."
    logger "Adobe Flash Player has been removed."
    exit 0
  fi

else
  echo "Adobe Flash Player Uninstaller not found."
  exit 0
fi
