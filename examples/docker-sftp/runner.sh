#!/bin/bash

# Verify current working directory
if [[ ! -f runner.sh ]] || [[ ! -f docker-compose.yml ]]; then
    echo "Please change into the SFTP docker compose directory!" >&2
    exit 1
fi

# Set environment variables
export SFTP_ADDR="172.69.0.1"
export SFTP_USER="tester"
export SFTP_PASS=$(cat /dev/random | xxd -p | head -c 24)

## Set top level variables
PROJECT_ROOT=$(readlink -f .)
SSH_KNOWN_HOSTS=$HOME/.ssh/known_hosts
VOLUME_ROOT=$PROJECT_ROOT/volume

# Set SSH hostkey paths
HOSTKEYS_ROOT=$VOLUME_ROOT/hostkeys
ED25519_KEYS_PATH=$HOSTKEYS_ROOT/ssh_host_ed25519_key
RSA_KEYS_PATH=$HOSTKEYS_ROOT/ssh_host_rsa_key

# Set SSH authentication keyring paths
KEYRING_ROOT=$VOLUME_ROOT/keyring
ID_RSA_KEYS_PATH=$KEYRING_ROOT/id_rsa
LOCAL_RSA_KEYS_PATH=$PROJECT_ROOT/sftp_key

# Set share volume and testfile paths
TESTFILE_NAME=testing.dat
SHARE_ROOT=$VOLUME_ROOT/share
TESTFILE_OUT_PATH=$PROJECT_ROOT/$TESTFILE_NAME
TESTFILE_IN_PATH=$SHARE_ROOT/$TESTFILE_NAME

function clean_services {
    # Cleanup local volume and docker data
    rm -f $LOCAL_RSA_KEYS_PATH
    rm -f $TESTFILE_OUT_PATH
    docker-clean -a
    if [ $(whoami) != 'root' ]; then
        sudo rm -rf $VOLUME_ROOT
    else
        rm -rf $VOLUME_ROOT
    fi
}

function start_services {
    # Create SSH keys, testing file, and start docker containers
    mkdir -p $VOLUME_ROOT/{hostkeys,keyring,share}
    ssh-keygen -t ed25519 -f $ED25519_KEYS_PATH </dev/null
    ssh-keygen -t rsa -b 4096 -f $RSA_KEYS_PATH </dev/null
    ssh-keygen -t rsa -b 4096 -f $ID_RSA_KEYS_PATH </dev/null
    echo 'This is a test!' >$TESTFILE_IN_PATH
    cp $ID_RSA_KEYS_PATH $LOCAL_RSA_KEYS_PATH
    chmod 600 $LOCAL_RSA_KEYS_PATH
    docker-compose up -d
    sleep 3
}

function get_sftp_testfile {
    # Retrieve the testfile via SFTP
    cp $SSH_KNOWN_HOSTS ${SSH_KNOWN_HOSTS}.tmp
    ssh-keyscan -t rsa $SFTP_ADDR >$SSH_KNOWN_HOSTS
    sftp -i $LOCAL_RSA_KEYS_PATH \
        ${SFTP_USER}@${SFTP_ADDR}:/share/$TESTFILE_NAME \
        $TESTFILE_OUT_PATH
    mv ${SSH_KNOWN_HOSTS}.tmp $SSH_KNOWN_HOSTS
}

function execute_main {
    if [ "$1" == "-v" ]; then
        clean_services
        start_services
        get_sftp_testfile
        cat $TESTFILE_OUT_PATH
        clean_services
    else
        clean_services >/dev/null 2>/dev/null
        start_services >/dev/null 2>/dev/null
        get_sftp_testfile >/dev/null 2>/dev/null
        cat $TESTFILE_OUT_PATH 2>/dev/null
        clean_services >/dev/null 2>/dev/null
    fi
}

execute_main $1
