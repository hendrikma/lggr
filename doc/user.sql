# create the following three mysql users:

# used by syslog-ng for inserting new data, referenced in /etc/syslog-ng/conf.d/08newlogsql.conf
GRANT INSERT,SELECT,UPDATE ON `DB_NAME`.* TO `USER_LOGGER`@DB_IP IDENTIFIED BY 'PW_LOGGER';

# used by the web gui for normal viewing, referenced in inc/config_class.php
GRANT SELECT ON `DB_NAME`.* TO `USER_LOGVIEWER`@DB_IP IDENTIFIED BY 'PW_LOGVIEWER';

# used by clean up cron job and for archiving, referenced in inc/adminconfig_class.php
GRANT SELECT,UPDATE,DELETE ON `DB_NAME`.* TO `USER_ADMINLOGGER`@DB_IP IDENTIFIED BY 'PW_LOGGERADMIN';
GRANT SELECT,INSERT  ON TABLE `DB_NAME`.`servers` TO `USER_ADMINLOGGER`@DB_IP;

# activate changes
FLUSH PRIVILEGES;
