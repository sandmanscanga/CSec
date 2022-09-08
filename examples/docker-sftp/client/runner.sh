#!/bin/sh

# Create user's ssh home
mkdir -p /root/.ssh

# Take root owenership and adjust file permissions for user's ssh keyring
chown root:root -R /root/.ssh
chmod 600 /root/.ssh/id_rsa

# Get remote hostkeys and grab remote testfile via SFTP
ssh-keyscan -t rsa sftp >/root/.ssh/known_hosts
sftp tester@sftp:/share/testing.dat /root/testing.dat

# Copy successfully downloaded file into share volume
cp /root/testing.dat /root/share/testing_results.dat

# Command that runs forever to hold the container open
tail -f /dev/null
