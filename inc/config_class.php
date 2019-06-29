<?php

class Config extends AbstractConfig {

    function __construct() {
                $this->setDbUser('USER_LOGVIEWER');
                $this->setDbPwd('PW_LOGVIEWER');
                $this->setDbName('DB_NAME');

        
        // Set your preferred language en_US, de_DE, or pt_BR
        $this->setLocale('en_US');
        
        $this->setUrlBootstrap('/logger/contrib/bootstrap/');
        $this->setUrlJquery('/logger/contrib/jquery/');
        $this->setUrlJqueryui('/logger/contrib/jqueryui/');
        $this->setUrlJAtimepicker('/logger/contrib/timepicker/');
        $this->setUrlChartjs('/logger/contrib/chartjs/');
        $this->setUrlJQCloud('/logger/contrib/jqcloud/');
        
    } // constructor
} // class
