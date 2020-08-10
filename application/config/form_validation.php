<?php defined('BASEPATH') OR exit('No direct script access allowed');


$config = [
    // a partir del usuario (nick o email) y contraseña y, si existe ese usuario y contraseña, genera el token 
    'token' => [
        [
            'field' => 'username',
            'label' => 'usuario (nick o email)',
            'rules' => 'required'
        ],
        [
            'field' => 'password',
            'label' => 'contraseña',
            'rules' => 'required'
        ]
    ],
    // corrobora que el token sea válido
    // 'Usuario/validateToken' => [],
    // generar un nuevo token (en caso que se re-generarlo, por si está próximo a caducar)
    // 'Usuario/refreshToken' => [],
    // corroborar que se tenga permiso para acceder al recurso
    'checkPermission' => [
        [
            'field' => 'resources',
            'label' => 'recursos',
            'rules' => 'trim|required'
        ],
        [
            'field' => 'system',
            'label' => 'sistema',
            'rules' => 'trim|required'
        ]
    ],
    // lista todos los permisos
    'getPermissions' => [
        [
            'field' => 'system',
            'label' => 'sistema',
            'rules' => 'trim|required'
        ]
    ]
    // 'Usuario/getPermissions' => [],
    // lista todos los permisos de un usuario
    // 'Usuario/getPermissionsByUserID' => [],
];

?>
