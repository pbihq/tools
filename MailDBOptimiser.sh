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

# Check for OS X version
if [[ $os = 10.11.* ]]; then
	mailversion="V3"
else
	mailversion="V2"
fi

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
