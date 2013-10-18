---
layout: page
title: "Plantilla para proyectos con Django"
description: ""
---

{% include JB/setup %}

## Acerca de ##

Esta plantilla de proyectos es traducción a español y adaptación de la
plantilla Xenith (licencia BSD):

https://github.com/xenith/django-base-template

Con financiación de Sofhouse también incluimos (dominio público):
* En directorio bin archivos de comandos que facilitan iniciar proyectos 
  nuevos con esta plantilla y desplegar proyectos existentes en nuevos 
  servidores.
* Estándares de programación en docs/estandares.md

La plantilla Xenith es para Django 1.5 y se basa especialmente 
en [Mozilla Playdoh][playdoh] y [Two Scoops of Django][twoscoops].

Según el autor de la plantilla Xenith todo el código está actualizado
para usarse con la nueva organización de directorios y funcionalidad 
de Django 1.5

[playdoh]: https://github.com/mozilla/playdoh
[twoscoops]: https://github.com/twoscoops/django-twoscoops-project

## Características ##

Por defecto, esta plantilla de proyectos incluye:

Un conjunto de plantillas básicas construidas con HTML5Boilerplate 4.1.0 y
Twitter Bootstrap 2.3.1 (localizadas en la aplicación base).

Plantillas:

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

Cualquiera de estas opciones puede añadirse, modificarse o eliminarse 
como lo prefiera tras crear su proyecto.

## Como emplear esta plantilla de proyectos para crear su proyecto ##

- Create your working environment and virtualenv
- Install Django 1.5 ($ pip install Django>=1.5)
- $ django-admin.py startproject --template https://github.com/xenith/django-base-template/zipball/master --extension py,md,rst projectname
- $ cd projectname
- Uncomment your preferred database adapter in requirements/compiled.txt (MySQL, Postgresql, or skip this step to stick with SQLite)
- $ pip install -r requirements/local.txt
- $ cp projectname/settings/local-dist.py projectname/settings/local.py
- $ python manage.py syncdb
- $ python manage.py migrate
- $ python manage.py runserver

That's all you need to do to get the project ready for development. When you deploy your project into production, you should look into getting certain settings from environment variables or other external sources. (See SECRET_KEY for an example.)

There isn't a need to add settings/local.py to your source control, but there are multiple schools of thought on this. The method I use here is an example where each developer has their own settings/local.py with machine-specific settings. You will also need to create a version of settings/local.py for use in deployment that you will put into place with your deployment system (Fabric, chef, puppet, etc).

The second school of thought is that all settings should be versioned, so that as much of the code/settings as possible is the same across all developers and test/production servers. If you prefer this method, then make sure *all* necessary settings are properly set in settings/base.py, and then edit settings/__init__.py so it no longer reraises the exception. (ie, by replacing 'raise' with 'pass'). As it is, settings/local.py should only be overriding settings from settings/base.py anyway. (You could also just set the DJANGO_SETTINGS_MODULE environment variable to "{{ project_name }}.settings.base" directly.)

