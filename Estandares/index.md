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

