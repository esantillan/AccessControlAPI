DROP DATABASE IF EXISTS access_control;
SET NAMES 'UTF8';
CREATE DATABASE access_control DEFAULT CHARACTER SET utf8 COLLATE utf8_spanish_ci;

USE access_control;


CREATE TABLE sistema(
   id_sistema INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
   descripcion VARCHAR(255) NOT NULL,
   codigo VARCHAR(50) NOT NULL,
   version VARCHAR(20) NOT NULL,
   baja BOOLEAN NOT NULL DEFAULT FALSE
)ENGINE=INNODB CHARSET utf8 COLLATE utf8_spanish_ci;

CREATE TABLE allowed_origins(
   id_allowed_origins INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
   sistema_id INT UNSIGNED,
   origin VARCHAR(255) NOT NULL,
   descripcion VARCHAR(255),
   baja BOOLEAN NOT NULL DEFAULT FALSE,
   CONSTRAINT fk_allowedorigins_sistema FOREIGN KEY (sistema_id) REFERENCES sistema(id_sistema) ON UPDATE CASCADE ON DELETE RESTRICT
)ENGINE=INNODB CHARSET utf8 COLLATE utf8_spanish_ci;

CREATE TABLE opcion(
   id_opcion INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
   codigo VARCHAR(50) NOT NULL,
   descripcion VARCHAR(255) NOT NULL,
   recurso VARCHAR(255) NOT NULL,
   opcion_padre_id INT UNSIGNED,
   sistema_id INT UNSIGNED,
   baja BOOLEAN NOT NULL DEFAULT FALSE,
   CONSTRAINT fk_opcion_sistema FOREIGN KEY (sistema_id) REFERENCES sistema(id_sistema) ON UPDATE CASCADE ON DELETE RESTRICT,
   CONSTRAINT fk_opcion_padre FOREIGN KEY (opcion_padre_id) REFERENCES Opcion(id_opcion) ON UPDATE CASCADE ON DELETE RESTRICT
)ENGINE=INNODB CHARSET utf8 COLLATE utf8_spanish_ci;

CREATE TABLE rol(
   id_rol INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
   descripcion VARCHAR(255) NOT NULL,
   baja BOOLEAN NOT NULL DEFAULT FALSE
)ENGINE=INNODB CHARSET utf8 COLLATE utf8_spanish_ci;

CREATE TABLE rol_opcion(
   id_rol_opcion INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
   opcion_id INT UNSIGNED,
   rol_id INT UNSIGNED,
   baja BOOLEAN NOT NULL DEFAULT FALSE,
   CONSTRAINT fk_rol_opcion_rol FOREIGN KEY (rol_id) REFERENCES rol(id_rol) ON UPDATE CASCADE ON DELETE RESTRICT,
   CONSTRAINT fk_rolopcion_opcion FOREIGN KEY (opcion_id) REFERENCES opcion(id_opcion) ON UPDATE CASCADE ON DELETE RESTRICT
)ENGINE=INNODB CHARSET utf8 COLLATE utf8_spanish_ci;

CREATE TABLE usuario(
   id_usuario INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
   nick VARCHAR(255) NOT NULL,
   email varchar(100) NOT NULL,
   `password` VARCHAR(128) BINARY,
   baja BOOLEAN NOT NULL DEFAULT FALSE)ENGINE=INNODB CHARSET utf8 COLLATE utf8_spanish_ci;


CREATE TABLE usuario_rol(
   id_usuario_rol INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
   usuario_id INT UNSIGNED,
   rol_id INT UNSIGNED,
   baja BOOLEAN NOT NULL DEFAULT FALSE,
   CONSTRAINT fk_usuariorol_usuario FOREIGN KEY (usuario_id) REFERENCES usuario(id_usuario) ON UPDATE CASCADE ON DELETE RESTRICT,
   CONSTRAINT fk_usuariorol_rol FOREIGN KEY (rol_id) REFERENCES rol(id_rol) ON UPDATE CASCADE ON DELETE RESTRICT
)ENGINE=INNODB CHARSET utf8 COLLATE utf8_spanish_ci;

CREATE FULLTEXT INDEX indx_usuario_email ON usuario (email);
CREATE FULLTEXT INDEX indx_usuario_nick ON usuario (nick);

CREATE FULLTEXT INDEX indx_opcion_recurso ON opcion (recurso);
CREATE FULLTEXT INDEX indx_opcion_codigo ON opcion (codigo);

CREATE FULLTEXT INDEX indx_sistema_codigo ON sistema(codigo);

/**
* Vista de usuarios: las apis externas obtendrán resultados de esta vista, en lugar de la propia tabla
* NOTA: 
*     . Detallo los campos (de forma explícita) para evitar compartir la contraseña
*     . El campo baja no es necesario que lo vean las apis externas
*/
CREATE ALGORITHM = MERGE VIEW v_usuario_opciones
AS
SELECT 
	u.id_usuario
	, nick
    , email
    , ur.id_usuario_rol
    , r.id_rol
    , r.descripcion AS descripcion_rol
    , ro.id_rol_opcion
    , o.id_opcion
    , o.codigo AS codigo_opcion
    , o.descripcion AS descripcion_opcion
    , o.recurso
    , s.id_sistema
    , s.codigo AS codigo_sistema
    , s.descripcion AS descripcion_sistema
FROM usuario u
	JOIN usuario_rol ur ON ur.usuario_id = u.id_usuario
	JOIN rol r ON ur.rol_id = r.id_rol
    JOIN rol_opcion ro ON ro.rol_id = r.id_rol
    JOIN opcion o ON ro.opcion_id = o.id_opcion
    JOIN sistema s ON o.sistema_id = s.id_sistema
WHERE u.baja = FALSE
	AND ur.baja = FALSE
    AND ro.baja = FALSE
    AND o.baja = FALSE
    AND s.baja = FALSE;


/*************************************************************
*  Tablas de Auditoría                                       *
*************************************************************/
CREATE TABLE audit_sistema(
   id_audit_sistema INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
	id_sistema INT UNSIGNED,
	descripcion VARCHAR(255),
	codigo VARCHAR(50),
	version VARCHAR(20),
	baja BOOLEAN DEFAULT FALSE,
   operacion CHAR(1) NOT NULL,
   usuario_bd VARCHAR(100) NOT NULL COMMENT 'usuario de base de datos con el que se conectó la API externa',
   fecha TIMESTAMP  NOT NULL DEFAULT CURRENT_TIMESTAMP
)ENGINE=MYISAM CHARSET utf8 COLLATE utf8_spanish_ci;

CREATE TABLE audit_allowed_origins(
   id_audit_allowed_origins INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
   id_allowed_origins INT UNSIGNED,
   sistema_id INT UNSIGNED,
   origin VARCHAR(255) NOT NULL,
   descripcion VARCHAR(255),
   baja BOOLEAN NOT NULL DEFAULT FALSE,
   operacion CHAR(1) NOT NULL,
   usuario_bd VARCHAR(100) NOT NULL COMMENT 'usuario de base de datos con el que se conectó la API externa',
   fecha TIMESTAMP  NOT NULL DEFAULT CURRENT_TIMESTAMP
)ENGINE=INNODB CHARSET utf8 COLLATE utf8_spanish_ci;

CREATE TABLE audit_opcion(
   id_audit_opcion INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
	id_opcion INT UNSIGNED,
	codigo VARCHAR(50),
	descripcion VARCHAR(255),
	recurso VARCHAR(255),
	opcion_padre_id INT UNSIGNED,
	sistema_id INT UNSIGNED,
	baja BOOLEAN DEFAULT FALSE,
   operacion CHAR(1) NOT NULL,
   usuario_bd VARCHAR(100) NOT NULL COMMENT 'usuario de base de datos con el que se conectó la API externa',
   fecha TIMESTAMP  NOT NULL DEFAULT CURRENT_TIMESTAMP
)ENGINE=MYISAM CHARSET utf8 COLLATE utf8_spanish_ci;

CREATE TABLE audit_rol(
   id_audit_rol INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
	id_rol INT UNSIGNED,
	descripcion VARCHAR(255),
	baja BOOLEAN DEFAULT FALSE,
   operacion CHAR(1) NOT NULL,
   usuario_bd VARCHAR(100) NOT NULL COMMENT 'usuario de base de datos con el que se conectó la API externa',
   fecha TIMESTAMP  NOT NULL DEFAULT CURRENT_TIMESTAMP
)ENGINE=MYISAM CHARSET utf8 COLLATE utf8_spanish_ci;

CREATE TABLE audit_rol_opcion(
   id_audit_rol_opcion INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
	id_rol_opcion INT UNSIGNED,
	opcion_id INT UNSIGNED,
	rol_id INT UNSIGNED,
	baja BOOLEAN DEFAULT FALSE,
   operacion CHAR(1) NOT NULL,
   usuario_bd VARCHAR(100) NOT NULL COMMENT 'usuario de base de datos con el que se conectó la API externa',
   fecha TIMESTAMP  NOT NULL DEFAULT CURRENT_TIMESTAMP
)ENGINE=MYISAM CHARSET utf8 COLLATE utf8_spanish_ci;

CREATE TABLE audit_usuario(
   id_audit_usuario INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
	id_usuario INT UNSIGNED,
	nick VARCHAR(255),
	email varchar(100),
	`password` VARCHAR(128) BINARY,
	baja BOOLEAN DEFAULT FALSE,
   operacion CHAR(1) ,
   usuario_bd VARCHAR(100) COMMENT 'usuario de base de datos con el que se conectó la API externa',
   fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)ENGINE=MYISAM CHARSET utf8 COLLATE utf8_spanish_ci; 

CREATE TABLE audit_usuario_rol(
   id_audit_usuario_rol INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
   id_usuario_rol INT UNSIGNED,
   usuario_id INT UNSIGNED,
   rol_id INT UNSIGNED,
   baja BOOLEAN DEFAULT FALSE,
   operacion CHAR(1) NOT NULL,
   usuario_bd VARCHAR(100) NOT NULL COMMENT 'usuario de base de datos con el que se conectó la API externa',
   fecha TIMESTAMP  NOT NULL DEFAULT CURRENT_TIMESTAMP
)ENGINE=MYISAM CHARSET utf8 COLLATE utf8_spanish_ci;

/*************************************************
* Triggers para usuario                          *
*************************************************/
DELIMITER $$

CREATE TRIGGER tr_usuario_ai AFTER INSERT ON usuario
FOR EACH ROW
BEGIN
	INSERT INTO audit_usuario (
		id_usuario
      , nick
      , email
      , `password`
      , baja
      , operacion
      , usuario_bd
	) VALUES(
		NEW.id_usuario
      , NEW.nick
      , NEW.email
      , NEW.`password`
      , NEW.baja
      , 'I'
      , CURRENT_USER()
	);
END; $$

DELIMITER ;


DELIMITER $$

CREATE TRIGGER tr_usuario_au AFTER UPDATE ON usuario
FOR EACH ROW
BEGIN
	INSERT INTO audit_usuario (
		id_usuario
      , nick
      , email
      , `password`
      , baja
      , operacion
      , usuario_bd
	) VALUES(
		NEW.id_usuario
      , NEW.nick
      , NEW.email
      , NEW.`password`
      , NEW.baja
      , 'U'
      , CURRENT_USER()
	);
END; $$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER tr_usuario_ad AFTER DELETE ON usuario
FOR EACH ROW
BEGIN
	INSERT INTO audit_usuario (
		id_usuario
      , nick
      , email
      , `password`
      , baja
      , operacion
      , usuario_bd
	) VALUES(
		OLD.id_usuario
      , OLD.nick
      , OLD.email
      , OLD.`password`
      , OLD.baja
      , 'D'
      , CURRENT_USER()
	);
END; $$

DELIMITER ;

/*************************************************
* Triggers para usuario_rol                      *
*************************************************/
DELIMITER $$

CREATE TRIGGER tr_usuario_rol_ai AFTER INSERT ON usuario_rol
FOR EACH ROW
BEGIN
	INSERT INTO audit_usuario_rol (
		id_usuario_rol
		, usuario_id
      , rol_id
      , baja
      , operacion
      , usuario_bd
	) VALUES(
		NEW.id_usuario_rol
      , NEW.usuario_id
      , NEW.rol_id
      , NEW.baja
      , 'I'
      , CURRENT_USER()
	);
END; $$

DELIMITER ;


DELIMITER $$

CREATE TRIGGER tr_usuario_rol_au AFTER UPDATE ON usuario_rol
FOR EACH ROW
BEGIN
	INSERT INTO audit_usuario_rol (
		id_usuario_rol
		, usuario_id
      , rol_id
      , baja
      , operacion
      , usuario_bd
	) VALUES(
		NEW.id_usuario_rol
      , NEW.usuario_id
      , NEW.rol_id
      , NEW.baja
      , 'U'
      , CURRENT_USER()
	);
END; $$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER tr_usuario_rol_ad AFTER DELETE ON usuario_rol
FOR EACH ROW
BEGIN
	INSERT INTO audit_usuario_rol (
		id_usuario_rol
		, usuario_id
      , rol_id
      , baja
      , operacion
      , usuario_bd
	) VALUES(
      OLD.id_usuario_rol
      , OLD.usuario_id
      , OLD.rol_id
      , OLD.baja
      , 'D'
      , CURRENT_USER()
	);
END; $$

DELIMITER ;



/*************************************************
* Triggers para sistema                          *
*************************************************/
DELIMITER $$

CREATE TRIGGER tr_sistema_ai AFTER INSERT ON sistema
FOR EACH ROW
BEGIN
	INSERT INTO audit_sistema (
		id_sistema
		, descripcion
      , codigo
      , `version`
      , baja
      , operacion
      , usuario_bd
	) VALUES(
		NEW.id_sistema
      , NEW.descripcion
      , NEW.codigo
      , NEW.`version`
      , NEW.baja
      , 'I'
      , CURRENT_USER()
	);
END; $$

DELIMITER ;


DELIMITER $$

CREATE TRIGGER tr_sistema_au AFTER UPDATE ON sistema
FOR EACH ROW
BEGIN
	INSERT INTO audit_sistema (
		id_sistema
		, descripcion
      , codigo
      , `version`
      , baja
      , operacion
      , usuario_bd
	) VALUES(
		NEW.id_sistema
      , NEW.descripcion
      , NEW.codigo
      , NEW.`version`
      , NEW.baja
      , 'U'
      , CURRENT_USER()
	);
END; $$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER tr_sistema_ad AFTER DELETE ON sistema
FOR EACH ROW
BEGIN
	INSERT INTO audit_sistema (
		id_sistema
		, descripcion
      , codigo
      , `version`
      , baja
      , operacion
      , usuario_bd
	) VALUES(
      OLD.id_sistema
      , OLD.descripcion
      , OLD.codigo
      , OLD.`version`
      , OLD.baja
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
      , baja
      , operacion
      , usuario_bd
	) VALUES(
		NEW.id_rol_opcion
      , NEW.opcion_id
      , NEW.rol_id
      , NEW.baja
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
      , baja
      , operacion
      , usuario_bd
	) VALUES(
		NEW.id_rol_opcion
      , NEW.opcion_id
      , NEW.rol_id
      , NEW.baja
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
      , baja
      , operacion
      , usuario_bd
	) VALUES(
      OLD.id_rol_opcion
      , OLD.opcion_id
      , OLD.rol_id
      , OLD.baja
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
      , baja
      , operacion
      , usuario_bd
	) VALUES(
		NEW.id_rol
      , NEW.descripcion
      , NEW.baja
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
      , baja
      , operacion
      , usuario_bd
	) VALUES(
		NEW.id_rol
      , NEW.descripcion
      , NEW.baja
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
      , baja
      , operacion
      , usuario_bd
	) VALUES(
      OLD.id_rol
      , OLD.descripcion
      , OLD.baja
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
      , sistema_id
      , baja
      , operacion
      , usuario_bd
	) VALUES(
		NEW.id_opcion
      , NEW.codigo
      , NEW.descripcion
      , NEW.recurso
      , NEW.opcion_padre_id
      , NEW.sistema_id
      , NEW.baja
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
      , sistema_id
      , baja
      , operacion
      , usuario_bd
	) VALUES(
		NEW.id_opcion
      , NEW.codigo
      , NEW.descripcion
      , NEW.recurso
      , NEW.opcion_padre_id
      , NEW.sistema_id
      , NEW.baja
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
      , sistema_id
      , baja
      , operacion
      , usuario_bd
	) VALUES(
      OLD.id_opcion
      , OLD.codigo
      , OLD.descripcion
      , OLD.recurso
      , OLD.opcion_padre_id
      , OLD.sistema_id
      , OLD.baja
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
      , sistema_id
	  , origin
      , descripcion
      , baja
      , operacion
      , usuario_bd
	) VALUES(
		NEW.id_allowed_origins
      , NEW.sistema_id
      , NEW.origin
      , NEW.descripcion
      , NEW.baja
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
      , sistema_id
	  , origin
      , descripcion
      , baja
      , operacion
      , usuario_bd
	) VALUES(
		NEW.id_allowed_origins
      , NEW.sistema_id
      , NEW.origin
      , NEW.descripcion
      , NEW.baja
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
      , sistema_id
	  , origin
      , descripcion
      , baja
      , operacion
      , usuario_bd
	) VALUES(
      OLD.id_allowed_origins
      , OLD.sistema_id
      , OLD.origin
      , OLD.descripcion
      , OLD.baja
      , 'D'
      , CURRENT_USER()
	);
END; $$

DELIMITER ;
/*****************************************************
* Inserts                                            *
******************************************************/
INSERT INTO `access_control`.`sistema` (`descripcion`, `codigo`, `version`) VALUES ('Sistema de cuotas online', 'siscuota_online', '1.0.0');

INSERT INTO `access_control`.`opcion` (`codigo`, `descripcion`, `recurso`, `sistema_id`) VALUES ('Alumno', 'controlador de alumnos', 'alumno', '1');
INSERT INTO `access_control`.`opcion` (`codigo`, `descripcion`, `recurso`, `sistema_id`) VALUES ('Apariencia', 'controlador de apariencia', 'apariencia', '1');
INSERT INTO `access_control`.`opcion` (`codigo`, `descripcion`, `recurso`, `sistema_id`) VALUES ('Bancos', 'controlador de bancos', 'bancos', '1');
INSERT INTO `access_control`.`opcion` (`codigo`, `descripcion`, `recurso`, `sistema_id`) VALUES ('Becas', 'controlador de becas', 'becas', '1');
INSERT INTO `access_control`.`opcion` (`codigo`, `descripcion`, `recurso`, `sistema_id`) VALUES ('CertificadoAnalitico', 'controlador de certificado_analitico', 'certificado_analitico', '1');
INSERT INTO `access_control`.`opcion` (`codigo`, `descripcion`, `recurso`, `sistema_id`) VALUES ('Ciclo', 'controlador de ciclo', 'ciclo', '1');
INSERT INTO `access_control`.`opcion` (`codigo`, `descripcion`, `recurso`, `sistema_id`) VALUES ('CicloReserva', 'controlador de cicloReserva', 'ciclo_reserva', '1');
INSERT INTO `access_control`.`opcion` (`codigo`, `descripcion`, `recurso`, `sistema_id`) VALUES ('Curso', 'controlador de curso', 'curso', '1');
INSERT INTO `access_control`.`opcion` (`codigo`, `descripcion`, `recurso`, `sistema_id`) VALUES ('Deudores', 'controlador de deudores', 'deudores', '1');
INSERT INTO `access_control`.`opcion` (`codigo`, `descripcion`, `recurso`, `sistema_id`) VALUES ('Division', 'controlador de Division', 'division', '1');
INSERT INTO `access_control`.`opcion` (`codigo`, `descripcion`, `recurso`, `sistema_id`) VALUES ('Pagos', 'controlador de Pagos', 'pagos', '1');
INSERT INTO `access_control`.`opcion` (`codigo`, `descripcion`, `recurso`, `sistema_id`) VALUES ('Parametros', 'controlador de Parametros', 'parametros', '1');
INSERT INTO `access_control`.`opcion` (`codigo`, `descripcion`, `recurso`, `sistema_id`) VALUES ('PermisoExamen', 'controlador de PermisoExamen', 'permiso_examen', '1');
INSERT INTO `access_control`.`opcion` (`codigo`, `descripcion`, `recurso`, `sistema_id`) VALUES ('ReservaVacante', 'controlador de ReservaVacante', 'reserva_vacante', '1');


INSERT INTO `access_control`.`rol` (`descripcion`) VALUES ('administrador');
INSERT INTO `access_control`.`rol` (`descripcion`) VALUES ('administrativo');

INSERT INTO rol_opcion (opcion_id,rol_id) SELECT o.id_opcion,1 FROM opcion o;
INSERT INTO rol_opcion (opcion_id,rol_id) SELECT o.id_opcion,2 FROM opcion o WHERE o.codigo NOT IN('Apariencia','Bancos','Becas','Parametros');

INSERT INTO opcion (codigo,descripcion,recurso,opcion_padre_id,sistema_id)
SELECT 
   CONCAT(codigo, '_insert')
   , CONCAT('Método insert() del controlador ', codigo)
   , CONCAT(recurso, '/insert')
   , id_opcion
   , 1
FROM Opcion o
WHERE opcion_padre_id IS NULL;

INSERT INTO opcion (codigo,descripcion,recurso,opcion_padre_id,sistema_id)
SELECT 
   CONCAT(codigo, '_update')
   , CONCAT('Método _update() del controlador ', codigo)
   , CONCAT(recurso, '/update')
   , id_opcion
   , 1
FROM Opcion o
WHERE opcion_padre_id IS NULL;

INSERT INTO opcion (codigo,descripcion,recurso,opcion_padre_id,sistema_id)
SELECT 
   CONCAT(codigo, '_delete')
   , CONCAT('Método delete() del controlador ', codigo)
   , CONCAT(recurso, '/delete')
   , id_opcion
   , 1
FROM Opcion o
WHERE opcion_padre_id IS NULL;


INSERT INTO opcion (codigo,descripcion,recurso,opcion_padre_id,sistema_id)
SELECT 
   CONCAT(codigo, '_getByID')
   , CONCAT('Método getByID() del controlador ', codigo)
   , CONCAT(recurso, '/getByID')
   , id_opcion
   , 1
FROM Opcion o
WHERE opcion_padre_id IS NULL;

INSERT INTO opcion (codigo,descripcion,recurso,opcion_padre_id,sistema_id)
SELECT 
   CONCAT(codigo, '_getByFilters')
   , CONCAT('Método getByFilters() del controlador ', codigo)
   , CONCAT(recurso, '/getByFilters')
   , id_opcion
   , 1
FROM Opcion o
WHERE opcion_padre_id IS NULL;


INSERT INTO rol_opcion (opcion_id,rol_id) SELECT o.id_opcion,1 FROM opcion o WHERE NOT EXISTS(SELECT 1 FROM rol_opcion ro WHERE ro.opcion_id = o.id_opcion AND ro.rol_id = 1);
INSERT INTO rol_opcion (opcion_id,rol_id) SELECT o.id_opcion
                                             , 2 
                                       FROM opcion o 
                                                   WHERE o.codigo NOT IN('Apariencia','Bancos','Becas','Parametros') 
                                          AND NOT EXISTS(SELECT 1 
                                                   FROM opcion o2 
                                                                  WHERe o.opcion_padre_id = o2.id_opcion
                                                      AND o2.codigo IN('Apariencia','Bancos','Becas','Parametros'))
                                          AND NOT EXISTS(SELECT 1 
                                                   FROM rol_opcion ro 
                                                                  WHERE ro.opcion_id = o.id_opcion 
                                                                  AND ro.rol_id = 2);

INSERT INTO `access_control`.`usuario` (`nick`, `email`) VALUES ('abustos', 'bustosaugusto62@gmail.com');
INSERT INTO `access_control`.`usuario` (`nick`, `email`) VALUES ('esantillan', 'estebansantillan96@gmail.com');
INSERT INTO `access_control`.`usuario` (`nick`, `email`) VALUES ('udev', 'udev@testing.com');

INSERT INTO usuario_rol (usuario_id, rol_id) VALUES(1,1),(2,1),(3,2);

INSERT INTO `access_control`.`allowed_origins` (`sistema_id`, `origin`, `descripcion`) VALUES ('1', '*', 'FIXME solo para pruebas');

-- user: abustos, pass: abustos hash_hmac('sha512', 'abustos', 'bustosaugusto62@gmail.com')
UPDATE `access_control`.`usuario` SET `password`='5ffe86722fa303abd5993078b55bdd384868b5c75ac806d0edd790ae87450d4e42e72479a4256dd612047a9644a9854f55d9850437d94fd00656f957cc66272a' WHERE `id_usuario`='1';
-- user: esantillan, pass: esantillan hash_hmac('sha512', 'esantillan', 'estebansantillan96@gmail.com')
UPDATE `access_control`.`usuario` SET `password`='b8e840fe7acb42b312660f1a5b8897b432ca02459a10a563a62b1de2da006fbdc416f38cd9122bad8ae6c8fa24cb3a99e7cfb845daae874295844a3a93939e34' WHERE `id_usuario`='2';
