<?php defined('BASEPATH') or exit('No direct script access allowed');

require APPPATH . '/libraries/REST_Controller.php';
require APPPATH . 'libraries/Format.php';

use Restserver\libraries\REST_Controller;

class Usuario extends \Restserver\Libraries\REST_Controller
{
    public function __construct()
    {
        parent::__construct();

        $this->load->model('repository/Usuario_Repository', 'UsuarioRepository');
        $this->load->helper('sanitizer');
        $this->load->library(['form_validation', 'Authorization_Token']);
    }

    /**
    * Comprueba las credenciales del usuario y devuelve un JWT
    * si son correctas ( con status 200 ) o un bad request en caso contrario // QUEST
    *
    * @param String username nick o email
    * @param String password contraseña
    */

    public function token_post()
    {
        $response = [
            'status' => null,
            'message' => null,
            'data' => null
        ];

        try {
            $params = $this->post();

            $this->form_validation->set_data($params);

            if ($this->form_validation->run('token')) {
                //valido los parámetros
                $params['username'] = sanitize_string($params['username']);
                $params['password'] = sanitize_string($params['password']);

                $user = $this->UsuarioRepository->getUserByUsernameAndPassword($params['username'], $params['password']);
                //busco al usuario por ( nick o email ) y contraseña

                if (isset($user)) {
                    //credenciales válidas
                    $this->load->library('Authorization_Token');

                    $token_data['user'] = $user;
                    $token_data['time'] = time();

                    $token = $this->authorization_token->generateToken($token_data);

                    $response['status'] = parent::HTTP_OK;
                    $response['message'] = 'Ok';
                    $response['data'] = $token;
                } else {
                    //credenciales inválidas
                    $response['status'] = parent::HTTP_UNAUTHORIZED;
                    $response['message'] = 'usuario o contraseña inválidos';
                }
            } else {
                //parámetros inválidos
                log_message('error', print_r($this->form_validation->get_errors(), true));

                $response['status'] = parent::HTTP_BAD_REQUEST;
                $response['message'] = $this->form_validation->get_errors();
            }
        } catch (Throwable $err) {
            log_message('error', print_r($error, true));

            $response['status'] = parent::HTTP_INTERNAL_SERVER_ERROR;
            $response['message'] = 'Se ha producido un error interno del servidor, por favor intentelo de nuevo más tarde o contactese con el administrador si el problema persiste';
        } finally {
            $this->response($response, $response['status']);
        }
    }

    /**
    * Valida el token recibido y retorna un status 200 si es válido o un bad request.
    * Lee el JWT desde la cabecera 'Authorization' de la peticion
    * //QUEST ¿Es necesario este método? ( o ¿Es necesario que sea un metodo API en lugar de uno privado? )
    */

    public function validateToken_post()
    {
        $response = [
            'status' => null,
            'message' => null
        ];

        try {
            $result = $this->authorization_token->validateToken();

            if ($result['status']) {
                //valido el token
                $response['status'] = parent::HTTP_OK;
                $response['message'] = 'Ok';
            } else {
                //token inválido
                log_message('error', print_r($result['message'], true));

                $response['status'] = parent::HTTP_BAD_REQUEST;
                $response['message'] = $result['message'];
            }
        } catch (Throwable $error) {
            log_message('error', print_r($error, true));

            $response['status'] = parent::HTTP_INTERNAL_SERVER_ERROR;
            $response['message'] = 'Se ha producido un error interno del servidor, por favor intentelo de nuevo más tarde o contactese con el administrador si el problema persiste';
        } finally {
            $this->response($response, $response['status']);
        }
    }

    /**
    * Comprueba que se tenga permiso para acceder al recurso y devuelve
    * un status 200 en caso de afirmativo, sino un 403
    *
    * Parametros: 'resource' 'codigo_recurso' o 'recurso' ( vista v_usuario_opciones )
    */

    public function checkPermission_get()
    {
        $response = [
            'status' => null,
            'message' => null,
            'data' => null
        ];

        try {
            $result = $this->authorization_token->validateToken();
            //compruebo el token

            if ($result['status']) {
                $params = $this->get();

                $this->form_validation->set_data($params);

                if ($this->form_validation->run('checkPermission')) {
                    //compruebo los parámetros
                    $data = $this->authorization_token->userData();
                    $params['resource'] = sanitize_string($params['resource']);
                    $params['system_code'] = sanitize_string($params['system_code']);
                    $params['system_version'] = sanitize_string($params['system_version']);//FIXME

                    $permiso_usuario = $this->UsuarioRepository->getPermissionByUser($data->user, $params['resource'], $params['system_code'], $params['system_version']);

                    if (isset($permiso_usuario)) {
                        //compruebo que tenga permiso
                        $response['status'] = parent::HTTP_OK;
                        $response['message'] = 'Ok';
                    } else {
                        //no tiene permiso
                        $response['status'] = parent::HTTP_FORBIDDEN;
                        $response['message'] = 'No tiene permisos para acceder a este recurso';
                    }
                } else {
                    //parámetros inválidos
                    log_message('error', print_r($this->form_validation->get_errors(), true));

                    $response['status'] = parent::HTTP_BAD_REQUEST;
                    $response['message'] = isset($params['resource']) ? $this->form_validation->get_errors() : 'No se ha proporcionado el recurso a consultar';
                }
            } else {
                //token invalido
                $err = $this->form_validation->get_errors();
                log_message('error', print_r($result['message'], true));

                $response['status'] = parent::HTTP_BAD_REQUEST;
                $response['message'] = $result['message'];
            }
        } catch (Throwable $error) {
            log_message('error', print_r($error, true));

            $response['status'] = parent::HTTP_INTERNAL_SERVER_ERROR;
            $response['message'] = 'Se ha producido un error interno del servidor, por favor intentelo de nuevo más tarde o contactese con el administrador si el problema persiste';
        } finally {
            $this->response($response, $response['status']);
        }
    }

    /**
    * Comprueba que se tenga permiso para acceder al recurso y devuelve
    * un status 200 en caso de afirmativo, sino un 403
    *
    * Parametros: 'resource' 'codigo_recurso' o 'recurso' ( vista v_usuario_opciones )
    */

    public function getPermissions_get()
    {
        $response = [
            'status' => null,
            'message' => null,
            'data' => null
        ];

        try {
            $result = $this->authorization_token->validateToken();

            if ($result['status']) {
                //compruebo el token
                $params = $this->get();

                $this->form_validation->set_data($params);

                if ($this->form_validation->run('getPermissions')) {
                    //compruebo los parámetros
                    $data = $this->authorization_token->userData();
                    $params['system_code'] = sanitize_string($params['system_code']);
                    $params['system_version'] = sanitize_string($params['system_version']);//FIXME

                    $permisos_usuario = $this->UsuarioRepository->getPermissionsByUser($data->user, $params['system_code'], $params['system_version']);

                    $response['status'] = parent::HTTP_OK;
                    if (isset($permisos_usuario)) {
                        //compruebo que tenga permiso
                        $response['message'] = 'Ok';
                        $response['data'] = $permisos_usuario;
                    } else {
                        //no tiene permiso
                        $response['message'] = 'No se encontraron resultados';
                    }
                } else {
                    //parámetros inválidos
                    log_message('error', print_r($this->form_validation->get_errors(), true));

                    $response['status'] = parent::HTTP_BAD_REQUEST;
                    $response['message'] = isset($params['resource']) ? $this->form_validation->get_errors() : 'No se ha proporcionado el recurso a consultar';
                }
            } else {
                //token invalido
                $err = $this->form_validation->get_errors();
                log_message('error', print_r($result['message'], true));

                $response['status'] = parent::HTTP_BAD_REQUEST;
                $response['message'] = $result['message'];
            }
        } catch (Throwable $error) {
            log_message('error', print_r($error, true));

            $response['status'] = parent::HTTP_INTERNAL_SERVER_ERROR;
            $response['message'] = 'Se ha producido un error interno del servidor, por favor intentelo de nuevo más tarde o contactese con el administrador si el problema persiste';
        } finally {
            $this->response($response, $response['status']);
        }
    }

    public function prueba2_post()
    {
        $this->load->library('MY_CURLRequest');

        $url = 'http://localhost/augusto/AccessControlAPI/index.php/Usuario/getPermissions';
        $method = 'delete';
        $token = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VyIjp7ImlkX3VzdWFyaW8iOiIyIiwibmljayI6ImVzYW50aWxsYW4iLCJlbWFpbCI6ImVzdGViYW5zYW50aWxsYW45NkBnbWFpbC5jb20ifSwidGltZSI6MTU5NzExMDQwMn0.LrJ7Tbi4oyIZsOZnaeMHaqR2E_BR_eIx51Df3THRmFM';
        $params = [
            'system' => 'siscuota_online'
        ];
        // $params = [
        //     'username' => 'esantillan',
        //     'password' => 'b8e840fe7acb42b312660f1a5b8897b432ca02459a10a563a62b1de2da006fbdc416f38cd9122bad8ae6c8fa24cb3a99e7cfb845daae874295844a3a93939e34'
        // ];

        $response = MY_CURLRequest::send_request($url, $method, $params, [], $token);
        $this->response(json_decode($response));
    }

    public function prueba_get()
    {
        $a = $this->post();
        $response = [
            'status' => 200,
            'message' => 'Cliente encontrado',
            'data' => [
                'nombre' => 'Esteban Antonio',
                'apellido' => 'Santillán'
            ]
        ];

        $this->response($response);
    }

    //     public function prueba_post ()
    // {
    //         $curl = curl_init();

    //         curl_setopt_array( $curl, array(
    //             CURLOPT_URL => 'http://localhost/augusto/AccessControlAPI/index.php/Usuario/getPermissions/?system=siscuota_online',
    //             CURLOPT_RETURNTRANSFER => true,
    //             CURLOPT_ENCODING => '',
    //             CURLOPT_MAXREDIRS => 10,
    //             CURLOPT_TIMEOUT => 0,
    //             CURLOPT_FOLLOWLOCATION => true,
    //             CURLOPT_HTTP_VERSION => CURL_HTTP_VERSION_1_1,
    //             CURLOPT_CUSTOMREQUEST => 'GET',
    //             CURLOPT_POSTFIELDS => 'username=esantillan&password=b8e840fe7acb42b312660f1a5b8897b432ca02459a10a563a62b1de2da006fbdc416f38cd9122bad8ae6c8fa24cb3a99e7cfb845daae874295844a3a93939e34',
    //             CURLOPT_HTTPHEADER => array(
    //                 'Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VyIjp7ImlkX3VzdWFyaW8iOiIyIiwibmljayI6ImVzYW50aWxsYW4iLCJlbWFpbCI6ImVzdGViYW5zYW50aWxsYW45NkBnbWFpbC5jb20ifSwidGltZSI6MTU5NzAyNjg4MX0._JCf9cYPx-XeH8lJGpRK5KrgxbALbKpmTM0IorAPDP8',
    //                 'Content-Type: application/x-www-form-urlencoded'
    // ),
    // ) );

    //         $response = curl_exec( $curl );
    //         $a = json_decode( $response );
    //         curl_close( $curl );
    //         echo $response;

    //     }
}
