<?php

class AdminConfig extends AbstractConfig {

    function __construct() {
        $this->setDbUser('USER_ADMINLOGGER');
        $this->setDbPwd('PW_LOGGERADMIN');
        $this->setDbName('DB_NAME');
    } // constructor
} // class
