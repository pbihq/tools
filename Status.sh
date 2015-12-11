#!/bin/bash

# Script to get a quick status overview on OS X

clear
printf "Displaying current status overview...\n\n"

# Display serial number, current user, host name and current WiFi
serial=$(system_profiler SPHardwareDataType | awk '/Serial Number/ { print $4 }')
currentuser=$(id -F)
printf "Serial number:\t%s\nCurrent user:\t%s\nHost name:\t%s\n" "$serial" "$currentuser" "$(hostname)"

# Display Bluetooth version
# Reference: https://www.bluetooth.org/en-us/specification/assigned-numbers/link-manager
lmp=$(system_profiler -detailLevel full SPBluetoothDataType | awk '/LMP Version/ { print $3 }' | cut -c 3)
if [[ $lmp -eq 8 ]]; then
	bluetooth="4.2"
elif [[ $lmp -eq 7 ]]; then
	bluetooth="4.1"
elif [[ $lmp -eq 6 ]]; then
	bluetooth="4.0"
elif [[ $lmp -eq 5 ]]; then
	bluetooth="3.0 + HS"
elif [[ $lmp -eq 4 ]]; then
	bluetooth="2.1 + EDR"
elif [[ $lmp -eq 3 ]]; then
	bluetooth="2.0 + EDR"
elif [[ $lmp -eq 2 ]]; then
	bluetooth="1.2"
elif [[ $lmp -eq 1 ]]; then
	bluetooth="1.1"
elif [[ $lmp -eq 0 ]]; then
	bluetooth="1.0b"
elif [[ $lmp -gt 8 ]]; then
	bluetooth="4.2+"
fi
printf "Bluetooth:\t%s\n" "$bluetooth"

# Display supported WiFi standards
wifistd=$(system_profiler -detailLevel mini SPAirPortDataType | awk '/Supported PHY Modes/ { print $4" "$5 }')
wifirate=$(/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I | awk '/maxRate/ { print $2 }')
printf "WiFi std:\t%s\nWiFi max:\t%s MBit/s\n" "$wifistd" "$wifirate"

# Display current WiFi SSID, access point BSSID and MAC addresses of primary and secondary networking interfaces
ssid=$(/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I | awk '/[^B]SSID/ { print $2 }')
bssid=$(/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I | awk '/[^B]BSSID/ { print $2 }')
primaryip=$(ipconfig getifaddr en0)
secondaryip=$(ipconfig getifaddr en1)
primarymac=$(networksetup -getmacaddress en0 | awk '{ print $3 }')
secondarymac=$(networksetup -getmacaddress en1 | awk '{ print $3 }')
printf "\nCurrent WiFi:\t%s\nMAC AP (BSSID):\t%s\n\nMAC | IP en0:\t%s\nMAC | IP en1:\t%s\n" "$ssid" "$bssid" "$primarymac | $primaryip" "$secondarymac | $secondaryip"

# Get public IP
pubip=$(dig +short myip.opendns.com @resolver1.opendns.com)
printf "Public IP:\t%s\n" "$pubip"

# Check OS version
os=$(sw_vers -productVersion)
build=$(sw_vers -buildVersion)
printf "\nOS X:\t\t%s\t(Build %s)\n" "$os" "$build"

# Check uptime
runningtime=$(uptime | grep -ohe 'up .*' | sed 's/,//g' | awk '{ print $2" "$3 }')
printf "Uptime:\t\t%s\n" "$runningtime"

# Display battery status
batterycharge=$(pmset -g batt | awk '/-InternalBattery-0/ { print $2 }' | sed 's/;$//')
if [[ -z $batterycharge ]]; then
	batterycharge="(No battery)"
fi
printf "Battery charge:\t%s\n" "$batterycharge"

# Check free disk space
diskspace=$(df -Hl | awk '/disk1/ { print $4 }')
diskusage=$(df -Hl | awk '/disk1/ { print $5 }')
printf "\nHDD usage:\t%s | %sB left\n" "$diskusage" "$diskspace"

# Display CPU usage
cpuload=$(top -l 1 -s 0 | awk '/CPU usage/ { print $3" "$4" "$5" "$6" "$7" "$8 }')
printf "CPU usage:\t%s\n" "$cpuload"

# Calculate Desktop size
desktopsize=$(du -hc ~/Desktop/ | awk '/total/ { print $1 }')
printf "\nDesktop size:\t%sB" "$desktopsize"

# Calculate Apple Mail database size
if [[ $os = 10.11.* ]]; then
	mailversion="V3"
else
	mailversion="V2"
fi
maildbsize=$(ls -lnah ~/Library/Mail/$mailversion/MailData | grep -E 'Envelope Index$' | awk '{ print $5 }')B
printf "\nMail db size:\t%s\n" "$maildbsize"

# Check for Office version installed
pptversion=$(defaults read /Applications/Microsoft\ Office\ 2011/Microsoft\ PowerPoint.app/Contents/version.plist CFBundleVersion)
excelversion=$(defaults read /Applications/Microsoft\ Office\ 2011/Microsoft\ Word.app/Contents/version.plist CFBundleVersion)
wordversion=$(defaults read /Applications/Microsoft\ Office\ 2011/Microsoft\ Excel.app/Contents/version.plist CFBundleVersion)
printf "\nPPT:\t\tv%s\nWord:\t\tv%s\nExcel:\t\tv%s\n" "$pptversion" "$excelversion" "$wordversion"

# List all users
listusers=$(dscl . -list /users shell | grep -v false | grep -v '^_' | awk '{ print $1 }')
printf "\nUser accounts:\n%s\n" "$listusers"

# Check for Filevault and OS X firewall
filevault=$(fdesetup status)
firewall=$(/usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate | awk '{ print $1" "$2" "$3 }')
printf "\n%s\n%s\n" "$filevault" "$firewall"

# Check for OS X software updates
echo
softwareupdate --list
echo

exit 0