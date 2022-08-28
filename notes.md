
# Notes

A notebook for documenting the process of setting up the DVWA application in a Docker container.

---

## References

+ [Official Github Link](https://github.com/digininja/DVWA)

+ [YouTube Installation Video](https://www.youtube.com/watch?v=cak2lQvBRAo)

+ [Official MySQL Docker Link](https://hub.docker.com/_/mysql)

+ [Official Apache Docker Link](https://hub.docker.com/_/httpd)

+ [Preconfigured DVWA Container Link](https://cybr.com/cybersecurity-fundamentals-archives/how-to-set-up-the-dvwa-on-kali-with-docker/)

+ [Dockerized PHP, MySQL, and Apache](https://www.section.io/engineering-education/dockerized-php-apache-and-mysql-container-development-environment/)

---

## Planning

I know I need to download or clone the DVWA source code from github.

The DVWA application depends on an Apache web server, a MySQL database, and utilizes PHP.

I am thinking that Apache and MySQL should be setup on separate containers as it may be easier for containerization.  The alternative is having a container with a full operating system and then configuring the components separately which will likely lead to unnecessary bloat.

---

## Progress Notes

After playing with a custom setup for a while I decided to try the preconfigured DVWA container to see if it makes more sense.

The preconfigured setup works out of the box for the most part but I would prefer to keep this entire application custom just to ensure that it is authentic.  I did find a useful blog online that describes an example of a PHP application that utilizes Apache and MySQL.  I want to check this out just to get some new angles on my own similar issue.  I will be keeping track of the notes for this example [here](./solutions/guided/separate/notes.md)

I played with various techniques to achieve what I needed done which was an Apache service supported by PHP with a configurable version and a MySQL server or local service.  I found a lot of annoyances that would likely cause more time to solve than it would be worth for usability of the project.

The preconfigured DVWA docker container is the easiest and most compatible solution in my opinion.

---
