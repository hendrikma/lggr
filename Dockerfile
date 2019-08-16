FROM debian:stable
#For use with docker on ARM (like Raspberry Pi)
#FROM arm32v7/debian:stable

RUN apt-get update -y
RUN apt-get install -y cron locales nano default-mysql-server libdbd-mysql apache2 php7.3 php-mysql php-redis redis-server syslog-ng git wget
RUN a2enmod rewrite expires headers

RUN rm -rf /var/www/html && git clone https://github.com/burnbabyburn/lggr.git /var/www/html

WORKDIR /var/www/html
RUN wget https://lggr.io/wp-content/uploads/2015/06/lggr_contrib.tar.gz
RUN tar xvfz lggr_contrib.tar.gz && rm lggr_contrib.tar*
RUN chown www-data:www-data /var/www/html/cache/
RUN mv ./install.sh /install.sh && chmod 755 /install.sh

EXPOSE 80 514/udp

RUN service apache2 restart && service mysql restart && service redis-server restart && service syslog-ng restart && service cron restart

CMD ["/bin/bash", "/install.sh"]
