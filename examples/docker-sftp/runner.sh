#!/bin/bash

# Verify root user
if [ $(whoami) != "root" ]; then
    echo "Please run this script as root!" >&2
    exit 1
fi

# Verify current working directory
if [[ ! -f 'runner.sh' ]] || [[ ! -f 'docker-compose.yml' ]]; then
    echo "Please change into the SFTP docker compose directory!" >&2
    exit 1
fi

# Environment variables
export SFTP_USER="tester"
export SFTP_PASS=$(cat /dev/random | xxd -p | head -c 24)

# Top level variables
PROJECT_ROOT=$(readlink -f .)
CLIENT_ROOT=$PROJECT_ROOT/client
CLIENT_RUNNER=$CLIENT_ROOT/runner.sh
CLIENT_VOLUME=$CLIENT_ROOT/volume
SFTP_VOLUME=$PROJECT_ROOT/volume

# Client shared variables
CLIENT_SHARE=$CLIENT_VOLUME/share
CLIENT_TESTFILE=$CLIENT_SHARE/testing_results.dat

# SFTP hostkey variables
SFTP_HOSTKEYS=$SFTP_VOLUME/hostkeys
SFTP_RSA_HOSTKEYS=$SFTP_HOSTKEYS/ssh_host_rsa_key
SFTP_DSA_HOSTKEYS=$SFTP_HOSTKEYS/ssh_host_dsa_key
SFTP_ECDSA_HOSTKEYS=$SFTP_HOSTKEYS/ssh_host_ecdsa_key
SFTP_ED25519_HOSTKEYS=$SFTP_HOSTKEYS/ssh_host_ed25519_key

# SFTP keyring variables
SFTP_KEYRING_ROOT=$SFTP_VOLUME/keyring
SFTP_KEYRING=$SFTP_KEYRING_ROOT/sftp
SFTP_RSA_KEYS=$SFTP_KEYRING_ROOT/id_rsa

# SFTP shared variables
SFTP_SHARE=$SFTP_VOLUME/share
SFTP_TESTFILE=$SFTP_SHARE/testing.dat

function cleanup_environment {
    # Cleanup the local filesystem
    echo "Cleaning up local volume docker data"

    # Wipe local filesystem volumes
    rm -rf $SFTP_VOLUME $CLIENT_VOLUME
}

function initialize_environment {
    # Initialize the local filesystem
    echo "Initializing the local filesystem"

    # Create local filesystem volumes
    mkdir -p {$CLIENT_SHARE,$SFTP_HOSTKEYS,$SFTP_KEYRING,$SFTP_SHARE}

    # Generate SFTP hostkeys
    ssh-keygen -N '' -t rsa -b 4096 -f $SFTP_RSA_HOSTKEYS </dev/null
    ssh-keygen -N '' -t dsa -f $SFTP_DSA_HOSTKEYS </dev/null
    ssh-keygen -N '' -t ecdsa -b 521 -f $SFTP_ECDSA_HOSTKEYS </dev/null
    ssh-keygen -N '' -t ed25519 -f $SFTP_ED25519_HOSTKEYS </dev/null

    # Generate RSA keypair, copy public key to keyring
    ssh-keygen -t rsa -b 4096 -f $SFTP_RSA_KEYS </dev/null
    cp ${SFTP_RSA_KEYS}.pub $SFTP_KEYRING

    # Copy client runner script and RSA keypair into client volume
    cp $CLIENT_RUNNER $CLIENT_VOLUME
    mv $SFTP_RSA_KEYS ${SFTP_RSA_KEYS}.pub $CLIENT_VOLUME

    # Generate a testfile for SFTP container
    echo 'This is a test!' >$SFTP_TESTFILE
}

function execute_start {
    echo "Executing start commands"
    cleanup_environment
    initialize_environment
    docker-compose up -d
}

function execute_stop {
    echo "Executing stop commands"
    docker-clean -a
    cleanup_environment
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
        cleanup_environment
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
                sleep 1 && cat $CLIENT_TESTFILE
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
            sleep 1 && cat $CLIENT_TESTFILE
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
