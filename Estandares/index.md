---
layout: page
title: "Estándares"
description: ""
---
{% include JB/setup %}


# Python #

Seguimos 
[The Style Guide for Python Code](http://www.python.org/dev/peps/pep-0008/).
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
teléfonos inteligentes, tabletas).  Un proyecto django que emplea bootstrap 
es P2PU, las fuentes de su entorno CSS están en 
https://github.com/p2pu/p2pu-css-framework y la documentación 
en http://p2pu.github.io/p2pu-css-framework/ 

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
![http://sinsitioweb.files.wordpress.com/2013/04/captura-de-pantalla-290413-133033.png]

[logging]: https://docs.djangoproject.com/en/dev/topics/logging/


