#!/bin/bash
# Uninstall Adobe Flash Player from the command line

# Run the uninstaller
/Applications/Adobe\ Flash\ Player\ Uninstaller.app/Contents/MacOS/Adobe\ Flash\ Player\ Install\ Manager -uninstall

# Remove uninstaller app
rm -rf /Applications/Adobe\ Flash\ Player\ Uninstaller.app

logger "Adobe Flash Player has been removed"
exit 0