#!/bin/bash
# Install status script. After that you can run it by simply typing "status" in Terminal

# Get admin user password
echo "Please enter your user name password:"
sudo -v

# Check for /usr/local/bin and install if not present
sudo mkdir -p /usr/local /usr/local/bin

# Assign rights for /usr/local/bin to local admin user
chmod -R 755 /usr/local/bin
sudo chown -R $USER:$GROUP /usr/local/bin

# Generate status script executable
cat > /usr/local/bin/status << EOF
#!/bin/bash
bash <(curl -s https://raw.githubusercontent.com/pbihq/tools/master/Status/Status.sh)
exit 0
EOF

chmod 755 /usr/local/bin/status
exit 0