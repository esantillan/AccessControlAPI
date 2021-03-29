DROP DATABASE IF EXISTS access_control_new;
SET NAMES 'UTF8';
CREATE DATABASE access_control DEFAULT CHARACTER SET utf8 COLLATE utf8_spanish_ci;

USE access_control;

CREATE TABLE company(
   id_company INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
   business_name VARCHAR(255) NOT NULL,
   CUIT BIGINT UNSIGNED NOT NULL,--@SEE En teoría son 11 dígitos 
   brand_name VARCHAR(255) NOT NULL,
   logo VARCHAR(255) NOT NULL COMMENT 'Path de la imagen (logo)',
   active BOOLEAN NOT NULL DEFAULT TRUE
)ENGINE=INNODB CHARSET utf8 COLLATE utf8_spanish_ci;

CREATE TABLE `system`(
   id_system INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
   descripcion VARCHAR(255) NOT NULL,
   codigo VARCHAR(50) NOT NULL,
   `version` VARCHAR(20) NOT NULL,
   active BOOLEAN NOT NULL DEFAULT TRUE
)ENGINE=INNODB CHARSET utf8 COLLATE utf8_spanish_ci;


CREATE TABLE company_system(
   id_company_system INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
   system_id INT UNSIGNED,
   company_id INT UNSIGNED,
   restrict_origins BOOLEAN NOT NULL DEFAULT FALSE,
   restrict_devices_types BOOLEAN NOT NULL DEFAULT FALSE,
   active BOOLEAN NOT NULL DEFAULT TRUE,
   CONSTRAINT fk_companysystem_system FOREIGN KEY (system_id) REFERENCES `system`(id_system) ON UPDATE CASCADE ON DELETE RESTRICT,
   CONSTRAINT fk_companysystem_company FOREIGN KEY (company_id) REFERENCES company(company_id) ON UPDATE CASCADE ON DELETE RESTRICT
)ENGINE=INNODB CHARSET utf8 COLLATE utf8_spanish_ci;


CREATE TABLE device_type(
   id_device_type INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
   platform VARCHAR(255) NOT NULL,
   model VARCHAR(255) NOT NULL,
   is_virtual BOOLEAN NOT NULL DEFAULT FALSE,
   manufacturer VARCHAR(255) NOT NULL,
   `description` VARCHAR(255) NOT NULL,
   active BOOLEAN NOT NULL DEFAULT TRUE
)ENGINE=INNODB CHARSET utf8 COLLATE utf8_spanish_ci;


CREATE TABLE company_system_allowed_device_type(
   id_company_system_allowed_device_type INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
   company_system_id INT UNSIGNED,
   device_type_id INT UNSIGNED,
   active BOOLEAN NOT NULL DEFAULT TRUE,
   CONSTRAINT fk_companysystemalloweddevicetype_companysystem FOREIGN KEY (company_system_id) REFERENCES company_system(company_system_id) ON UPDATE CASCADE ON DELETE RESTRICT,
   CONSTRAINT fk_companysystemalloweddevicetype_devicetype FOREIGN KEY (device_type_id) REFERENCES device_type(device_type_id) ON UPDATE CASCADE ON DELETE RESTRICT
)ENGINE=INNODB CHARSET utf8 COLLATE utf8_spanish_ci;


CREATE TABLE company_system_skin(
   id_company_system_skin INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
   company_system_id INT UNSIGNED,
   skin_value LONGTEXT NOT NULL,
   alt_skin_value LONGTEXT NULL,
   active BOOLEAN NOT NULL DEFAULT TRUE,
   CONSTRAINT fk_companysystemskin_companysystem FOREIGN KEY (company_system_id) REFERENCES company_system(company_system_id) ON UPDATE CASCADE ON DELETE RESTRICT
)ENGINE=INNODB CHARSET utf8 COLLATE utf8_spanish_ci;


CREATE TABLE allowed_origins(
   id_allowed_origins INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
   company_system_id INT UNSIGNED,
   origin VARCHAR(255) NOT NULL,
   descripcion VARCHAR(255),
   active BOOLEAN NOT NULL DEFAULT TRUE,
   CONSTRAINT fk_allowedorigins_companysystem FOREIGN KEY (company_system_id) REFERENCES company_system(company_system_id) ON UPDATE CASCADE ON DELETE RESTRICT
)ENGINE=INNODB CHARSET utf8 COLLATE utf8_spanish_ci;

CREATE TABLE opcion(
   id_opcion INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
   codigo VARCHAR(50) NOT NULL,
   descripcion VARCHAR(255) NOT NULL,
   recurso VARCHAR(255) NOT NULL,
   opcion_padre_id INT UNSIGNED,
   system_id INT UNSIGNED,
   active BOOLEAN NOT NULL DEFAULT TRUE,
   CONSTRAINT fk_opcion_system FOREIGN KEY (system_id) REFERENCES system(id_system) ON UPDATE CASCADE ON DELETE RESTRICT,
   CONSTRAINT fk_opcion_padre FOREIGN KEY (opcion_padre_id) REFERENCES Opcion(id_opcion) ON UPDATE CASCADE ON DELETE RESTRICT
)ENGINE=INNODB CHARSET utf8 COLLATE utf8_spanish_ci;

CREATE TABLE rol(
   id_rol INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
   descripcion VARCHAR(255) NOT NULL,
   active BOOLEAN NOT NULL DEFAULT TRUE
)ENGINE=INNODB CHARSET utf8 COLLATE utf8_spanish_ci;

CREATE TABLE rol_opcion(
   id_rol_opcion INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
   opcion_id INT UNSIGNED,
   rol_id INT UNSIGNED,
   active BOOLEAN NOT NULL DEFAULT TRUE,
   CONSTRAINT fk_rol_opcion_rol FOREIGN KEY (rol_id) REFERENCES rol(id_rol) ON UPDATE CASCADE ON DELETE RESTRICT,
   CONSTRAINT fk_rolopcion_opcion FOREIGN KEY (opcion_id) REFERENCES opcion(id_opcion) ON UPDATE CASCADE ON DELETE RESTRICT
)ENGINE=INNODB CHARSET utf8 COLLATE utf8_spanish_ci;

CREATE TABLE user(
   id_user INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
   nick VARCHAR(255) NOT NULL,
   email varchar(100) NOT NULL,
   `password` VARCHAR(128) BINARY,
   active BOOLEAN NOT NULL DEFAULT TRUE
)ENGINE=INNODB CHARSET utf8 COLLATE utf8_spanish_ci;

CREATE TABLE user_device(
   id_user_device INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
   user_id INT UNSIGNED,
   --cordova info
   device_type_id INT UNSIGNED,
   uuid VARCHAR(255),
   --windows info
   serial_number VARCHAR(255),
   user_name VARCHAR(255),
   user_domain_name VARCHAR(255),
   machine_name VARCHAR(255),
   OSVersion VARCHAR(255),
   processor_count TINYINT,
   mac_address VARCHAR(255),

   other_info VARCHAR(255),
   active BOOLEAN NOT NULL DEFAULT TRUE,
   CONSTRAINT fk_companysystemalloweddevicetype_companysystem FOREIGN KEY (company_system_id) REFERENCES company_system(company_system_id) ON UPDATE CASCADE ON DELETE RESTRICT,
   CONSTRAINT fk_companysystemalloweddevicetype_devicetype FOREIGN KEY (device_type_id) REFERENCES device_type(device_type_id) ON UPDATE CASCADE ON DELETE RESTRICT
)ENGINE=INNODB CHARSET utf8 COLLATE utf8_spanish_ci;

-- @TODO authentication_methods
-- @TODO company_system_authentication_methods
-- @TODO user_authentication_methods
-- @TODO accesslog (hacer referencia a user_device)

CREATE TABLE user_rol(
   id_user_rol INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
   user_id INT UNSIGNED,
   rol_id INT UNSIGNED,
   active BOOLEAN NOT NULL DEFAULT TRUE,
   CONSTRAINT fk_userrol_user FOREIGN KEY (user_id) REFERENCES user(id_user) ON UPDATE CASCADE ON DELETE RESTRICT,
   CONSTRAINT fk_userrol_rol FOREIGN KEY (rol_id) REFERENCES rol(id_rol) ON UPDATE CASCADE ON DELETE RESTRICT
)ENGINE=INNODB CHARSET utf8 COLLATE utf8_spanish_ci;

CREATE FULLTEXT INDEX indx_user_email ON user (email);
CREATE FULLTEXT INDEX indx_user_nick ON user (nick);

CREATE FULLTEXT INDEX indx_opcion_recurso ON opcion (recurso);
CREATE FULLTEXT INDEX indx_opcion_codigo ON opcion (codigo);

CREATE FULLTEXT INDEX indx_system_codigo ON system(codigo);

/**
* Vista de users: las apis externas obtendrán resultados de esta vista, en lugar de la propia tabla
* NOTA: 
*     . Detallo los campos (de forma explícita) para evitar compartir la contraseña
*     . El campo active no es necesario que lo vean las apis externas
*/
CREATE ALGORITHM = MERGE VIEW v_user_opciones
AS
SELECT 
	u.id_user
	, nick
    , email
    , ur.id_user_rol
    , r.id_rol
    , r.descripcion AS descripcion_rol
    , ro.id_rol_opcion
    , o.id_opcion
    , o.codigo AS codigo_opcion
    , o.descripcion AS descripcion_opcion
    , o.recurso
    , s.id_system
    , s.codigo AS codigo_system
    , s.descripcion AS descripcion_system
    , s.version
FROM user u
	JOIN user_rol ur ON ur.user_id = u.id_user
	JOIN rol r ON ur.rol_id = r.id_rol
    JOIN rol_opcion ro ON ro.rol_id = r.id_rol
    JOIN opcion o ON ro.opcion_id = o.id_opcion
    JOIN system s ON o.system_id = s.id_system
WHERE u.active = FALSE
	AND ur.active = FALSE
    AND ro.active = FALSE
    AND o.active = FALSE
    AND s.active = FALSE;


/*************************************************************
*  Tablas de Auditoría                                       *
*************************************************************/
CREATE TABLE audit_system(
   id_audit_system INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
	id_system INT UNSIGNED,
	descripcion VARCHAR(255),
	codigo VARCHAR(50),
	version VARCHAR(20),
	active BOOLEAN DEFAULT FALSE,
   operacion CHAR(1) NOT NULL,
   user_bd VARCHAR(100) NOT NULL COMMENT 'user de base de datos con el que se conectó la API externa',
   fecha TIMESTAMP  NOT NULL DEFAULT CURRENT_TIMESTAMP
)ENGINE=MYISAM CHARSET utf8 COLLATE utf8_spanish_ci;

CREATE TABLE audit_allowed_origins(
   id_audit_allowed_origins INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
   id_allowed_origins INT UNSIGNED,
   system_id INT UNSIGNED,
   origin VARCHAR(255) NOT NULL,
   descripcion VARCHAR(255),
   active BOOLEAN NOT NULL DEFAULT TRUE,
   operacion CHAR(1) NOT NULL,
   user_bd VARCHAR(100) NOT NULL COMMENT 'user de base de datos con el que se conectó la API externa',
   fecha TIMESTAMP  NOT NULL DEFAULT CURRENT_TIMESTAMP
)ENGINE=INNODB CHARSET utf8 COLLATE utf8_spanish_ci;

CREATE TABLE audit_opcion(
   id_audit_opcion INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
	id_opcion INT UNSIGNED,
	codigo VARCHAR(50),
	descripcion VARCHAR(255),
	recurso VARCHAR(255),
	opcion_padre_id INT UNSIGNED,
	system_id INT UNSIGNED,
	active BOOLEAN DEFAULT FALSE,
   operacion CHAR(1) NOT NULL,
   user_bd VARCHAR(100) NOT NULL COMMENT 'user de base de datos con el que se conectó la API externa',
   fecha TIMESTAMP  NOT NULL DEFAULT CURRENT_TIMESTAMP
)ENGINE=MYISAM CHARSET utf8 COLLATE utf8_spanish_ci;

CREATE TABLE audit_rol(
   id_audit_rol INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
	id_rol INT UNSIGNED,
	descripcion VARCHAR(255),
	active BOOLEAN DEFAULT FALSE,
   operacion CHAR(1) NOT NULL,
   user_bd VARCHAR(100) NOT NULL COMMENT 'user de base de datos con el que se conectó la API externa',
   fecha TIMESTAMP  NOT NULL DEFAULT CURRENT_TIMESTAMP
)ENGINE=MYISAM CHARSET utf8 COLLATE utf8_spanish_ci;

CREATE TABLE audit_rol_opcion(
   id_audit_rol_opcion INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
	id_rol_opcion INT UNSIGNED,
	opcion_id INT UNSIGNED,
	rol_id INT UNSIGNED,
	active BOOLEAN DEFAULT FALSE,
   operacion CHAR(1) NOT NULL,
   user_bd VARCHAR(100) NOT NULL COMMENT 'user de base de datos con el que se conectó la API externa',
   fecha TIMESTAMP  NOT NULL DEFAULT CURRENT_TIMESTAMP
)ENGINE=MYISAM CHARSET utf8 COLLATE utf8_spanish_ci;

CREATE TABLE audit_user(
   id_audit_user INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
	id_user INT UNSIGNED,
	nick VARCHAR(255),
	email varchar(100),
	`password` VARCHAR(128) BINARY,
	active BOOLEAN DEFAULT FALSE,
   operacion CHAR(1) ,
   user_bd VARCHAR(100) COMMENT 'user de base de datos con el que se conectó la API externa',
   fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)ENGINE=MYISAM CHARSET utf8 COLLATE utf8_spanish_ci; 

CREATE TABLE audit_user_rol(
   id_audit_user_rol INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
   id_user_rol INT UNSIGNED,
   user_id INT UNSIGNED,
   rol_id INT UNSIGNED,
   active BOOLEAN DEFAULT FALSE,
   operacion CHAR(1) NOT NULL,
   user_bd VARCHAR(100) NOT NULL COMMENT 'user de base de datos con el que se conectó la API externa',
   fecha TIMESTAMP  NOT NULL DEFAULT CURRENT_TIMESTAMP
)ENGINE=MYISAM CHARSET utf8 COLLATE utf8_spanish_ci;

/*************************************************
* Triggers para user                          *
*************************************************/
DELIMITER $$

CREATE TRIGGER tr_user_ai AFTER INSERT ON user
FOR EACH ROW
BEGIN
	INSERT INTO audit_user (
		id_user
      , nick
      , email
      , `password`
      , active
      , operacion
      , user_bd
	) VALUES(
		NEW.id_user
      , NEW.nick
      , NEW.email
      , NEW.`password`
      , NEW.active
      , 'I'
      , CURRENT_USER()
	);
END; $$

DELIMITER ;


DELIMITER $$

CREATE TRIGGER tr_user_au AFTER UPDATE ON user
FOR EACH ROW
BEGIN
	INSERT INTO audit_user (
		id_user
      , nick
      , email
      , `password`
      , active
      , operacion
      , user_bd
	) VALUES(
		NEW.id_user
      , NEW.nick
      , NEW.email
      , NEW.`password`
      , NEW.active
      , 'U'
      , CURRENT_USER()
	);
END; $$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER tr_user_ad AFTER DELETE ON user
FOR EACH ROW
BEGIN
	INSERT INTO audit_user (
		id_user
      , nick
      , email
      , `password`
      , active
      , operacion
      , user_bd
	) VALUES(
		OLD.id_user
      , OLD.nick
      , OLD.email
      , OLD.`password`
      , OLD.active
      , 'D'
      , CURRENT_USER()
	);
END; $$

DELIMITER ;

/*************************************************
* Triggers para user_rol                      *
*************************************************/
DELIMITER $$

CREATE TRIGGER tr_user_rol_ai AFTER INSERT ON user_rol
FOR EACH ROW
BEGIN
	INSERT INTO audit_user_rol (
		id_user_rol
		, user_id
      , rol_id
      , active
      , operacion
      , user_bd
	) VALUES(
		NEW.id_user_rol
      , NEW.user_id
      , NEW.rol_id
      , NEW.active
      , 'I'
      , CURRENT_USER()
	);
END; $$

DELIMITER ;


DELIMITER $$

CREATE TRIGGER tr_user_rol_au AFTER UPDATE ON user_rol
FOR EACH ROW
BEGIN
	INSERT INTO audit_user_rol (
		id_user_rol
		, user_id
      , rol_id
      , active
      , operacion
      , user_bd
	) VALUES(
		NEW.id_user_rol
      , NEW.user_id
      , NEW.rol_id
      , NEW.active
      , 'U'
      , CURRENT_USER()
	);
END; $$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER tr_user_rol_ad AFTER DELETE ON user_rol
FOR EACH ROW
BEGIN
	INSERT INTO audit_user_rol (
		id_user_rol
		, user_id
      , rol_id
      , active
      , operacion
      , user_bd
	) VALUES(
      OLD.id_user_rol
      , OLD.user_id
      , OLD.rol_id
      , OLD.active
      , 'D'
      , CURRENT_USER()
	);
END; $$

DELIMITER ;



/*************************************************
* Triggers para system                          *
*************************************************/
DELIMITER $$

CREATE TRIGGER tr_system_ai AFTER INSERT ON system
FOR EACH ROW
BEGIN
	INSERT INTO audit_system (
		id_system
		, descripcion
      , codigo
      , `version`
      , active
      , operacion
      , user_bd
	) VALUES(
		NEW.id_system
      , NEW.descripcion
      , NEW.codigo
      , NEW.`version`
      , NEW.active
      , 'I'
      , CURRENT_USER()
	);
END; $$

DELIMITER ;


DELIMITER $$

CREATE TRIGGER tr_system_au AFTER UPDATE ON system
FOR EACH ROW
BEGIN
	INSERT INTO audit_system (
		id_system
		, descripcion
      , codigo
      , `version`
      , active
      , operacion
      , user_bd
	) VALUES(
		NEW.id_system
      , NEW.descripcion
      , NEW.codigo
      , NEW.`version`
      , NEW.active
      , 'U'
      , CURRENT_USER()
	);
END; $$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER tr_system_ad AFTER DELETE ON system
FOR EACH ROW
BEGIN
	INSERT INTO audit_system (
		id_system
		, descripcion
      , codigo
      , `version`
      , active
      , operacion
      , user_bd
	) VALUES(
      OLD.id_system
      , OLD.descripcion
      , OLD.codigo
      , OLD.`version`
      , OLD.active
      , 'D'
      , CURRENT_USER()
	);
END; $$

DELIMITER ;

/*************************************************
* Triggers para rol_opcion                       *
*************************************************/

DELIMITER $$

CREATE TRIGGER tr_rol_opcion_ai AFTER INSERT ON rol_opcion
FOR EACH ROW
BEGIN
	INSERT INTO audit_rol_opcion (
		id_rol_opcion
		, opcion_id
      , rol_id
      , active
      , operacion
      , user_bd
	) VALUES(
		NEW.id_rol_opcion
      , NEW.opcion_id
      , NEW.rol_id
      , NEW.active
      , 'I'
      , CURRENT_USER()
	);
END; $$

DELIMITER ;


DELIMITER $$

CREATE TRIGGER tr_rol_opcion_au AFTER UPDATE ON rol_opcion
FOR EACH ROW
BEGIN
	INSERT INTO audit_rol_opcion (
		id_rol_opcion
		, opcion_id
      , rol_id
      , active
      , operacion
      , user_bd
	) VALUES(
		NEW.id_rol_opcion
      , NEW.opcion_id
      , NEW.rol_id
      , NEW.active
      , 'U'
      , CURRENT_USER()
	);
END; $$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER tr_rol_opcion_ad AFTER DELETE ON rol_opcion
FOR EACH ROW
BEGIN
	INSERT INTO audit_rol_opcion (
		id_rol_opcion
		, opcion_id
      , rol_id
      , active
      , operacion
      , user_bd
	) VALUES(
      OLD.id_rol_opcion
      , OLD.opcion_id
      , OLD.rol_id
      , OLD.active
      , 'D'
      , CURRENT_USER()
	);
END; $$

DELIMITER ;

/*************************************************
* Triggers para rol                              *
*************************************************/

DELIMITER $$

CREATE TRIGGER tr_rol_ai AFTER INSERT ON rol
FOR EACH ROW
BEGIN
	INSERT INTO audit_rol (
		id_rol
		, descripcion
      , active
      , operacion
      , user_bd
	) VALUES(
		NEW.id_rol
      , NEW.descripcion
      , NEW.active
      , 'I'
      , CURRENT_USER()
	);
END; $$

DELIMITER ;


DELIMITER $$

CREATE TRIGGER tr_rol_au AFTER UPDATE ON rol
FOR EACH ROW
BEGIN
	INSERT INTO audit_rol (
		id_rol
		, descripcion
      , active
      , operacion
      , user_bd
	) VALUES(
		NEW.id_rol
      , NEW.descripcion
      , NEW.active
      , 'U'
      , CURRENT_USER()
	);
END; $$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER tr_rol_ad AFTER DELETE ON rol
FOR EACH ROW
BEGIN
	INSERT INTO audit_rol (
		id_rol
		, descripcion
      , active
      , operacion
      , user_bd
	) VALUES(
      OLD.id_rol
      , OLD.descripcion
      , OLD.active
      , 'D'
      , CURRENT_USER()
	);
END; $$

DELIMITER ;

/*************************************************
* Triggers para opcion                           *
**************************************************/

DELIMITER $$

CREATE TRIGGER tr_opcion_ai AFTER INSERT ON opcion
FOR EACH ROW
BEGIN
	INSERT INTO audit_opcion (
		id_opcion
      , codigo
		, descripcion
      , recurso
      , opcion_padre_id
      , system_id
      , active
      , operacion
      , user_bd
	) VALUES(
		NEW.id_opcion
      , NEW.codigo
      , NEW.descripcion
      , NEW.recurso
      , NEW.opcion_padre_id
      , NEW.system_id
      , NEW.active
      , 'I'
      , CURRENT_USER()
	);
END; $$

DELIMITER ;


DELIMITER $$

CREATE TRIGGER tr_opcion_au AFTER UPDATE ON opcion
FOR EACH ROW
BEGIN
	INSERT INTO audit_opcion (
		id_opcion
      , codigo
		, descripcion
      , recurso
      , opcion_padre_id
      , system_id
      , active
      , operacion
      , user_bd
	) VALUES(
		NEW.id_opcion
      , NEW.codigo
      , NEW.descripcion
      , NEW.recurso
      , NEW.opcion_padre_id
      , NEW.system_id
      , NEW.active
      , 'U'
      , CURRENT_USER()
	);
END; $$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER tr_opcion_ad AFTER DELETE ON opcion
FOR EACH ROW
BEGIN
	INSERT INTO audit_opcion (
		id_opcion
      , codigo
		, descripcion
      , recurso
      , opcion_padre_id
      , system_id
      , active
      , operacion
      , user_bd
	) VALUES(
      OLD.id_opcion
      , OLD.codigo
      , OLD.descripcion
      , OLD.recurso
      , OLD.opcion_padre_id
      , OLD.system_id
      , OLD.active
      , 'D'
      , CURRENT_USER()
	);
END; $$

DELIMITER ;

/*************************************************
* Triggers para allowed_origins                  *
**************************************************/

DELIMITER $$

CREATE TRIGGER tr_allowed_origins_ai AFTER INSERT ON allowed_origins
FOR EACH ROW
BEGIN
	INSERT INTO audit_allowed_origins(
		id_allowed_origins
      , system_id
	  , origin
      , descripcion
      , active
      , operacion
      , user_bd
	) VALUES(
		NEW.id_allowed_origins
      , NEW.system_id
      , NEW.origin
      , NEW.descripcion
      , NEW.active
      , 'I'
      , CURRENT_USER()
	);
END; $$

DELIMITER ;


DELIMITER $$

CREATE TRIGGER tr_allowed_origins_au AFTER UPDATE ON allowed_origins
FOR EACH ROW
BEGIN
	INSERT INTO audit_allowed_origins (
		id_allowed_origins
      , system_id
	  , origin
      , descripcion
      , active
      , operacion
      , user_bd
	) VALUES(
		NEW.id_allowed_origins
      , NEW.system_id
      , NEW.origin
      , NEW.descripcion
      , NEW.active
      , 'U'
      , CURRENT_USER()
	);
END; $$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER tr_allowed_origins_ad AFTER DELETE ON allowed_origins
FOR EACH ROW
BEGIN
	INSERT INTO audit_allowed_origins (
		id_allowed_origins
      , system_id
	  , origin
      , descripcion
      , active
      , operacion
      , user_bd
	) VALUES(
      OLD.id_allowed_origins
      , OLD.system_id
      , OLD.origin
      , OLD.descripcion
      , OLD.active
      , 'D'
      , CURRENT_USER()
	);
END; $$

DELIMITER ;
/*****************************************************
* Inserts                                            *
******************************************************/
INSERT INTO `access_control`.`system` (`descripcion`, `codigo`, `version`) VALUES ('system de cuotas online', 'sicu', '1.0.0');

INSERT INTO `access_control`.`opcion` (`codigo`, `descripcion`, `recurso`, `system_id`) VALUES ('Alumno', 'controlador de alumnos', 'alumno', '1');
INSERT INTO `access_control`.`opcion` (`codigo`, `descripcion`, `recurso`, `system_id`) VALUES ('Apariencia', 'controlador de apariencia', 'apariencia', '1');
INSERT INTO `access_control`.`opcion` (`codigo`, `descripcion`, `recurso`, `system_id`) VALUES ('Banco', 'controlador de banco', 'banco', '1');
INSERT INTO `access_control`.`opcion` (`codigo`, `descripcion`, `recurso`, `system_id`) VALUES ('Becas', 'controlador de becas', 'becas', '1');
INSERT INTO `access_control`.`opcion` (`codigo`, `descripcion`, `recurso`, `system_id`) VALUES ('CertificadoAnalitico', 'controlador de certificado_analitico', 'certificado_analitico', '1');
INSERT INTO `access_control`.`opcion` (`codigo`, `descripcion`, `recurso`, `system_id`) VALUES ('Ciclo', 'controlador de ciclo', 'ciclo', '1');
INSERT INTO `access_control`.`opcion` (`codigo`, `descripcion`, `recurso`, `system_id`) VALUES ('CicloReserva', 'controlador de cicloReserva', 'ciclo_reserva', '1');
INSERT INTO `access_control`.`opcion` (`codigo`, `descripcion`, `recurso`, `system_id`) VALUES ('Curso', 'controlador de curso', 'curso', '1');
INSERT INTO `access_control`.`opcion` (`codigo`, `descripcion`, `recurso`, `system_id`) VALUES ('Deudores', 'controlador de deudores', 'deudores', '1');
INSERT INTO `access_control`.`opcion` (`codigo`, `descripcion`, `recurso`, `system_id`) VALUES ('Division', 'controlador de Division', 'division', '1');
INSERT INTO `access_control`.`opcion` (`codigo`, `descripcion`, `recurso`, `system_id`) VALUES ('Pago', 'controlador de Pago', 'pago', '1');
INSERT INTO `access_control`.`opcion` (`codigo`, `descripcion`, `recurso`, `system_id`) VALUES ('Parametro', 'controlador de Parametro', 'parametro', '1');
INSERT INTO `access_control`.`opcion` (`codigo`, `descripcion`, `recurso`, `system_id`) VALUES ('PermisoExamen', 'controlador de PermisoExamen', 'permiso_examen', '1');
INSERT INTO `access_control`.`opcion` (`codigo`, `descripcion`, `recurso`, `system_id`) VALUES ('ReservaVacante', 'controlador de ReservaVacante', 'reserva_vacante', '1');
INSERT INTO `access_control`.`opcion` (`codigo`, `descripcion`, `recurso`, `system_id`) VALUES ('Tarjeta', 'controlador de Tarjeta (tabla "seleccionartarjeta")', 'tarjeta', '1');
INSERT INTO `access_control`.`opcion` (`codigo`, `descripcion`, `recurso`, `system_id`) VALUES ('Cobro', 'controlador de Cobros', 'cobro', '1');


INSERT INTO `access_control`.`rol` (`descripcion`) VALUES ('administrador');
INSERT INTO `access_control`.`rol` (`descripcion`) VALUES ('administrativo');

INSERT INTO rol_opcion (opcion_id,rol_id) SELECT o.id_opcion,1 FROM opcion o;
INSERT INTO rol_opcion (opcion_id,rol_id) SELECT o.id_opcion,2 FROM opcion o WHERE o.codigo NOT IN('Apariencia','Banco','Becas','Parametro');

INSERT INTO opcion (codigo,descripcion,recurso,opcion_padre_id,system_id)
SELECT 
   CONCAT(codigo, '_insert')
   , CONCAT('Método insert() del controlador ', codigo)
   , CONCAT(recurso, '/insert')
   , id_opcion
   , 1
FROM Opcion o
WHERE opcion_padre_id IS NULL;

INSERT INTO opcion (codigo,descripcion,recurso,opcion_padre_id,system_id)
SELECT 
   CONCAT(codigo, '_update')
   , CONCAT('Método _update() del controlador ', codigo)
   , CONCAT(recurso, '/update')
   , id_opcion
   , 1
FROM Opcion o
WHERE opcion_padre_id IS NULL;

INSERT INTO opcion (codigo,descripcion,recurso,opcion_padre_id,system_id)
SELECT 
   CONCAT(codigo, '_delete')
   , CONCAT('Método delete() del controlador ', codigo)
   , CONCAT(recurso, '/delete')
   , id_opcion
   , 1
FROM Opcion o
WHERE opcion_padre_id IS NULL;


INSERT INTO opcion (codigo,descripcion,recurso,opcion_padre_id,system_id)
SELECT 
   CONCAT(codigo, '_getByID')
   , CONCAT('Método getByID() del controlador ', codigo)
   , CONCAT(recurso, '/getByID')
   , id_opcion
   , 1
FROM Opcion o
WHERE opcion_padre_id IS NULL;

INSERT INTO opcion (codigo,descripcion,recurso,opcion_padre_id,system_id)
SELECT 
   CONCAT(codigo, '_getByFilters')
   , CONCAT('Método getByFilters() del controlador ', codigo)
   , CONCAT(recurso, '/getByFilters')
   , id_opcion
   , 1
FROM Opcion o
WHERE opcion_padre_id IS NULL;

INSERT INTO opcion (codigo,descripcion,recurso,opcion_padre_id,system_id)/*FIXME No todos los controladores tendrán este método*/
SELECT 
   CONCAT(codigo, '_getAll')
   , CONCAT('Método getAll() del controlador ', codigo)
   , CONCAT(recurso, '/getAll')
   , id_opcion
   , 1
FROM Opcion o
WHERE opcion_padre_id IS NULL;

INSERT INTO `access_control`.`opcion` (`codigo`, `descripcion`, `recurso`, `system_id`) VALUES ('Login/getPermissions', 'Metodo para listar los permisos, todos los users deben tener esta opcion', 'login/getPermissions', '1');
INSERT INTO `access_control`.`opcion` (`codigo`, `descripcion`, `recurso`, `system_id`) VALUES ('Reporte', 'Controlador de Reporte', 'reporte', '1');
INSERT INTO `access_control`.`opcion` (`codigo`, `descripcion`, `recurso`, `system_id`) VALUES ('Reporte_ListadoAlumnos', 'Reporte (jasper) de listado de alumnos', 'reporte/listadoalumnos', '1');
-- FIXME sólo para pruebas
INSERT INTO `access_control`.`opcion` (`codigo`, `descripcion`, `recurso`, `system_id`) VALUES ('Prueba', 'pruebas', 'prueba', '1');
INSERT INTO `access_control`.`opcion` (`codigo`, `descripcion`, `recurso`, `system_id`) VALUES ('Prueba', 'pruebas', 'prueba/prueba', '1');

INSERT INTO rol_opcion (opcion_id,rol_id) SELECT o.id_opcion,1 FROM opcion o WHERE NOT EXISTS(SELECT 1 FROM rol_opcion ro WHERE ro.opcion_id = o.id_opcion AND ro.rol_id = 1);
INSERT INTO rol_opcion (opcion_id,rol_id) SELECT o.id_opcion
                                             , 2 
                                       FROM opcion o 
                                                   WHERE o.codigo NOT IN('Apariencia','Banco','Becas','Parametro') 
                                          AND NOT EXISTS(SELECT 1 
                                                   FROM opcion o2 
                                                                  WHERe o.opcion_padre_id = o2.id_opcion
                                                      AND o2.codigo IN('Apariencia','Banco','Becas','Parametro'))
                                          AND NOT EXISTS(SELECT 1 
                                                   FROM rol_opcion ro 
                                                                  WHERE ro.opcion_id = o.id_opcion 
                                                                  AND ro.rol_id = 2);

INSERT INTO `access_control`.`user` (`nick`, `email`) VALUES ('abustos', 'bustosaugusto62@gmail.com');
INSERT INTO `access_control`.`user` (`nick`, `email`) VALUES ('esantillan', 'estebansantillan96@gmail.com');
INSERT INTO `access_control`.`user` (`nick`, `email`) VALUES ('udev', 'udev@testing.com');

INSERT INTO user_rol (user_id, rol_id) VALUES(1,1),(2,1),(3,2);

INSERT INTO `access_control`.`allowed_origins` (`system_id`, `origin`, `descripcion`) VALUES ('1', '*', 'FIXME solo para pruebas');

-- user: abustos, pass: abustos hash_hmac('sha512', 'abustos', 'bustosaugusto62@gmail.com')
UPDATE `access_control`.`user` SET `password`='5ffe86722fa303abd5993078b55bdd384868b5c75ac806d0edd790ae87450d4e42e72479a4256dd612047a9644a9854f55d9850437d94fd00656f957cc66272a' WHERE `id_user`='1';
-- user: esantillan, pass: esantillan hash_hmac('sha512', 'esantillan', 'estebansantillan96@gmail.com')
UPDATE `access_control`.`user` SET `password`='b8e840fe7acb42b312660f1a5b8897b432ca02459a10a563a62b1de2da006fbdc416f38cd9122bad8ae6c8fa24cb3a99e7cfb845daae874295844a3a93939e34' WHERE `id_user`='2';


