FROM httpd:2.4

RUN apt-get update -y

#RUN ln -fs /usr/share/zoneinfo/America/New_York /etc/localtime
#RUN apt-get install -y tzdata
#RUN dpkg-reconfigure --frontend noninteractive tzdata

COPY bashrc /root/.bashrc

#RUN apt-get install -y git apache2 php php-mysqli php-gd libapache2-mod-php
RUN apt-get install -y git php php-mysqli php-gd libapache2-mod-php

COPY php.ini /etc/php/7.4/apache2/php.ini

WORKDIR /usr/local/apache2/htdocs

RUN rm -f *
RUN git clone https://github.com/digininja/DVWA.git .

COPY config.inc.php.dist config/config.inc.php.dist

RUN mv config/config.inc.php.dist config/config.inc.php
RUN chmod 777 hackable/uploads
RUN chmod 777 external/phpids/0.6/lib/IDS/tmp/phpids_log.txt

#RUN service apache2 restart

#ENTRYPOINT /usr/bin/sleep 604800
