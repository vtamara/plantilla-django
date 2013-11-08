---
layout: page
title: "Estándares"
description: ""
---
{% include JB/setup %}


Seguimos 
[The Style Guide for Python Code](http://www.python.org/dev/peps/pep-0008/).
De donde resumimos:

* Indentación 4 espacios sin usar tabuladores
* Líneas de código máximo de 79 caracteres y de comentarios o docstrings de 72,
  preferir usar paréntesis y paréntesis cuadrados para expresiones que 
  requieran varias líneas (en ocasiones puede usarse \).
* 


En su proyecto Django:

* Donde se requieran rutas absolutas relativas al directorio del proyecto
  usar
```python
import ap.settings 
...
ap.settings.PROJECT_ROOT
```

