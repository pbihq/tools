#!/bin/bash
TERM=xterm-256color

# Script to get a quick status overview on OS X

clear
printf "Displaying current status overview...\n\n"

# Display Apple Mac marketing name, serial number, current user, host name and current WiFi
macname=$(curl -s http://support-sp.apple.com/sp/product?cc=\
$( ioreg -c IOPlatformExpertDevice -d 2 | awk -F\" '/IOPlatformSerialNumber/\
{ sn=$(NF-1); if (length(sn) == 12) count=3; else if (length(sn) == 11) \
count=2; print substr(sn, length(sn) - count, length(sn))}' ) | \
xpath '/root/configCode/text()' 2>/dev/null)
serial=$(system_profiler SPHardwareDataType | awk '/Serial Number/ { print $4 }')
currentuser=$(id -F)
printf "Mac:\t\t\t%s\nSerial number:\t\t%s\nCurrent user:\t\t%s\nHost name:\t\t%s\n" "$macname" "$serial" "$currentuser" "$(hostname)"

# Display Bluetooth version
# Reference: https://www.bluetooth.org/en-us/specification/assigned-numbers/link-manager
lmp=$(system_profiler -detailLevel full SPBluetoothDataType | awk '/LMP Version/ { print $3 }')

if [ $lmp = "0x8" ] || [ $lmp = "4.2" ]; then
	bluetooth="4.2"
elif [ $lmp = "0x7" ] || [ $lmp = "4.1" ]; then
	bluetooth="4.1"
elif [ $lmp = "0x6" ] || [ $lmp = "4.0" ]; then
	bluetooth="4.0"
elif [ $lmp = "0x5" ] || [ $lmp = "3.0" ]; then
	bluetooth="3.0 + HS"
elif [ $lmp = "0x4" ] || [ $lmp = "2.1" ]; then
	bluetooth="2.1 + EDR"
elif [ $lmp = "0x3" ] || [ $lmp = "2.0" ]; then
	bluetooth="2.0 + EDR"
elif [ $lmp = "0x2" ] || [ $lmp = "1.2" ]; then
	bluetooth="1.2"
elif [ $lmp = "0x1" ] || [ $lmp = "1.1" ]; then
	bluetooth="1.1"
elif [ $lmp = "0x0" ] || [ $lmp = "1.0b" ]; then
	bluetooth="1.0b"
else
	bluetooth="Bluetooth version unknown"
fi
printf "Bluetooth:\t\t%s\n" "$bluetooth"

# Display supported WiFi standards
wifistd=$(system_profiler -detailLevel mini SPAirPortDataType | awk '/Supported PHY Modes/ { print $4" "$5 }')
wifirate=$(/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I | awk '/maxRate/ { print $2 }')
printf "WiFi std:\t\t%s\nWiFi max rec:\t\t%s MBit/s\n" "$wifistd" "$wifirate"

# Display current WiFi SSID, access point BSSID and MAC addresses of primary and secondary networking interfaces
ssid=$(/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I | awk '/[^B]SSID/ { print $2 }')
bssid=$(/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I | awk '/[^B]BSSID/ { print $2 }')
primaryip=$(ipconfig getifaddr en0)
secondaryip=$(ipconfig getifaddr en1)
primarymac=$(networksetup -getmacaddress en0 | awk '{ print $3 }')
secondarymac=$(networksetup -getmacaddress en1 | awk '{ print $3 }')
printf "\nCurrent WiFi:\t\t%s\nMAC AP (BSSID):\t\t%s\n\nMAC | IP en0:\t\t%s\nMAC | IP en1:\t\t%s\n" "$ssid" "$bssid" "$primarymac | $primaryip" "$secondarymac | $secondaryip"

# Get public IP
pubip=$(dig +short myip.opendns.com @resolver1.opendns.com)
printf "Public IP:\t\t%s\n" "$pubip"

# Check OS version
os=$(sw_vers -productVersion)
build=$(sw_vers -buildVersion)
printf "\nOS X:\t\t\t%s\t(Build %s)\n" "$os" "$build"

# Check uptime
runningtime=$(uptime | grep -ohe 'up .*' | sed 's/,//g' | awk '{ print $2" "$3 }')
printf "Uptime:\t\t\t%s\n" "$runningtime"

# Display battery status
batterycharge=$(pmset -g batt | awk '/-InternalBattery-0/ { print $2 }' | sed 's/;$//')
if [[ -z $batterycharge ]]; then
	batterycharge="(No battery)"
fi
printf "Battery charge:\t\t%s\n" "$batterycharge"

# Check free disk space
diskspace=$(df -Hl | awk '/disk1/ { print $4 }')
diskusage=$(df -Hl | awk '/disk1/ { print $5 }')
printf "\nHDD usage:\t\t%s | %sB left\n" "$diskusage" "$diskspace"

# Display CPU usage
cpuload=$(top -l 1 -s 0 | awk '/CPU usage/ { print $3" "$4" "$5" "$6" "$7" "$8 }')
printf "CPU usage:\t\t%s\n" "$cpuload"

# Calculate Desktop size and number of elements
desktopelements=$(ls ~/Desktop/ | wc -l | xargs)
desktopsize=$(du -hc ~/Desktop/ | awk '/total/ { print $1 }')
printf "\nDesktop items:\t\t%s (%sB)" "$desktopelements" "$desktopsize"

# Calculate Apple Mail database size
if [[ $os = 10.11.* ]]; then
	mailversion="V3"
else
	mailversion="V2"
fi
maildbsize=$(ls -lnah ~/Library/Mail/$mailversion/MailData | grep -E 'Envelope Index$' | awk '{ print $5 }')B
printf "\nMail db size:\t\t%s\n" "$maildbsize"

# Check for installed MS Office software and print out version numbers
# Associative arrays in Bash are only supported from 4.0 upwards so three manual checks used

# PowerPoint checks
if [[ -f /Applications/Microsoft\ PowerPoint.app/Contents/Info.plist ]] ; then
	pptversion2016=$(defaults read /Applications/Microsoft\ PowerPoint.app/Contents/Info.plist CFBundleShortVersionString)
else
	pptversion2016="-"
fi

if [[ -f /Applications/Microsoft\ Office\ 2011/Microsoft\ PowerPoint.app/Contents/version.plist ]] ; then
	pptversion2011=$(defaults read /Applications/Microsoft\ Office\ 2011/Microsoft\ PowerPoint.app/Contents/version.plist CFBundleVersion)
else
	pptversion2011="-"
fi

# Excel checks
if [[ -f /Applications/Microsoft\ Excel.app/Contents/Info.plist ]] ; then
	excelversion2016=$(defaults read /Applications/Microsoft\ Excel.app/Contents/Info.plist CFBundleShortVersionString)
else
	excelversion2016="-"
fi

if [[ -f /Applications/Microsoft\ Office\ 2011/Microsoft\ Excel.app/Contents/version.plist ]] ; then
	excelversion2011=$(defaults read /Applications/Microsoft\ Office\ 2011/Microsoft\ Excel.app/Contents/version.plist CFBundleVersion)
else
	excelversion2011="-"
fi

# Word checks
if [[ -f /Applications/Microsoft\ Word.app/Contents/Info.plist ]] ; then
	wordversion2016=$(defaults read /Applications/Microsoft\ Word.app/Contents/Info.plist CFBundleShortVersionString)
else
	wordversion2016="-"
fi

if [[ -f /Applications/Microsoft\ Office\ 2011/Microsoft\ Word.app/Contents/version.plist ]] ; then
	wordversion2011=$(defaults read /Applications/Microsoft\ Office\ 2011/Microsoft\ Word.app/Contents/version.plist CFBundleVersion)
else
	wordversion2011="-"
fi

# Display MS Office version numbers
printf "\nOffice 2016:\t\tWord 2016: %s | Excel 2016: %s | PPT 2016: %s" "$pptversion2016" "$excelversion2016" "$wordversion2016"
printf "\nOffice 2011:\t\tWord 2011: %s | Excel 2011: %s | PPT 2011: %s" "$pptversion2011" "$excelversion2011" "$wordversion2011"

# Display Dropbox version
dropboxversion=$(defaults read /Applications/Dropbox.app/Contents/Info.plist CFBundleVersion)
printf "\nDropbox:\t\tv%s\n" "$dropboxversion"

# List all users
listusers=$(dscl . -list /users shell | grep -v false | grep -v '^_' | awk '{ print $1 }')
printf "\nUser accounts:\n%s\n" "$listusers"

# Check for Filevault, OS X firewall and System Integrity Protection
filevaultstatus=$(fdesetup status)
firewallstatus=$(/usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate | awk '{ print $1" "$2" "$3 }')
if [[ $os = 10.11.* ]]; then
	sipstatus=$(csrutil status)
else
	sipstatus=""
fi

printf "\n%s\n%s\n%s\n" "$filevaultstatus" "$firewallstatus" "$sipstatus"

# Check for OS X software updates
# echo
# softwareupdate --list
# echo

exit 0
