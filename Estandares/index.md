---
layout: page
title: "Estándares"
description: ""
---
{% include JB/setup %}


# Python #

Seguimos 
[The Style Guide for Python Code][style].
De donde resumimos:

* Indentación 4 espacios sin usar tabuladores
* Líneas de código máximo de 79 caracteres y de comentarios o docstrings de 72,
  preferir usar paréntesis y paréntesis cuadrados para expresiones que 
  requieran varias líneas (en ocasiones puede usarse \).
* 


# Django #


* Donde se requieran rutas absolutas relativas al directorio del proyecto
  usar

```python
import ap.settings 
...
ap.settings.PROJECT_ROOT
```

## Entorno CSS ##

Lo recomendamos para desarrollar con más facilidad aplicaciones receptivas 
(*responsive*), que se adaptan al dispositivos desde el cual se ven (e.g
teléfonos inteligentes, tabletas).  En la plantilla operando se nota al cambiar
el tamaño de la ventana del navegador.

Un proyecto en Django que emplea bootstrap es P2PU (ver [fuentes][fuentescssp2pu] y [documentación][doccssp2pu]).
, las fuentes de su entorno CSS están en 

## Bitácoras ##

Emplear el método estándar de Django [Método estándar de Django][logging],
es decir donde requiera registrar sucesos:

```python
import logging

logger = logging.getLogger(__name__)
...
    logger.error('Lo que se registra en bitacora')
```

Con la configuración de la plantilla, los mensajes que envíe a esta bitácora
podrá verlos en la sección Logging de la barra de herramientas de depuración 
(debug-toolbar), la cual se activa ingresando a la zona administrativa (ruta /admin).
![]
![debug-toolbar](http://sinsitioweb.files.wordpress.com/2013/04/captura-de-pantalla-290413-133033.png "Barra de herramientas de depuración de http://sinsitioweb.wordpress.com/2013/04/29/usando-debug-toolbar-django/")
[logging]: https://docs.djangoproject.com/en/dev/topics/logging/

## Paquetes ##

Los paquetes para pip que se requieren se especifican en:

- requeridos/prod.txt los requeridos para producción y que no necesitan compilación
- requeridos/comp.txt requeridos para producción y que deben compilarse (como cx-oracle)
- requeridos/des.txt  requeridod en desarrollo y pruebas pero no en sitios de producción

Desde el directorio de la aplicación puede instalarlos, actualizarlos o completarlos 
(después de cambiar esos archivos) con:

```sh
$ sudo pip -r requirements.txt
```

o más breve para instalar los de producción:

```sh
$ sudo make pip
```

Y los de desarrollo
```sh
$ sudo make des
```

Puede consultar más como emplear estos archivos con virtualenv en [pip and friends: packaging][playdohpack]



[style]: http://www.python.org/dev/peps/pep-0008/
[fuentescssp2pu]: https://github.com/p2pu/p2pu-css-framework
[doccssp2pu]: http://p2pu.github.io/p2pu-css-framework/ 
[playdoh]: https://github.com/mozilla/playdoh
[twoscoops]: https://github.com/twoscoops/django-twoscoops-project
[p2pu]: https://github.com/p2pu/lernanta
[playdohpack]: https://github.com/mozilla/playdoh-docs/blob/master/packages.rst
