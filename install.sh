#!/bin/bash
# Install Script

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

DB_NAME="pihole-logger"
PW_LOGGER="MyLoggerPW"
PW_LOGVIEWER="MyLogViewerPW"
PW_LOGGERADMIN="MyloggeradminPW"

LOGGER_LOCALE="en_US"

ENABLE_BASICAUTH=false

#export SYSLOG_SERVER="192.168.1.10"
SYSLOG_SERVER="0.0.0.0"

DB_IP="localhost"

SYSLOG_CONF=/etc/syslog-ng/syslog-ng.conf
#export SYSLOG_CONF=/etc/syslog-ng/conf.d/99-logger.conf



#--------------------------------------------------------------------------------------------
sed -i "s|DB_NAME|$DB_NAME|g" ./doc/db.sql
sed -i "s|DB_NAME|$DB_NAME|g" ./doc/user.sql
#--------------------------------------------------------------------------------------------
sed -i "s|PW_LOGGER|$PW_LOGGER" ./doc/user.sql
sed -i "s|PW_LOGVIEWER|$PW_LOGVIEWER" ./doc/user.sql
sed -i "s|PW_LOGGERADMIN|$PW_LOGGERADMIN" ./doc/user.sql
#--------------------------------------------------------------------------------------------
sed -i "s|PW_LOGVIEWER|$PW_LOGVIEWER" ./inc/config_class.php
sed -i "s|DB_NAME|$DB_NAME|g"

# Set your preferred language en_US, de_DE, or pt_BR
sed -i "s|en_US|$LOGGER_LOCALE" ./inc/config_class.php
#--------------------------------------------------------------------------------------------
sed -i "s|PW_LOGGERADMIN|$PW_LOGGERADMIN" ./inc/adminconfig_class.php
sed -i "s|DB_NAME|$DB_NAME|g"./inc/adminconfig_class.php
#--------------------------------------------------------------------------------------------
# Remove BasicAuth part from checkSecurity()
if [ $ENABLE_BASICAUTH = false ]
sed -i '52,54 s/^/#/' ./inc/lggr_class.php
fi
#--------------------------------------------------------------------------------------------
systemctl start mysql.service
if [ systemctl is-active mysql ] ; then 
mysql $DB_NAME < ./doc/db.sql
mysql $DB_NAME < ./doc/user.sql
fi

if [ -f /etc/debian_verison]
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
    local_time_zone("Europe/Berlin")
    type(mysql)
    username("logger")
    password("PW_LOGGER")
    database("DB_NAME")
    host("DB_IP")
    table("newlogs")
    columns("date", "facility", "level", "host", "program", "pid", "message")
    values("${R_YEAR}-${R_MONTH}-${R_DAY} ${R_HOUR}:${R_MIN}:${R_SEC}", "$FACILITY", "$LEVEL", "$HOST", "$PROGRAM", "${PID:-9999}", "$MSGONLY")
    indexes()
    );
};

log {
#    source(s_net);
    source(s_local);
	destination(d_newmysql);
};
' > $SYSLOG_CONF





sed -i "s|SYSLOG_SERVER|$SYSLOG_SERVER" $SYSLOG_CONF
sed -i "s|PW_LOGGER|$PW_LOGGER" $SYSLOG_CONF
sed -i "s|DB_NAME|$DB_NAME" $SYSLOG_CONF
sed -i "s|DB_IP|$DB_IP" $SYSLOG_CONF

#systemctl start apache2.service
#sleep 60




