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


plantilla-django es adaptación de la plantilla [Xenith](https://github.com/xenith/django-base-template), que además incluye:

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
- Incluye django-debug-toolbar-user-panel, que es bien util, pero deshabilitado hasta que soporte bien Django 1.5

Pruebas:

- nose y django-nose
- pylint, pep8, y coverage

Archivos de comandos:

- bin/prepdjango.sh para:
  - instalar Apache, python, pip, django, virtualenv, virtualenvwrapper y motor de 
    base de datos en su sistema
  - para iniciar proyectos y 
  - para desplegar proyectos en nuevos servidores.

Cualquiera de estas opciones puede añadirse, modificarse o eliminarse 
como lo prefiera tras crear su proyecto.

## Uso ##

Desde un Ubuntu 12.04 descargue de la plantilla el archivo de comandos 
bin/prepdjango.sh y ejecutelo asi:

  ```sh
  chmod +x ./prepdjango.sh
  ./prepdjango.sh
  ```
con esto ingresará a una interfaz con menus que le pedirá el nombre del 
proyecto y el motor de bases de datos por usar.
![por-instalar]({{BASE_PATH}}/static/img/por-instalar.png "Ejecución interactiva")
También puede ejecutarlo dando el nombre del proyecto como primer parámetro
por ejemplo: 

  ```sh
  ./prepdjango.sh miap
  ```

O puede especificar como segundo parámetro el motor de bases de datos por usar (los posibles son sqlite y oracle): 

  ```sh
  ./prepdjango.sh miap oracle
  ```

Después de esto se iniciará el servidor de prueba que podrá examinar en [http://localhost:8000](http://localhost:8000)

Es importante que lo detenga y configure aspectos generales y comunes
a servidores de desarrollo y de despliegue en proyecto/settings/base.py 
y las particularidades de la instalación que hace en 
proyecto/settings/local.py (el cual no se incluye en el control de
versiones, pero se copia de local-dist.py que si se incluye).

En sitios de producción asegurese también de establecer SECRET_KEY 
en proyecot/settings/local.py diferente al de proyecto/settings/local-dist.py

There isn't a need to add settings/local.py to your source control, but there are multiple schools of thought on this. The method I use here is an example where each developer has their own settings/local.py with machine-specific settings. You will also need to create a version of settings/local.py for use in deployment that you will put into place with your deployment system (Fabric, chef, puppet, etc).

The second school of thought is that all settings should be versioned, so that as much of the code/settings as possible is the same across all developers and test/production servers. If you prefer this method, then make sure *all* necessary settings are properly set in settings/base.py, and then edit settings/__init__.py so it no longer reraises the exception. (ie, by replacing 'raise' with 'pass'). As it is, settings/local.py should only be overriding settings from settings/base.py anyway. (You could also just set the DJANGO_SETTINGS_MODULE environment variable to "{{ project_name }}.settings.base" directly.)

