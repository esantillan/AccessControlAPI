<?php defined('BASEPATH') OR exit('No direct script access allowed');
require APPPATH .  'models/DTO/Usuario_DTO.php';
require APPPATH .  'models/DTO/V_Usuario_Opciones_DTO.php';

class Usuario_Repository extends CI_Model
{
    protected $table = 'usuario';
    protected $permisos_usuario = 'v_usuario_opciones';


    /**
     * User Login
     * ----------------------------------
     * @param: username (string) nick or email address
     * @param: password (string) password (SHA512 encoded)
     */
    public function getUserByUsernameAndPassword($username, $password)
    {
        $result = $this->db->select(['id_usuario', 'nick', 'email'])
                            ->group_start()
                                ->where('nick', $username)
                                ->or_where('email', $username)
                            ->group_end()
                            ->where('password', $password)
                            ->get($this->table);

        return $result->row();//devuelvo el objeto StdClass para evitar que figuren los campos password y baja
    }

    /**
     * Valida que el usuario tenga permisos y retorna TRUE o FALSE
     * @param resource (string) recurso
     */
    public function getPermissionByUser ($user, $resource, $system)
    {

        $result = $this->db->select()
                            ->group_start()
                                ->where('codigo_opcion', $resource)
                                ->or_where('recurso', $resource)
                            ->group_end()
                            ->where('id_usuario', $user->id_usuario)
                            ->where('codigo_sistema', $system)
                            ->get($this->permisos_usuario);

        return $result->row(0, 'V_Usuario_Opciones_DTO');
    }

    /**
     * Devuelve todas las opciones del 
     * @param system (string) codigo_sistema
     */
    public function getPermissionsByUser ($user, $system)
    {

        $result = $this->db->select(['id_opcion', 'descripcion_opcion', 'recurso'])
                            ->distinct()
                            ->where('id_usuario', $user->id_usuario)
                            ->where('codigo_sistema', $system)
                            ->get($this->permisos_usuario);

        return $result->result();//devuelvo el objeto StdClass para reducir el tamaño de los datos devueltos //SEE 
    }
}
