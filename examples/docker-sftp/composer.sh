#!/bin/bash

# Verify root user
if [ $(whoami) != "root" ]; then
    echo "Please run this script as root!" >&2
    exit 1
fi

# Verify current working directory
if [ ! -f "composer.sh" ] || [ ! -f "docker-compose.yml" ]; then
    echo "Please change into the SFTP docker compose directory!" >&2
    exit 1
fi

# Environment variables
export SFTP_USER=tester
export SFTP_PASS=$(head -c 16 /dev/random | xxd -p)

# Top level variables
PROJECT_ROOT=$(pwd -P)
INFILE=testing.dat
OUTFILE=testing_results.dat

# Volume variables
ROOT_VOLUME=$PROJECT_ROOT/volume
SFTP_VOLUME=$ROOT_VOLUME/sftp
CLIENT_VOLUME=$ROOT_VOLUME/client
KEYRING_VOLUME=$ROOT_VOLUME/keyring

# SFTP variables
SFTP_KEYRING=$SFTP_VOLUME/keyring
SFTP_SHARE=$SFTP_VOLUME/share
SFTP_TESTFILE=$SFTP_SHARE/$INFILE
SFTP_HOSTKEYS=$SFTP_VOLUME/hostkeys

# SFTP hostkey variables
SFTP_RSA_HOSTKEYS=$SFTP_HOSTKEYS/ssh_host_rsa_key
SFTP_DSA_HOSTKEYS=$SFTP_HOSTKEYS/ssh_host_dsa_key
SFTP_ECDSA_HOSTKEYS=$SFTP_HOSTKEYS/ssh_host_ecdsa_key
SFTP_ED25519_HOSTKEYS=$SFTP_HOSTKEYS/ssh_host_ed25519_key

# Client variables
CLIENT_KEYRING=$CLIENT_VOLUME/keyring
CLIENT_SHARE=$CLIENT_VOLUME/share
CLIENT_TESTFILE=$CLIENT_SHARE/$OUTFILE
CLIENT_SCRIPT=$CLIENT_VOLUME/start.sh

function create_client_script {
cat << EOF > $CLIENT_SCRIPT
apk add --update --no-cache openssh
mkdir -p /root/.ssh
cp /root/keyring/* /root/.ssh
rm -f /root/keyring/*
chown root:root -R /root/.ssh
chmod 600 /root/.ssh/id_rsa
ssh-keyscan -t rsa sftp >/root/.ssh/known_hosts
sftp tester@sftp:/share/$INFILE /root/$INFILE
cp /root/$INFILE /root/share/$OUTFILE
rm -f $INFILE
tail -f /dev/null
EOF
}

function initialize_environment {
    mkdir -p $KEYRING_VOLUME
    mkdir -p {$SFTP_KEYRING,$SFTP_SHARE,$SFTP_HOSTKEYS}
    mkdir -p {$CLIENT_KEYRING,$CLIENT_SHARE}

    ssh-keygen -N "" -t rsa -b 4096 -f $SFTP_RSA_HOSTKEYS </dev/null
    ssh-keygen -N "" -t dsa -f $SFTP_DSA_HOSTKEYS </dev/null
    ssh-keygen -N "" -t ecdsa -b 521 -f $SFTP_ECDSA_HOSTKEYS </dev/null
    ssh-keygen -N "" -t ed25519 -f $SFTP_ED25519_HOSTKEYS </dev/null

    ssh-keygen -t rsa -b 4096 -f $KEYRING_VOLUME/id_rsa </dev/null
    cp $KEYRING_VOLUME/*.pub $SFTP_KEYRING
    cp $KEYRING_VOLUME/* $CLIENT_KEYRING
    rm -rf $KEYRING_VOLUME

    echo "This test happened at $(date)" >$SFTP_TESTFILE
    create_client_script
}

function execute_start {
    rm -rf $ROOT_VOLUME
    initialize_environment
    docker-compose up -d
}

function execute_stop {
    docker-clean -a
    rm -rf $ROOT_VOLUME
}

function run_command {
    if [ "$1" == "start" ]; then
        execute_start
    elif [ "$1" == "stop" ]; then
        execute_stop
    elif [ "$1" == "init" ]; then
        initialize_environment
    elif [ "$1" == "up" ]; then
        docker-compose up -d
    elif [ "$1" == "down" ]; then
        docker-clean -a
    elif [ "$1" == "clean" ]; then
        rm -rf $ROOT_VOLUME
    else
        echo "Please enter a valid command!" >&2
        echo "Run '$0 help' for usage info..."
        exit 1
    fi
}

function execute_main {
    if [[ "$1" == "-s" ]] || [[ "$2" == "-s" ]]; then
        # silent flag is set somewhere
        if [ "$1" == "-s" ]; then
            # silent flag is set on first argument
            if [ -z "$2" ]; then
                # second command is empty
                execute_start >/dev/null 2>/dev/null
                sleep 3 && cat $CLIENT_TESTFILE
                execute_stop >/dev/null 2>/dev/null
            else
                run_command $2 >/dev/null 2>/dev/null
            fi
        else
            # silent flag is set on second argument
            run_command $1 >/dev/null 2>/dev/null
        fi
    else
        # silent flag is not set
        if [ -z "$1" ]; then
            # first command is empty
            execute_start
            sleep 3 && cat $CLIENT_TESTFILE
            execute_stop
        else
            # first command is not empty
            run_command $1
        fi
    fi
}

function display_usage {
    echo "Usage $0:"
    echo -e "\n\n$0 <no_arguments>"
    echo "    -> Execute full test with verbosity"
    echo -e "\n$0 <optional_command> -s"
    echo "    -> Execute a command silently"
    echo -e "\n$0 start"
    echo "    -> Initializes and starts the docker composed environment"
    echo -e "\n$0 stop"
    echo "    -> Stops and cleans up the docker composed environment"
    echo -e "\n$0 init"
    echo "    -> Initializes filesystem without starting containers"
    echo -e "\n$0 up"
    echo "    -> Starts docker containers without initializing"
    echo -e "\n$0 test"
    echo "    -> Runs the main test case"
    echo -e "\n$0 down"
    echo "    -> Stops docker containers without cleaning up filesystem"
    echo -e "\n$0 clean"
    echo "    -> Cleans up the filesystem"
}

function execute_help {
    if [[ "$1" == "help" ]]; then
        display_usage && exit
    elif [[ "$1" == "-h" ]]; then
        display_usage && exit
    elif [[ "$1" == "--help" ]]; then
        display_usage && exit
    fi
}

function execute_test {
    if [ "$1" == "test" ]; then
        cat $CLIENT_TESTFILE; exit
    elif [ "$1" == "-t" ]; then
        cat $CLIENT_TESTFILE; exit
    elif [ "$1" == "--test" ]; then
        cat $CLIENT_TESTFILE; exit
    fi
}

function execute_runner {
    execute_test $1
    execute_help $1
    execute_main $1 $2
}

execute_runner $1 $2
