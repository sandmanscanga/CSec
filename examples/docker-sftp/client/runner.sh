#!/bin/sh

mkdir -p /root/.ssh
chown root:root -R /root/.ssh
chmod 600 /root/.ssh/id_rsa
ssh-keyscan -t rsa sftp >/root/.ssh/known_hosts
sftp tester@sftp:/share/testing.dat /root/testing.dat
cat /root/testing.dat
tail -f /dev/null
