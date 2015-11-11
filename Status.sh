#!/bin/bash

# Script to get a quick status overview on OS X
# v1.0 | November 2015

clear
printf "Displaying current status overview...\n\n"

# Display serial number, current user, host name and current WiFi
serial=$(system_profiler SPHardwareDataType | grep "Serial Number" | awk '{ print $4 }')
currentuser=$(id -F)
hostname=$(scutil --get HostName)
ssid=$(/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I | awk '/[^B]SSID/ { print $2 }')
printf "Serial number:\t%s\nCurrent user:\t%s\nHost name:\t%s\nCurrent WiFi:\t%s\n" "$serial" "$currentuser" "$hostname" "$ssid"

# Check OS version
os=$(sw_vers -productVersion)
printf "\nOS X:\t%s\n" "$os"

# Check uptime and load
runningtime=$(uptime | grep -ohe 'up .*' | sed 's/,//g' | awk '{ print $2" "$3 }')
load=$(uptime | grep -ohe 'load average[s:][: ].*' | awk '{ print $3 }')
printf "Uptime:\t%s\nLoad:\t%s\n" "$runningtime" "$load"

# Check free disk space
diskspace=$(df -Hl | grep "disk1" | awk '{ print $4 }')
diskusage=$(df -Hl | grep "disk1" | awk '{ print $5 }')
printf "\nFree disk space left:\t%s\nDisk usage in percent:\t%s\n" "$diskspace" "$diskusage"

# Calculate Apple Mail database size
if [[ $os = 10.11.* ]]; then
	mailversion="V3"
else
	mailversion="V2"
fi
maildbsize=$(ls -lnah ~/Library/Mail/$mailversion/MailData | grep -E 'Envelope Index$' | awk '{ print $5 }')B
printf "\nMail database size:\t%s\n" "$maildbsize"

# Check for Filevault and OS X firewall
filevault=$(fdesetup status)
firewall=$(/usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate | awk '{ print $1" "$2" "$3 }')
printf "\n%s\n%s\n" "$filevault" "$firewall"

# Display MAC addresses of primary and secondary networking interfaces
primary=$(ifconfig en0 | grep -o -E '([[:xdigit:]]{1,2}:){5}[[:xdigit:]]{1,2}')
secondary=$(ifconfig en1 | grep -o -E '([[:xdigit:]]{1,2}:){5}[[:xdigit:]]{1,2}')
printf "\nMAC address en0:\t%s\nMAC address en1:\t%s\n" "$primary" "$secondary"

# Check for OS X software updates
echo
softwareupdate --list
echo

exit 0