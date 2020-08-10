# RESTFUL API para el Control de Acceso utilizando JWT

Author: Esteban Santilán

API desarrollada con el framework CodeIgniter utilizando la librería de Cris kacerguis "CodeIgniter RestServer" y basado en el proyecto de Ruslan Gonzales "RESTFUL API with CodeIgniter"

### Lista de tareas de características para esta API

#### DB
- [x] tables & views
- [x] constraints & indices
- [x] tablas de auditoría & triggers
- [x] algo de informacion para poder comenzar a desarrollar la api
- [ ] Añadir rol y opciones para ver registros de auditoría (readonly)
- [ ] ir añadiendo opciones a medida que desarrolle la API de sistema de coutas
- [ ] crear usuario para la API (dejar de usar "root")
- [ ] crear usuario para la API del sistema de cuotas
- [ ] script para crear usuarios y asignarle permisos mínimos sobre la bd access_control

#### Configuracion del proyecto
- [x] sanitize_string: metodo ubicado en sanitizer_helper, que sanea strings (el método xss() de CI no se puede utilizar para contraseñas y ha sido eliminado en CI4, por lo que hay que evitar su uso)
- [x] adaptacion de la libreria para trabajar con JWT: para facilitar las pruebas con PostMan, modifiqué Authorization_Token para quitar la palabra "Bearer" y el espacio (ya que esto produce errores al intentar leer ese "prefijo" como parte del JWT)
- [x] Configuraciones inciales del proyecto: deshabilite el uso de la "api keys" y "log" del proyecto como elimine archivos del proyecto de ruslan que no utilizaré (como controladores y helpers)
- [ ] Quitar carpeta "user_guide"
- [ ] Quitar controlador y vista "Welcome"
- [ ] Establecer controlador "Usuario" como predeterminado
- [ ] Establecer la constante ENVIROMENT en "production" antes del deploy

#### Métodos API
- [x] token (login): para obtener JWT a partir del username (nick o email) y la contraseña
- [x] checkPermission: comprueba si se tiene permiso para acceder al $resource proporcionado como parámetro (primero valida el token)
- [x] getPermissions: a partir del parámetro $system  y del $user->id_user (que se encuentra en el JWT) retornar todos los permisos (primero valida el token)
- [ ] Crear métodos ABM para c/u de las tablas (excepto auditoría)
- [ ] Crear métodos para ver registros de auditoría
- [ ] agregar método index al controlador de "Usuario"
- [ ] Modification timestamps/ Search by criteria
- [ ] Crear método para crear usuario (a nivel de sql, con los permisos mínimos)

### Créditos
* [CI Framework](https://codeigniter.com/)
* [@Klerith](https://github.com/Klerith)
* [@chriskacerguis](https://github.com/chriskacerguis/codeigniter-restserver)
* [@Ruslan Gonzalez](https://github.com/ruslanguns/codeigniter-restful)
