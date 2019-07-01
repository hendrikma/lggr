#!/bin/bash
# Install Script
#Todo: testen, remote sql noch nicht ganz fertig (mysql commands gehen alle noch auf lokal

export DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

export DB_NAME="logger"
export DB_IP="localhost"

# Comments the BasicAuth part from checkSecurity() function in ./inc/lggr_class
# Enabling this removes BasicAuth requirement
export ENABLE_BASICAUTH=true
export ENABLE_BASICAUTH_FILE=/var/www/webuser

#verbose - more output
export ENABLE_VERBOSE=false

#If set to true, script will drop existing user and database
export ENABLE_DROPDB=false

export USER_LOGGER="logger"
export PW_LOGGER="MyLoggerPW"

export USER_LOGVIEWER="logviewer"
export PW_LOGVIEWER="MyLogViewerPW"

export USER_ADMINLOGGER="loggeradmin"
export PW_ADMINLOGGER="MyloggeradminPW"

export LOGGER_LOCALE="de_DE"

#Lookup your timezone here: https://www.php.net/manual/en/timezones.php
export PHP_TIMEZONE=Europe/Berlin
#PHP_TIMEZONE=America/New_York

#export SYSLOG_SERVER="192.168.1.10"
#export SYSLOG_CONF=/etc/syslog-ng/conf.d/99-logger.conf
export SYSLOG_SERVER="0.0.0.0"
export SYSLOG_CONF=/etc/syslog-ng/syslog-ng.conf
#--------------------------------------------------------------------------------------------
#
# Configure Settings
#
#--------------------------------------------------------------------------------------------
sed -i "s|DB_NAME|$DB_NAME|g" $DIR/doc/db.sql

sed -i "s|DB_NAME|$DB_NAME|g" $DIR/doc/user.sql
sed -i "s|DB_IP|$DB_IP|" $DIR/doc/user.sql

sed -i "s|USER_LOGGER|$USER_LOGGER|" $DIR/doc/user.sql
sed -i "s|USER_LOGVIEWER|$USER_LOGVIEWER|" $DIR/doc/user.sql
sed -i "s|USER_ADMINLOGGER|$USER_ADMINLOGGER|" $DIR/doc/user.sql

sed -i "s|PW_LOGGER|$PW_LOGGER|" $DIR/doc/user.sql
sed -i "s|PW_LOGVIEWER|$PW_LOGVIEWER|" $DIR/doc/user.sql
sed -i "s|PW_LOGGERADMIN|$PW_ADMINLOGGER|" $DIR/doc/user.sql

sed -i "s|PW_LOGVIEWER|$PW_LOGVIEWER|" $DIR/inc/config_class.php
sed -i "s|DB_NAME|$DB_NAME|g" $DIR/inc/config_class.php
sed -i "s|USER_LOGVIEWER|$USER_LOGVIEWER|g" $DIR/inc/config_class.php

# Set your preferred language en_US, de_DE, or pt_BR
sed -i "s|en_US|$LOGGER_LOCALE|" $DIR/inc/config_class.php

sed -i "s|PW_LOGGERADMIN|$PW_ADMINLOGGER|" $DIR/inc/adminconfig_class.php
sed -i "s|DB_NAME|$DB_NAME|" $DIR/inc/adminconfig_class.php
sed -i "s|USER_ADMINLOGGER|$USER_ADMINLOGGER|" $DIR/inc/adminconfig_class.php
#--------------------------------------------------------------------------------------------
if [ $ENABLE_BASICAUTH = false ]
then
  sed -i '52,54 s/^/#/' $DIR/inc/lggr_class.php
else
  sed -i '52,54 s/^#//' $DIR/inc/lggr_class.php
  sed "s|AuthUserFile.*|AuthUserFile    $ENABLE_BASICAUTH_FILE"
  htpasswd -c "$ENABLE_BASICAUTH_FILE" "$USER_LOGGER"
fi
#--------------------------------------------------------------------------------------------
if ! grep -q no-caps "/etc/default/syslog-ng" ;
then
  echo 'SYSLOGNG_OPTS="-–no-caps"' >> /etc/default/syslog-ng
fi
#--------------------------------------------------------------------------------------------
function init_mysql
{

if ! systemctl is-active mysql;
then
	systemctl start mysql
fi

if ! mysql -e "use $DB_NAME";
	then
	mysql "$DB_NAME" < "$DIR"/doc/db.sql
	else
	if [ ENABLE_DROPDB = true ] ;
	 then
		mysql -e "DROP DATABASE $DB_NAME"
		mysql < "$DIR"/doc/db.sql
	fi
fi
	
if [ ENABLE_DROPDB = true ] ;
then 
	mysql -e "DROP USER IF EXISTS $USER_LOGGER"@$DB_IP
	mysql -e "DROP USER IF EXISTS $USER_ADMINLOGGER"@$DB_IP
	mysql -e "DROP USER IF EXISTS $USER_LOGVIEWER"@$DB_IP
fi
	
}
#--------------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------------
#Check if Packagename e.g. mysql (param1) installed
function PKG_OK { dpkg-query -W --showformat='${Status}\n' "$1"|grep "install ok installed" }

#string to concate missing packages to
export PKG_INSTALL=" "
#--------------------------------------------------------------------------------------------
function check_requirements
{
if [ ! "$(PKG_OK "apache2")" ]
then
  PKG_INSTALL="${PKG_INSTALL} apache2"
fi

a2enmod headers expires 
a2enmod auth_basic

# Restart Apache after enabling modules
systemctl restart apache2

if [ ! "$(PKG_OK "php")" ]
then
  PKG_INSTALL="${PKG_INSTALL} php php-mysql php-redis"
fi

string=$(php -r "echo PHP_VERSION;")
#min PHP 5.4 needed
php_version="${string:0:3}"
sed  -i "s|date.timezone =.*|date.timezone = Europe/Berlin" /etc/php/$php_version/cli/php.ini

if [ ! "$(PKG_OK "redis-server")" ]
then
  PKG_INSTALL="${PKG_INSTALL} redis-server"
fi
}
#--------------------------------------------------------------------------------------------
if [ ! -f $SYSLOG_CONF ] ;
then
	cp "$DIR"/doc/syslog.conf "$SYSLOG_CONF"

	sed -i "s|SYSLOG_SERVER|$SYSLOG_SERVER" $SYSLOG_CONF
	sed -i "s|USER_LOGGER|$USER_LOGGER" $SYSLOG_CONF
	sed -i "s|PW_LOGGER|$PW_LOGGER" $SYSLOG_CONF
	sed -i "s|DB_NAME|$DB_NAME" $SYSLOG_CONF
	sed -i "s|DB_IP|$DB_IP" $SYSLOG_CONF
	sed -i "s|PHP_TIMEZONE|$PHP_TIMEZONE" $SYSLOG_CONF
else
	echo "Skipping syslog configuration. $SYSLOG_CONF already exists"
fi
#--------------------------------------------------------------------------------------------

#systemctl start apache2.service
#sleep 60