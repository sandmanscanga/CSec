FROM php:7.2-apache

RUN docker-php-ext-install mysqli
RUN docker-php-ext-enable mysqli

RUN apt-get update -y
RUN apt-get install -y git php-gd default-mysql-client

RUN rm -f /var/www/html/*
RUN git clone https://github.com/digininja/DVWA.git /var/www/html

WORKDIR /var/www/html

RUN mv config/config.inc.php.dist config/config.inc.php

COPY bashrc /root/.bashrc
