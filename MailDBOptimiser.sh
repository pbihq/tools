#!/bin/bash

# Apple Mail database defragmentation / optimisation script

# Start script
clear
echo "Apple Mail Database optimisation started..."

# Define variable(s)
os=$(sw_vers -productVersion)

# Close Apple Mail
AppRunning=$(pgrep Mail)
if [[ -n $AppRunning ]]; then
    osascript -e 'quit app "Mail"'
fi

# Set Mailversion for correct filepath
case $os in
10.10*) mailversion="V2";;
10.11*) mailversion="V3";;
10.12*) mailversion="V4";;
*) echo "Error while setting mail version. Please note: This script only works from macOS 10.10 to 10.12"
esac

# Calculate database size before starting optimisation
sizebefore=$(ls -lnah ~/Library/Mail/$mailversion/MailData | grep -E 'Envelope Index$' | awk {'print $5'})B

# Run database optimisation (SQL vaccuming)
/usr/bin/sqlite3 ~/Library/Mail/$mailversion/MailData/Envelope\ Index vacuum &> /private/tmp/MailDatabaseOptimisation.log
error=$(cat /private/tmp/MailDatabaseOptimisation.log)

# Calculate database size after optimisation
sizeafter=$(ls -lnah ~/Library/Mail/$mailversion/MailData | grep -E 'Envelope Index$' | awk {'print $5'})B

# Create success/error message
if [[ -z $error ]]; then
	error=0
	echo "Done."
else
	echo $error
fi

# Show stats
printf "\nMail index size before:\t%s\nMail index size after:\t%s\n\nEnjoy the new speed!\n\n" "$sizebefore" "$sizeafter"

# Set exit code
if [[ "$error" -ne "0" ]]; then
	logger "Apple Mail Database Optimisation failed."
	exit 1
else
	logger "Apple Mail Database Optimisation finished."
	exit 0
fi
