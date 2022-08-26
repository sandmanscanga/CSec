
# Prologue

I am not entirely sure how to approach the creation of this project but I do have a pretty good idea of how the end result should look.

The first step should be to spin up a docker container for a vulnerablity.  I am thinking something like DVWA to start with just because it has some low hanging vulnerabilities and a login portal right out of the box.  This will allow me to get a solid foundation for the *vulnerability* side of the project and provide some basic target practice for the *exploitation* side of the project.

Keeping security in mind, credential management is going to be a huge aspect in the project.  Nothing will be hardcoded which will likely lead to a larger amount of prerequisite installation understanding.  Some key points on this note might include:

+ A strong understanding of scope of the host machine versus the containers.

+ A strong understanding of GPG key creation and management for generating secure encryption subkeys as well as importing and exporting subkeys from the host machine to the appropriate containers.

+ A well known common path on the filesystem for accessing any persistent installation configurations, or possibly using environment variables.

+ A clear understanding of the various stages to go from cloning the project to watching it work at full capacity.

+ A uniform routine for each stage of the project that follows a standard so it can scale efficiently and easily.

+ Clear and concise documentation for the early setup that will likely require manual configuration rather than automation.
