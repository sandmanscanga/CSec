#!/bin/bash

# Verify current working directory
if [[ ! -f 'runner.sh' ]] || [[ ! -f 'docker-compose.yml' ]]; then
    echo "Please change into the SFTP docker compose directory!" >&2
    exit 1
fi

# Set environment variables
export SFTP_ADDR="172.69.0.1"
export SFTP_USER="tester"
export SFTP_PASS=$(cat /dev/random | xxd -p | head -c 24)
export CLIENT_ADDR="172.69.0.2"

## Set top level variables
PROJECT_ROOT=$(readlink -f .)
TESTFILE=$PROJECT_ROOT/testing.dat
VOLUME_ROOT=$PROJECT_ROOT/volume
CLIENT_RUNNER=$PROJECT_ROOT/client/runner.sh
CLIENT_VOLUME=$PROJECT_ROOT/client/volume
HOSTKEYS_ROOT=$VOLUME_ROOT/hostkeys
KEYRING_ROOT=$VOLUME_ROOT/keyring
SHARE_ROOT=$VOLUME_ROOT/share
ED25519_HOST_KEYS=$HOSTKEYS_ROOT/ssh_host_ed25519_key
RSA_HOST_KEYS=$HOSTKEYS_ROOT/ssh_host_rsa_key
SFTP_ROOT=$KEYRING_ROOT/sftp
MAIN_RSA_KEYS=$KEYRING_ROOT/id_rsa

function clean_services {
    # Cleanup local volume and docker data
    rm -f $TESTFILE
    docker-clean -a
    if [ $(whoami) != 'root' ]; then
        sudo rm -rf $VOLUME_ROOT $CLIENT_VOLUME
    else
        rm -rf $VOLUME_ROOT $CLIENT_VOLUME
    fi
}

function start_services {
    # Create SSH keys, testing file, and start docker containers
    mkdir -p {$HOSTKEYS_ROOT,$SHARE_ROOT,$SFTP_ROOT,$CLIENT_VOLUME}
    ssh-keygen -t ed25519 -f $ED25519_HOST_KEYS </dev/null
    ssh-keygen -t rsa -b 4096 -f $RSA_HOST_KEYS </dev/null
    ssh-keygen -t rsa -b 4096 -f $MAIN_RSA_KEYS </dev/null
    cp ${MAIN_RSA_KEYS}.pub $SFTP_ROOT
    cp $MAIN_RSA_KEYS ${MAIN_RSA_KEYS}.pub $CLIENT_VOLUME
    echo 'This is a test!' >$SHARE_ROOT/testing.dat
    cp $CLIENT_RUNNER $CLIENT_VOLUME
    rm -f $MAIN_RSA_KEYS ${MAIN_RSA_KEYS}.pub
    docker-compose up -d
    sleep 10
    docker cp client:/root/testing.dat .
}

function execute_main {
    if [ "$1" == "-v" ]; then
        clean_services
        start_services
        cat $TESTFILE
        clean_services
    elif [ "$1" == "-c" ]; then
        clean_services
    elif [ "$1" == "-s" ]; then
        start_services
    else
        clean_services >/dev/null 2>/dev/null
        start_services >/dev/null 2>/dev/null
        cat $TESTFILE
        clean_services >/dev/null 2>/dev/null
    fi
}

execute_main $1
