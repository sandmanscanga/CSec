
# SFTP - Docker - Promptless

This composed docker environment creates an SFTP server container along with an SFTP client container without any user intervention.  This includes creating a unique RSA authentication keypair that is tailored specifically to the SFTP server without leaking credentials.  This situation allows files to be transferred securely even during the docker build phase as well as the git repo to avoid any sensitivity leaks.  This creates a secure relationship between the SFTP server and each client (which can be considered isolated [meaning each client is unique and compromising any would not result in a central point of failure])...

This specific scenario is automated with docker for demonstrative purposes but will be integrated into the main project eventually.

---

## Execution Notes

The included bash script is required in order to initialize the filesystem's dependencies for docker to work.  This is currently a limitation to cross-platform compatibility but I plan to solve this in future updates.  In order to run this you will need a Linux filesystem along with the packages **docker** & **docker-compose**, installed in order to run the program.  Assuming the prerequisites are met, the instructions are simpe...

Ensure you are in the directory with the `docker-compose.yml` file.  Then just utilize the `runner.sh` script along with keeping permissions in mind.

For additional information on how to use the **runner** script, run the command `sudo bash runner.sh help`.

---
