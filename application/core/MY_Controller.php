<?php

defined('BASEPATH') or exit('No direct script access allowed');

require APPPATH . '/libraries/REST_Controller.php';
require APPPATH . '/libraries/Format.php';

use Restserver\libraries\REST_Controller;

class MY_Controller extends \Restserver\Libraries\REST_Controller
{

    public function __construct()
    {
        parent::__construct();

    }

}
/* End of file MY_Controller.php */
/* Location: ./application/core/MY_Controller.php */
