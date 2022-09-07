
# SFTP Docker Container

This example should give insight on how to setup a docker container with SFTP so that sensitive files can be placed here and only accessed via trusted RSA keys.  This will introduce another layer of security to avoid any plain text passwords being part of the project repository or any leaks during installation.

---

## References

+ [SFTP Docker Example](https://entermediadb.org/knowledge/10/sftp.html)

+ [Isolated SFTP Docker Container](https://www.net7.be/blog/article/isolated_sftp_docker.html)

+ [Using SFTP & Docker Compose](http://www.inanzzz.com/index.php/post/6fa7/creating-a-ssh-and-sftp-server-with-docker-compose)

+ [Official Docker Image](https://hub.docker.com/r/atmoz/sftp)

---

## Notes

Install this .ssh/config to avoid problems:

    Host 172.69.0.*
        StrictHostKeyChecking no
        UserKnownHostsFile=/dev/null

This command should grab a file without a problem:

```bash
sftp -i volume/keyring/id_rsa testing@172.69.0.2:/share/testing.dat .
```

Basic usage:

```bash
docker run -p 22:22 -d atmoz/sftp foo:pass:::upload
```

Sharing directory from host:

```bash
docker run \
    -v <host-dir>/upload:/home/foo/upload \
    -p 2222:22 -d atmoz/sftp \
    foo:pass:1001
```

Using docker compose:

```yaml
sftp:
  image: atmoz/sftp
  volumes:
    - <host-dir>/upload:/home/foo/upload
  ports:
    - 2222:22
  command: foo:pass:1001
```

Storing users in config:

```bash
docker run \
    -v <host-dir>/users.conf:/etc/sftp/users.conf:ro \
    -v mySftpVolume:/home \
    -p 2222:22 -d atmoz/sftp
## foo:123:1001:100
## bar:abc:1002:100
## baz:xyz:1003:100
```

Encrypted password:

```bash
docker run \
    -v <host-dir>/share:/home/foo/share \
    -p 2222:22 -d atmoz/sftp \
    'foo:$1$0G2g0GSt$ewU0t6GXG15.0hWoOX8X9.:e:1001'
```

Logging using ssh keys:

```bash
docker run \
    -v <host-dir>/id_rsa.pub:/home/foo/.ssh/keys/id_rsa.pub:ro \
    -v <host-dir>/id_other.pub:/home/foo/.ssh/keys/id_other.pub:ro \
    -v <host-dir>/share:/home/foo/share \
    -p 2222:22 -d atmoz/sftp \
    foo::1001
```

Providing your own ssh host key (recommended):

```bash
docker run \
    -v <host-dir>/ssh_host_ed25519_key:/etc/ssh/ssh_host_ed25519_key \
    -v <host-dir>/ssh_host_rsa_key:/etc/ssh/ssh_host_rsa_key \
    -v <host-dir>/share:/home/foo/share \
    -p 2222:22 -d atmoz/sftp \
    foo::1001
```

Generate keys with these commands:

```bash
ssh-keygen -t ed25519 -f ssh_host_ed25519_key < /dev/null
ssh-keygen -t rsa -b 4096 -f ssh_host_rsa_key < /dev/null
```
