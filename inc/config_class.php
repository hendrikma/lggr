<?php

class Config extends AbstractConfig {

    function __construct() {
                $this->setDbUser('logviewer');
                $this->setDbPwd('rl');
                $this->setDbName('logger');

        
        // Set your preferred language en_US, de_DE, or pt_BR
        $this->setLocale('en_US');
        
        /* remote storage 
        $this->setUrlBootstrap('//maxcdn.bootstrapcdn.com/bootstrap/3.3.4/');
        $this->setUrlJquery('//code.jquery.com/');
        $this->setUrlJqueryui('//code.jquery.com/ui/1.11.4/');
        $this->setUrlJAtimepicker(
            '//cdnjs.cloudflare.com/ajax/libs/jquery-ui-timepicker-addon/1.4.5/');
        $this->setUrlChartjs('//cdnjs.cloudflare.com/ajax/libs/Chart.js/2.7.2/');
        $this->setUrlJQCloud('//cdnjs.cloudflare.com/ajax/libs/jqcloud/1.0.4/');
        */
         local storage 
        
        $this->setUrlBootstrap('/logger/contrib/bootstrap/');
        $this->setUrlJquery('/logger/contrib/jquery/');
        $this->setUrlJqueryui('/logger/contrib/jqueryui/');
        $this->setUrlJAtimepicker('/logger/contrib/timepicker/');
        $this->setUrlChartjs('/logger/contrib/chartjs/');
        $this->setUrlJQCloud('/logger/contrib/jqcloud/');
        
    } // constructor
} // class
