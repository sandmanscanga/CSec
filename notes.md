
# Notes

A notebook for documenting the process of setting up the DVWA application in a Docker container.

---

## References

+ [Official Github Link](https://github.com/digininja/DVWA)

+ [YouTube Installation Video](https://www.youtube.com/watch?v=cak2lQvBRAo)

+ [Official MySQL Docker Link](https://hub.docker.com/_/mysql)

+ [Official Apache Docker Link](https://hub.docker.com/_/httpd)

+ [Preconfigured DVWA Container Link](https://cybr.com/cybersecurity-fundamentals-archives/how-to-set-up-the-dvwa-on-kali-with-docker/)

---

## Planning

I know I need to download or clone the DVWA source code from github.

The DVWA application depends on an Apache web server, a MySQL database, and utilizes PHP.

I am thinking that Apache and MySQL should be setup on separate containers as it may be easier for containerization.  The alternative is having a container with a full operating system and then configuring the components separately which will likely lead to unnecessary bloat.

---

## Progress

After playing with a custom setup for a while I decided to try the preconfigured DVWA container to see if it makes more sense.

---
