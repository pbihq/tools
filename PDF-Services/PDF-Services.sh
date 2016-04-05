#!/bin/bash
#
# Setup PDF-Services
#
# Note: PKG installer deploys payloads to /tmp

# Check for existing custom user colours and copy PLIST if they don't exist
cp /tmp/Combine\ PDFs.workflow/ /tmp/SplitPDF.workflow/ ~/

# Install PBI Colours palette for current user
cp /tmp/PBI\ Colours\ v1.1.clr ~/Library/Colors
rm /tmp/PBI\ Colours\ v1.1.clr

# Assign files to user
chown $USER:staff ~/Library/Colors/*

exit 0
