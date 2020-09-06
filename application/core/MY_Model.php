<?php

defined('BASEPATH') OR exit('No direct script access allowed');

class MY_Model extends CI_Model
{
	protected $table;
	protected $view;
	protected $DTO;
	protected $viewDTO;
	private $tableReferences;

   public function __construct()
	{
		parent::__construct();
      $this->load->database();
	}

	public function exists($params){
		if(empty($this->table)){
			throw new Exception('property [table] is not defined!');
		}

		$count = $this->db->from($this->table)
								->where($params)
								->count_all_results();
								
		return ($count > 0);
	}
	
	public function canDelete ($id)
	{
		$can_delete = $this->exists(['ID' => $id]);

		if($can_delete){
			$can_delete = empty($this->getDependencies($id));
		}

		return $can_delete;
	}

	public function getDependencies ($id)
	{
		$this->loadTableReferences();
		$dependecies = [];

		foreach ($this->tableReferences as $row) {
			$this->db->from($row->TABLE_NAME);
			$this->db->where($row->COLUMN_NAME, $id);
			$count = $this->db->count_all_results();

			if($count > 0){
				$dependecies[$row->TABLE_NAME] = $count;
			}
		}

		return $dependecies;
	}

	private function loadTableReferences(){
		if(empty($this->tableReferences)){
			$this->tableReferences = $this->db->query("SELECT TABLE_NAME, COLUMN_NAME FROM information_schema.key_column_usage WHERE REFERENCED_TABLE_NAME = '$this->table' AND REFERENCED_COLUMN_NAME = 'ID'")->result();
		}
	}

	/**
	 * CRUD methods
	 */
	public function getAll($filters = [], $page = 1, $limit = 10)
	{
		$this->load->helper('pagination');
		$table = $this->view ?? $this->table;
		$DTO = $this->viewDTO ?? $this->DTO;

		return paginate($table, $DTO, $filters, $page, $limit);
	}

	public function insert ($params, $user)
	{
		 $params['usuario_id'] = $user['id_usuario'];
		 $this->db->insert($this->table, $params);

		 log_message('debug', $this->db->last_query());
		 return $this->db->affected_rows();
	}

	public function update ($params, $user)
	{
		 $id = $params['ID'];
		 unset($params['ID']);

		 $params['usuario_id'] = $user['id_usuario'];
		 $this->db->where('ID', $id);
		 $this->db->update($this->table, $params);

		 log_message('debug', $this->db->last_query());
		 return $this->db->affected_rows();
	}

	public function delete ($id, $user)
	{
		 $this->db->where('ID', $id);
		 $this->db->delete($this->table);

		 log_message('debug', $this->db->last_query());
		 $this->completarAuditoria($id, $user);
		 return $this->db->affected_rows();
	}

	private function completarAuditoria($id, $user){
		$this->db->where(['ID' => $id, 'operacion' => 'D']);
		$this->db->update('audit_' . $this->table, ['usuario_id' => $user['id_usuario']]);
		log_message('debug', $this->db->last_query());
	}
}