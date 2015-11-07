#!/bin/bash
# PBI SSH Setup v1.3

# Define variable(s)
os=$(sw_vers -productVersion)
group=$(id -ng)

# Define path for sshd_config
if [[ $os > "10.10" ]]; then
	sshd_config_path="/etc/ssh/sshd_config"
else
	sshd_config_path="/etc/sshd_config"
fi

# Create folder structure and define ACLs
if [ ! -d ~/.ssh ]; then
	mkdir ~/.ssh
fi
chmod 700 ~/.ssh

# Copy public keys to authorized_keys
cat > ~/.ssh/authorized_keys << EOF
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMjrRfL6f0W/w83PJ04rvQQ4rI63eRWF0PWXnoGoyLez paul.galow@point-blank-international.com
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDiYgB1D6absBbn/zAZ5V+LOAvto/2IdPDMuG5UolAHPuPzPZMzJQklajkHf8C3u+DqqDwllIgJpzBOPilan2a9zze0qH9a36/gvgBz2B5d6ZmG5yI8u55xrouUyA6yAjR8/qXhM8rqEmW1awSlzSJot+mBIrcUiVIQA/C+Bi0YomJjGMwZhusaoZ1JMq7QISQdzGBeB9S6Bp0f5e/WV5s/bDzS95nx/bmrbnP9ukSZUsGvaSE8ietv33gvCJY1ZsMa/DsdDFIl1mNgbIc6+1mWTdmzFb25ZGgkV3Si1BqOq/hhZxIBGoFvSdOyLjNun3V5/IXyyRJWRq6BJLcZaQDZmld5b7aOhCrWJVx4f25YW1YIJljjXPvjoNnRzgzvoKMClLflh3ictkYDO61Ax7J9NQqDgnVWxR6Soyst1yoj1z2E3o6trsEQ9AKKPTGqK1cW76Ai3aRf1LUzaM0NILyETbsbwQOZGN+V4GdNRuuKnQfD7rts86k2f8B1Wae3Mvje4sMwQLDTjB0ZVio+oQb4QYJ+794sowRJYfvHqBmzLdxOgdTzmOF5XnYJg3UUJoIm1HGc66F0aoiy0ay9d4vs4vxxOxo3q0cnJ5Px8CdXU/WBzD8c9Bq2nEzGSv+LatE66mJAizZev7zgfvuUFiWw4Vj42Aaq/aavRIBAyNz2GQ==
EOF

chmod 600 ~/.ssh/authorized_keys
chown -R $USER:$group ~/.ssh

# Edit SSH configuration at /etc/sshd_config
cp $sshd_config_path $sshd_config_path.bak
sed -i "" "s/#PasswordAuthentication yes/PasswordAuthentication no/" $sshd_config_path
sed -i "" "s/PasswordAuthentication yes/PasswordAuthentication no/" $sshd_config_path
sed -i "" "s/#PasswordAuthentication no/PasswordAuthentication no/" $sshd_config_path

sed -i "" "s/#ChallengeResponseAuthentication yes/ChallengeResponseAuthentication no/" $sshd_config_path
sed -i "" "s/ChallengeResponseAuthentication yes/ChallengeResponseAuthentication no/" $sshd_config_path
sed -i "" "s/#ChallengeResponseAuthentication no/ChallengeResponseAuthentication no/" $sshd_config_path

sed -i "" "s/#PermitRootLogin yes/PermitRootLogin no/" $sshd_config_path
sed -i "" "s/#PermitRootLogin no/PermitRootLogin no/" $sshd_config_path
sed -i "" "s/PermitRootLogin yes/PermitRootLogin no/" $sshd_config_path

# Restart SSH service
launchctl stop com.openssh.sshd

# Activate SSH remote login
systemsetup -f -setremotelogin on

logger "PBI SSH Setup installiert"
exit 0