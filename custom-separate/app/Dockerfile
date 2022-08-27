FROM httpd:2.4

RUN apt-get update -y
#RUN apt-get install -y default-mysql-client  # temporary
RUN apt-get install -y git php php-mysqli php-gd libapache2-mod-php

RUN rm -f /usr/local/apache2/htdocs/*
RUN git clone https://github.com/digininja/DVWA.git /usr/local/apache2/htdocs
