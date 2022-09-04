#!/bin/bash

export SFTP_RANDOM_PASSWORD=$(cat /proc/sys/kernel/random/uuid| md5sum | head -c 20)
