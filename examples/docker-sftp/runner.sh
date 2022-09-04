#!/bin/bash

docker-clean -a
docker-compose up -d

## install this .ssh/config to avoid problems
# Host 172.69.0.*
#    StrictHostKeyChecking no
#    UserKnownHostsFile=/dev/null

## this command should grab a file without a problem
# sftp -i volume/keyring/id_rsa testing@172.69.0.2:/share/testing.dat .

########################################################################
## basic usage
# docker run -p 22:22 -d atmoz/sftp foo:pass:::upload
########################################################################

########################################################################
## sharing directory from host
# docker run \
#     -v <host-dir>/upload:/home/foo/upload \
#     -p 2222:22 -d atmoz/sftp \
#     foo:pass:1001
########################################################################
## using docker compose
# sftp:
#     image: atmoz/sftp
#     volumes:
#         - <host-dir>/upload:/home/foo/upload
#     ports:
#         - "2222:22"
#     command: foo:pass:1001
########################################################################

########################################################################
## storing users in config
# docker run \
#     -v <host-dir>/users.conf:/etc/sftp/users.conf:ro \
#     -v mySftpVolume:/home \
#     -p 2222:22 -d atmoz/sftp
#
## foo:123:1001:100
## bar:abc:1002:100
## baz:xyz:1003:100
########################################################################

########################################################################
## encrypted password
# docker run \
#     -v <host-dir>/share:/home/foo/share \
#     -p 2222:22 -d atmoz/sftp \
#     'foo:$1$0G2g0GSt$ewU0t6GXG15.0hWoOX8X9.:e:1001'
########################################################################

########################################################################
## logging using ssh keys
# docker run \
#     -v <host-dir>/id_rsa.pub:/home/foo/.ssh/keys/id_rsa.pub:ro \
#     -v <host-dir>/id_other.pub:/home/foo/.ssh/keys/id_other.pub:ro \
#     -v <host-dir>/share:/home/foo/share \
#     -p 2222:22 -d atmoz/sftp \
#     foo::1001
########################################################################

########################################################################
## providing your own ssh host key (recommended)
# docker run \
#     -v <host-dir>/ssh_host_ed25519_key:/etc/ssh/ssh_host_ed25519_key \
#     -v <host-dir>/ssh_host_rsa_key:/etc/ssh/ssh_host_rsa_key \
#     -v <host-dir>/share:/home/foo/share \
#     -p 2222:22 -d atmoz/sftp \
#     foo::1001
#
## generate keys with these commands
# ssh-keygen -t ed25519 -f ssh_host_ed25519_key < /dev/null
# ssh-keygen -t rsa -b 4096 -f ssh_host_rsa_key < /dev/null
########################################################################
