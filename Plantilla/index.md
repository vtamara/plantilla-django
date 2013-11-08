---
layout: page
title: "Plantilla para proyectos Django"
description: "Como usar plantilla-django"
---

{% include JB/setup %}

plantilla-django es una plantilla de proyectos para iniciar nuevos proyectos 
en Django.  Está disponible en 
[github](https://github.com/vtamara/plantilla-django)

## Acerca de ##


plantilla-django es adaptación de la plantilla 
[Xenith](https://github.com/xenith/django-base-template), 
que además incluye:

- Archivo de comandos que facilita instalar Django,  iniciar proyectos 
  nuevos con esta plantilla y desplegar proyectos existentes en nuevos 
  servidores.
- En la rama `gh-pages` encuentra esta documentación y estándares de desarrollo
- Elementos de fuentes de proyectos en Django tales como [P2PU][p2pu]

La plantilla Xenith a su vez toma ideas de [Mozilla Playdoh][playdoh] 
y [Two Scoops of Django][twoscoops], pero todo el código está actualizado 
para usarse con la nueva organización de directorios y funcionalidad de 
Django 1.5

[playdoh]: https://github.com/mozilla/playdoh
[twoscoops]: https://github.com/twoscoops/django-twoscoops-project
[p2pu]: https://github.com/p2pu/lernanta

## Características ##

Incluye:


Entornos HTML,  CSS y plantillas:

- HTML5Boilerplate 4.1.0 
- Twitter Bootstrap 2.3.1 
- Markdown
- django_compressor para comprimir javascript/css/less/sass

Seguridad:

- bleach
- python-bcrypt2 - usa bcrypt para condensados de claves por defecto

Tareas en segundo plano:

- Celery

Migraciones:

- South

Colchones (Caching):

- python-memcached

Administración:

- Incluye django-admin-toolbar para desarrollo y producción (habilitado 
  para superusuarios)
- Incluye django-debug-toolbar-user-panel pero deshabilitado hasta 
  que soporte bien Django 1.5

Pruebas:

- nose y django-nose
- pylint, pep8, y coverage

Desarrollo:
- vagrant 

Archivos de comandos:

- bin/prepdjango.sh para:
  - instalar Apache, python, pip, django, virtualenv, virtualenvwrapper 
    y motor de base de datos en su sistema
  - iniciar proyectos y 
  - desplegar proyectos ya desarrollados en nuevos servidores.

Cualquiera de estas opciones puede añadirse, modificarse o eliminarse 
como lo prefiera tras crear su proyecto.

## Uso ##

Hemos adaptado el archivo de comados y la plantilla para que pueda 
comenzar a usarse sin cambios en los siguientes sistemas:

- Ubuntu Server 12.04
- CentOS 6.2 con SELinux habilitado

### Iniciar un proyecto ###
 
Descargue de la plantilla el archivo de comandos bin/prepdjango.sh 
(digamos en /tmp/) y ejecutelo desde el directorio donde iniciará la 
aplicación (por ejemplo /var/www) asi:

  ```sh
  cd /tmp/
  wget https://raw.github.com/vtamara/plantilla-django/master/bin/prepdjango.sh
  chmod +x ./prepdjango.sh
  sudo mkdir -p /var/www
  cd /var/www
  /tmp/prepdjango.sh
  ```
al hacerlo se instalaran los paquetes para desarrollar con Django y 
posteriormente probar el despliegue con Apache y WSGI. 

![por-instalar]({{BASE_PATH}}/static/img/por-instalar.png "Ejecución interactiva")

A continuación este archivo de comandos le pedirá el nombre del proyecto 
y el motor de bases de datos por usar.  


> También puede ejecutarlo dando el nombre del proyecto como primer parámetro
> por ejemplo: `/tmp/prepdjango.sh miap` 
> 
> O puede especificar como segundo parámetro el motor de bases de datos por 
> usar (los posibles son sqlite y oracle):  `/tmp/prepdjango.sh miap oracle`

Después de esto puede comenzar a editar el proyecto con las instrucciones que verá.
La primera vez ejecute `. ~/.bashrc` a continuación y en sesiones posteriores:
```sh
  mkvirtualenv miap --system-site-packages 
  workon miap 
  cd miap 
```

Recién creado el proyecto especifique base de datos, usuario y clave en 'ap/settings/local.py'
y a continuación prepara una base de datos y un sistema de autenticación y administración mínimo con:
```sh
  ./manage.py syncdb 
  ./manage.py migrate 
```

Inicie el servidor de prueba con `./manage.py runserver` y con un navegador examine:
[http://localhost:8000](http://localhost:8000).

![recieninstalado]({{BASE_PATH}}/static/img/recieninstalado.png "Sitio recién instalado")

Comprobará que se usa bootstrap de Twitter como entorno CSS. 


Empleando el superusuario que creo cuando inicializó la base de datos podrá ingresar 
a la interfaz administrativa mínima generada desde:
[http://localhost:8000/admin/](http://localhost:8000/admin/).

![minadmin]({{BASE_PATH}}/static/img/minadmin.png "Interfaz administrativa mínima")

Puede detener el servidor de prueba (con Control-C) y configurar
aspectos generales y comunes a servidores de desarrollo y de despliegue en `miap/settings/base.py`
y las particularidades de la instalación que hace en `miap/settings/local.py`
replicando cambios a ese archivo en `miap/settings/local-dist.py`

Recomendamos que suba su nuevo proyecto a un sistema de control de versiones 
como git.  
Incluya todos los archivos excepto `miap/settings/local.py` (pero
incluya `miap/settings/local-dist.py` con valores por 
defecto que guien cambios por aplicar a `miap/settings/local.py`).


### Desplegar un proyecto ya desarrollado con Apache y WSGI ###

Desde el directorio base de su proyecto ejecute:

  ```sh
  bin/prepdjango.sh
  ```

Esto configurará Apache para que emplee WSGI para ingresar a su aplicación 
desde el URL / en el puerto que especifique.

En cada sitio de producción establezca SECRET_KEY 
de miap/settings/local.py diferente al de miap/settings/local-dist.py


### Desarrollar con vagrant y virtualbox

vagrant maneja máquinas virtuales desde la línea de comandos automatizando
la creación de cajas (boxes) de desarrollo o donde podrá probar el despliegue.

Desde el directorio de una aplicación inicie una máquina virtual de desarrollo
con
```vagrant up```
puede monitorear abriendo virtualbox
La primera vez se descargará una máquina virtual mínima.

Una vez suba y esté preparada su máquina virtual, quedaran redireccionados
puertos así:
- 80 al 8080 de su sistema
- 8000 al 8001
- 90 al 8090
- 443 al 8443
- 22 al 2222
Puede ingresar a la caja  de desarrollo con:
```vagrant ssh```

En la caja el usuario vagrant tendrá un directorio `project`
que es compartido con su directorio de trabajo --los cambios que haga en
cualquiera de los dos se ven en el otro.

Avance en el desarrollo y bien pruebe con el servidor web de django:
```./manage.py runserver```
Y examine en su computador en el puerto 8001 o bien despliegue con
Apache y WSGI en el puerto 90 y examine en su computador en el puerto 8090
o despliegue en el puerto 443 y examine en su computaodr en el puerto 8443.


