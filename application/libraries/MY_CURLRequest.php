<?php defined( 'BASEPATH' ) OR exit( 'No direct script access allowed' );

/**
* Clase muy sencilla para encapsular las peticiones HTTP a la API de control de acceso utilizando cURL
*/

class MY_CURLRequest {

    // const HTTP_OK = 200;
    // const HTTP_BAD_REQUEST = 400;
    // const HTTP_UNAUTHORIZED = 401;
    // const HTTP_FORBIDDEN = 403;
    // const HTTP_NOT_FOUND = 404;
    // const HTTP_INTERNAL_SERVER_ERROR = 500;

    const METHOD_GET = 'GET';
    const METHOD_POST = 'POST';
    const METHOD_PUT = 'PUT';
    const METHOD_DELETE = 'DELETE';
    const METHOD_OPTIONS = 'OPTIONS';
    const METHOD_HEAD = 'HEAD';
    const METHOD_PATCH = 'PATCH';

    public static function send_request ( $url, $method, $params, $headers, $token ) {
        $method = strtoupper( $method );

        $curl_opts =  [
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_ENCODING => '',
            CURLOPT_MAXREDIRS => 10,
            CURLOPT_TIMEOUT => 0,
            CURLOPT_FOLLOWLOCATION => true,
            CURLOPT_HTTP_VERSION => CURL_HTTP_VERSION_1_1,
            CURLOPT_CUSTOMREQUEST => $method,
            CURLOPT_HTTPHEADER => [
                'Content-Type: application/x-www-form-urlencoded'
            ]
        ];

        if ( $method == 'GET' AND count( $params ) > 0 ) {
            $url .= '?' . self::paramsArrayToString( $params );
        } else if ( $method != 'GET' AND count( $params ) > 0 ) {
            $curl_opts[CURLOPT_POSTFIELDS] = self::paramsArrayToString( $params );
        }

        if ( isset( $token ) AND !empty( $token ) ) {
            $curl_opts[CURLOPT_HTTPHEADER][] = "Authorization: Bearer {$token}";
        }

        $curl_opts[CURLOPT_URL] = $url;

        $curl = curl_init();
        curl_setopt_array( $curl, $curl_opts );

        return curl_exec( $curl );
    }

    private static function paramsArrayToString( $params ) {
        $ret = '';
        $size = count( $params );
        $c = 0;

        foreach ( $params as $key => $value ) {
            $c++;
            $ret .= "{$key}={$value}" . ( $c < $size ? '&' : '' );
        }

        return $ret;
    }

}