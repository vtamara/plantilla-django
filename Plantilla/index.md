---
layout: page
title: "Plantilla de proyectos Django"
description: "Como usar plantilla-django"
---

{% include JB/setup %}

plantilla-django us una plantilla de proyectos para iniciar nuevos proyectos 
en Django.  Está disponible en
[github](https://github.com/vtamara/plantilla-django)

## Acerca de ##


plantilla-django es adaptación de la plantilla [Xenith](https://github.com/xenith/django-base-template), 
que además incluye:

- Archivo de comandos que facilita instalar Django,  iniciar proyectos 
  nuevos con esta plantilla y desplegar proyectos existentes en nuevos 
  servidores.
- En la rama gh-pages esta documentación y estándares de desarrollo

La plantilla Xenith toma ideas de [Mozilla Playdoh][playdoh] 
y [Two Scoops of Django][twoscoops], pero todo el código está actualizado 
para usarse con la nueva organización de directorios y funcionalidad de 
Django 1.5

[playdoh]: https://github.com/mozilla/playdoh
[twoscoops]: https://github.com/twoscoops/django-twoscoops-project

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

- Incluye django-admin-toolbar para desarrollo y producción (habilitado para superusuarios)
- Incluye django-debug-toolbar-user-panel pero deshabilitado hasta que soporte bien Django 1.5

Pruebas:

- nose y django-nose
- pylint, pep8, y coverage

Archivos de comandos:

- bin/prepdjango.sh para:
  - instalar Apache, python, pip, django, virtualenv, virtualenvwrapper y motor de 
    base de datos en su sistema
  - iniciar proyectos y 
  - desplegar proyectos ya desarrollados en nuevos servidores.

Cualquiera de estas opciones puede añadirse, modificarse o eliminarse 
como lo prefiera tras crear su proyecto.

## Uso ##

Hemos adaptado el archivo de comados y la plantilla para que pueda comenzar a usarse sin cambios en los
siguientes sistemas:
* Ubuntu Server 12.04
* CentOS 6.2 con SELinux habilitado

### Iniciar un proyecto ###
 
Descargue de la plantilla el archivo de comandos bin/prepdjango.sh (digamos en /tmp/) y ejecutelo
desde el directorio donde iniciará la aplicación (por ejemplo /var/www) asi:

  ```sh
  cd /var/www
  chmod +x ./prepdjango.sh
  /tmp/prepdjango.sh
  ```
al hacerlo se instalaran los paquetes para desarrollar con Django y posteriormente probar el despliegue
con Apache y WSGI. A continuación este archivo de comandos le pedirá el nombre del 
proyecto y el motor de bases de datos por usar.
![por-instalar]({{BASE_PATH}}/static/img/por-instalar.png "Ejecución interactiva")

<table>
  <tr><td>
También puede ejecutarlo dando el nombre del proyecto como primer parámetro
por ejemplo: /tmp/prepdjango.sh miap
  </td></tr>
  <tr><td>
O puede especificar como segundo parámetro el motor de bases de datos por usar (los posibles son sqlite 
y oracle): sh /tmp/prepdjango.sh miap oracle
 </td></tr>
</table>

Después de esto se iniciará el servidor de prueba que podrá examinar en
[http://localhost:8000](http://localhost:8000).
Al examinar comprobará que se usa bootstrap como entorno CSS.

A continuación detenga el servidor de prueba (con Control-C) y configure aspectos generales y comunes
a servidores de desarrollo y de despliegue en miap/settings/base.py 
y las particularidades de la instalación que hace en miap/settings/local.py

En sitios de producción asegurese también de establecer SECRET_KEY 
en miap/settings/local.py diferente al de miap/settings/local-dist.py

A continuación recomendamos que suba su nuevo proyecto a un sistema de control de versiones como git.  
Incluya todos los archivos excepto miap/settings/local.py (aunque si es recomendable que 
incluya miap/settings/local-dist.py con valores por defecto).


### Desplegar un proyecto ya desarrollado con Apache y WSGI ###

Desde el directorio base de su proyecto ejecute:

  ```sh
  bin/prepdjango.sh
  ```

Esto configurará Apache para que emplee WSGI para ingresar a su aplicación desde el URL / en el puerto que
especifique.
