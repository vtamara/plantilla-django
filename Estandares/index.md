---
layout: page
title: "Estándares"
description: ""
---
{% include JB/setup %}


# Python #

Seguimos la gran mayoría de 
[The Style Guide for Python Code][style].
De donde resumimos:

* Indentación 4 espacios sin usar tabuladores
* Líneas de código máximo de 79 caracteres y de comentarios o docstrings de 72,
  preferir usar paréntesis y paréntesis cuadrados para expresiones que 
  requieran varias líneas (en ocasiones puede usarse \).
* 


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

# Control de versiones #

Recomendamos emplear un repositorio git para controlar versiones y planear nombres
de versiones.  La siguiente sugerencia se basa en el esquema seguido por OpenBSD:
* Nombres de versiones con dos números (e.g 1.2). El primer número (mayor) sólo cambia cuando se inician
  cambios profundos, el segundo número (menor) cambia cuando comienza a planearse un despliegue 
  y a implementarse las características del mismo.
* Una rama por cada versión menor (digamos v1.2), con el nombre de la versión menor y en la que se
  incluyan soluciones a problemas a esa versión cuando se requieran.
* Una etiqueta cada vez que se despliegue (para facilitar comparar diferencias), puede ser con fecha y
  entidad donde se desplego (e.g nov18entidad)
* En la rama master el desarrollo más reciente


## Migraciones ##

Se recomienda emplear migraciones con la aplicación `south` para manejar
cambios a la base de datos y a los modelos.  
Algunos casos de uso tomados de [Migraciones en Lernanta][miglernanta] son:

### Inicializar y actualizar la base de datos ###

```
./manage.py syncdb --noinput --migrate
```
o más breve
```
make mig
```
./manage.py syncdb --noinput --migrate


Inicializa o actualiza después de introducir cambios a los modelos (los cambios a los modelos se ven
cuando cambian los archivos de la forma `apps/*/models.py`).  Ejecutelo para asegurar que la base y modelos
están al dia.

### Cambiar modelo de una aplicación existente ###

Si cambia el modelo de una aplicación  
(i.e cambia `apps/users/models.py`), ejecute:
```
./manage.py schemamigration users --auto
```
Para crear una nueva migración en  `apps/users/migrations`.
El código generado lo puede afinar --por ejemplo para asegurar que 
un migración se aplica después de otra.

### Crear el modelo para una nueva apliacion ###

Si desarrolla una nueva aplicación, digamos  miap, después
de crear el modelo en python, ejecute:
```
./manage.py schemamigration miap --initial
```

Esto generará la primera migración que puede crear las tablas que haya
definido en ```apps/repasa/models.py```

### Probar migraciones ###

Para asegurar que las migraciones se ejecutarán sin fallas, puede preparar 
una base de datos de prueba en `settings/local.py`, por ejemplo:
```python
    's': {
        'ENGINE': 'django.db.backends.sqlite3',
        'NAME': 'lernanta.db',
    },
```
que declara una base de datos en SQLite, con identificación "s" y que podrá
actualizar con:
```
./manage.py syncdb --database s --migrate
```

Una prueba completa es:
1. Borrar la base
```
rm db/lernanta.db
```
2. Inicializar y aplicar todas las migraciones:
```
./manage.py syncdb --database s --noinput --migrate
```
3. Revertir todas las migraciones aplicadas:
```
./manage.py migrate --database s --all zero
```
4. Aplicar todas las migraciones de nuevo:
```
        ./manage.py migrate --database s --all
```

### Visualizar migraciones ### 

Una vez instalado Graphviz, puede generar el grafo de migraciones con:
```
./manage.py graphmigrations | dot -Tpng -omigraciones.png
```


[style]: http://www.python.org/dev/peps/pep-0008/
[fuentescssp2pu]: https://github.com/p2pu/p2pu-css-framework
[doccssp2pu]: http://p2pu.github.io/p2pu-css-framework/ 
[playdoh]: https://github.com/mozilla/playdoh
[twoscoops]: https://github.com/twoscoops/django-twoscoops-project
[p2pu]: https://github.com/p2pu/lernanta
[playdohpack]: https://github.com/mozilla/playdoh-docs/blob/master/packages.rst
[miglernanta]: https://github.com/vtamara/lernanta/blob/master/docs/migrations.txt
