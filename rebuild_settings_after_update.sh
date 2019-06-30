#!/bin/bash

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

USER_LOGGER="logger2"
PW_LOGGER="MyLoggerPW"

USER_LOGVIEWER="logviewer2"
PW_LOGVIEWER="MyLogViewerPW"

USER_ADMINLOGGER="loggeradmin2"
PW_LOGGERADMIN="MyloggeradminPW"

LOGGER_LOCALE="en_US"

sed -i "s|PW_LOGVIEWER|$PW_LOGVIEWER|" $DIR/inc/config_class.php
sed -i "s|DB_NAME|$DB_NAME|g" $DIR/inc/config_class.php
sed -i "s|USER_LOGVIEWER|$USER_LOGVIEWER|g" $DIR/inc/config_class.php

# Set your preferred language en_US, de_DE, or pt_BR
sed -i "s|en_US|$LOGGER_LOCALE|" $DIR/inc/config_class.php
sed -i "s|lang="en"|$LOGGER_LOCALE|" $DIR/inc/config_class.php
#--------------------------------------------------------------------------------------------
sed -i "s|PW_LOGGERADMIN|$PW_LOGGERADMIN|" $DIR/inc/adminconfig_class.php
sed -i "s|DB_NAME|$DB_NAME|" $DIR/inc/adminconfig_class.php
sed -i "s|USER_ADMINLOGGER|$USER_ADMINLOGGER|" $DIR/inc/adminconfig_class.php

