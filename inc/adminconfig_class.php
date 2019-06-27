<?php

class AdminConfig extends AbstractConfig {

    function __construct() {
        $this->setDbUser('loggeradmin');
        $this->setDbPwd('PW_LOGGERADMIN');
        $this->setDbName('DB_NAME');
    } // constructor
} // class
