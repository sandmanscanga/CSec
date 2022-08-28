FROM php:5.6-apache

WORKDIR /var/www/html

RUN rm -f *

COPY index.php .

RUN docker-php-ext-install mysqli
RUN docker-php-ext-enable mysqli

RUN apt-get update -y
RUN apt-get upgrade -y
