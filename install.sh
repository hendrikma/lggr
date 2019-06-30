#!/bin/bash
# Install Script
#Todo: testen, remote sql noch nicht ganz fertig (mysql commands gehen alle noch auf lokal

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

DB_NAME="pihole-logger"
DB_IP="localhost"

#Lookup your timezone here: https://www.php.net/manual/en/timezones.php
PHP_TIMEZONE=Europe/Berlin
#PHP_TIMEZONE=America/New_York

USER_LOGGER="logger2"
PW_LOGGER="MyLoggerPW"

USER_LOGVIEWER="logviewer2"
PW_LOGVIEWER="MyLogViewerPW"

USER_LOGGERADMIN="loggeradmin2"
PW_LOGGERADMIN="MyloggeradminPW"

LOGGER_LOCALE="en_US"

# Comments the BasicAuth part from checkSecurity() function in ./inc/lggr_class
# Enabling this removes BasicAuth requirement
ENABLE_BASICAUTH=enable

#export SYSLOG_SERVER="192.168.1.10"
#export SYSLOG_CONF=/etc/syslog-ng/conf.d/99-logger.conf
SYSLOG_SERVER="0.0.0.0"
SYSLOG_CONF=/etc/syslog-ng/syslog-ng.conf


#--------------------------------------------------------------------------------------------
#Check if Packagename e.g. mysql (param1) installed
function PKG_OK {
dpkg-query -W --showformat='${Status}\n' "$1"|grep "install ok installed"
}
#string to concate missing packages to
PKG_INSTALL=""
#--------------------------------------------------------------------------------------------
if [ ! "$(PKG_OK "apache2")" ]
then
  $PKG_INSTALL="${PKG_INSTALL}apache2"
fi
if [ ! "$(PKG_OK "php")" ]
then
  $PKG_INSTALL="${PKG_INSTALL}php php-mysql"
fi
string=$(php -r "echo PHP_VERSION;")
php_version="${string:0:3}"
sed  -i "s|date.timezone =.*|date.timezone = Europe/Berlin" /etc/php/$php_version/cli/php.ini

#--------------------------------------------------------------------------------------------
sed -i "s|DB_NAME|$DB_NAME|g" $DIR/doc/db.sql
sed -i "s|DB_NAME|$DB_NAME|g" $DIR/doc/user.sql
#--------------------------------------------------------------------------------------------
sed -i "s|USER_LOGGER|$USER_LOGGER|" $DIR/doc/user.sql
sed -i "s|USER_LOGVIEWER|$USER_LOGVIEWER|" $DIR/doc/user.sql
sed -i "s|USER_LOGGERADMIN|$USER_LOGGERADMIN|" $DIR/doc/user.sql
sed -i "s|DB_IP|$DB_IP|" $DIR/doc/user.sql

sed -i "s|PW_LOGGER|$PW_LOGGER|" $DIR/doc/user.sql
sed -i "s|PW_LOGVIEWER|$PW_LOGVIEWER|" $DIR/doc/user.sql
sed -i "s|PW_LOGGERADMIN|$PW_LOGGERADMIN|" $DIR/doc/user.sql
#--------------------------------------------------------------------------------------------
sed -i "s|PW_LOGVIEWER|$PW_LOGVIEWER|" $DIR/inc/config_class.php
sed -i "s|DB_NAME|$DB_NAME|g" $DIR/inc/config_class.php
sed -i "s|USER_LOGVIEWER|$USER_LOGVIEWER|g" $DIR/inc/config_class.php

# Set your preferred language en_US, de_DE, or pt_BR
sed -i "s|en_US|$LOGGER_LOCALE|" $DIR/inc/config_class.php
#--------------------------------------------------------------------------------------------
sed -i "s|PW_LOGGERADMIN|$PW_LOGGERADMIN|" $DIR/inc/adminconfig_class.php
sed -i "s|DB_NAME|$DB_NAME|" $DIR/inc/adminconfig_class.php
sed -i "s|USER_LOGGERADMIN|$USER_LOGGERADMIN|" $DIR/inc/adminconfig_class.php

#--------------------------------------------------------------------------------------------
if [ $ENABLE_BASICAUTH = false ]
then
  sed -i '52,54 s/^/#/' $DIR/inc/lggr_class.php
fi
#--------------------------------------------------------------------------------------------

if [ systemctl is-active mysql ] ; then 
  mysql $DB_NAME < $DIR/doc/db.sql
  mysql $DB_NAME < $DIR/doc/user.sql
else
  systemctl start mysql.service
  sleep 15
  mysql $DB_NAME < $DIR/doc/db.sql
  mysql $DB_NAME < $DIR/doc/user.sql  
fi

if [ -f /etc/debian_verison]
then
  echo 'SYSLOGNG_OPTS="-–no-caps"' >> /etc/default/syslog-ng
fi

# Install syslog-ng config
# Added default Value (PID=-9999) for PID as it was sometimes empty for me
printf '@version: 3.19

options { keep-hostname(yes); chain_hostnames(off); use_dns(no); use_fqdn(no);
          owner("root"); group("adm"); perm(0640); stats_freq(0); keep_timestamp(yes);
          bad_hostname("^gconfd$");
};

source s_local {
  system();
  internal();
};

# RFC3164 BSD-syslog
# https://www.syslog-ng.com/technical-documents/doc/syslog-ng-open-source-edition/3.22/administration-guide/19#TOPIC-1209138
# I am not able to escape the strings correctly => so changed to sed
source s_net {
        network(
                transport("tcp")
				# default 0.0.0.0
                ip(SYSLOG_SERVER)
				# default tcp port
                port(601)

                max-connections(5)
                log-iw-size(2000)
# tls
#               tls(peer-verify("required-trusted")
#               key-file("etc/syslog-ng/syslog-ng.key")
#               cert-file("etc/syslog-ng/syslog-ng.crt")
        );
		network(
        ip(SYSLOG_SERVER)
        transport("udp")
		# default tcp port
        port(601)
		);
};

destination d_newmysql {
    sql(
    flags(dont-create-tables,explicit-commits)
    session-statements("SET NAMES utf8")
    batch_lines(10)
    batch_timeout(5000)
    local_time_zone("PHP_TIMEZONE")
    type(mysql)
    username("USER_LOGGER")
    password("PW_LOGGER")
    database("DB_NAME")
    host("DB_IP")
    table("newlogs")
    columns("date", "facility", "level", "host", "program", "pid", "message")
    values("${R_YEAR}-${R_MONTH}-${R_DAY} ${R_HOUR}:${R_MIN}:${R_SEC}", "$FACILITY", "$LEVEL", "$HOST", "$PROGRAM", "${PID:-9999}", "$MSGONLY")
    indexes()
    );
};

#Filter example
#Rule removes annyoing seafile message
filter annyoingmessages {
match("size-sched.c(96): Repo size compute queue size is 0");

};


log {
    source(s_net);
    source(s_local);
	destination(d_newmysql);
};
' > $SYSLOG_CONF

sed -i "s|SYSLOG_SERVER|$SYSLOG_SERVER" $SYSLOG_CONF
sed -i "s|USER_LOGGER|$USER_LOGGER" $SYSLOG_CONF
sed -i "s|PW_LOGGER|$PW_LOGGER" $SYSLOG_CONF
sed -i "s|DB_NAME|$DB_NAME" $SYSLOG_CONF
sed -i "s|DB_IP|$DB_IP" $SYSLOG_CONF
sed -i "s|PHP_TIMEZONE|$PHP_TIMEZONE" $SYSLOG_CONF


#systemctl start apache2.service
#sleep 60




