#!/bin/bash
# Rutinas para prepara paquetes y entorno para desarrollar con Django 
# y una base de datos sobre Ubuntu 12.04 en x86_64 empleando estándares 
# de código.
# vtamara@pasosdeJesus.org. Dominio Publico. 2013

# Puede usarse para iniciar un proyecto nuevo con el parámetro ini
# Puede usarse como librería de funciones para despliegues (deployments)
# particulares al cargarlo sin parámetros
#
# Basado en instrucciones de: 
#   http://dhobsd.pasosdejesus.org/index.php?id=Desarrollar+Lernanta+en+OpenBSD+adJ
#   https://github.com/p2pu/lernanta/wiki/Setup-Lernanta-Manually
#   https://www.digitalocean.com/community/articles/installing-mod_wsgi-on-ubuntu-12-04


par="$@"
op1=$1
op2=$2
op3=$3
tf3=/tmp/dialog_3_$$
# Verifica parametros y entorno e inicializa variables 


# Instala un RPM ubicado en /tmp/ de requerirse via alien, por ejemplo para instalar /tmp/oracle-instantclient11.2-basic-11.2.0.4.0-1.x86_64.rpm usar:
# insrpm "RPM de Oracle InstantClient Basic" oracle-instantclient11.2-basic "-11.02.04.x86_64";
function insrpm {
	nom=$1;
	paq=$2;
	vl=$3
	if (test -x /usr/bin/apt-cache) then {
		apt-cache policy ${paq} | grep "Installed" > /dev/null 2>&1
		r=$1
	} elif (test -x /usr/bin/yum) then {
		yum list installed ${paq} > /dev/null 2>&1
		r=$1
	} fi;
	if (test "$r" != "0") then {
		rpm=$4;
		if (test "$rpm" = "") then {
			rpm="$paq${vl}.rpm";
		} fi;
		if (test ! -f "/tmp/$rpm") then {
			echo "Descargue en /tmp RPM de $nom ($rpm)";
			exit 1;
		} else {
			if (test -x /usr/bin/alien) then {
				sudo alien -i /tmp/$rpm
			} else {
				sudo rpm -i /tmp/$rpm
			} fi;
		} fi;
	} fi;
}

function verificaoracle {
	r=`find /usr/local -name "*instantclient*"`;
	if (test "$r" != "") then {
		echo "Eliminar primero instalaciones de instantclient en /usr/local";
		echo "$r"
			exit 1;
	} fi;
}

# Instala dialog y paquetes requeridos por este archivo de comandos
function prepdialog {
	if (test -x /usr/bin/apt-get) then {
		sudo apt-get install dialog
	} elif (test -x /usr/bin/yum) then {
		sudo yum -y install dialog
	} fi;
}

# Instala lo basico de Python y Django
function instalapythondjango {
	if (test -x /usr/bin/apt-get) then {
		if (test ! -d /etc/apache2/) then {
			sudo apt-get update
		} fi;
		sudo apt-get install python-dev python-setuptools \
		python-imaging \
		python-m2crypto make sqlite3 alien libaio1 libmemcached-dev \
		apache2 apache2.2-common apache2-mpm-prefork apache2-utils \
		libexpat1 ssl-cert libapache2-mod-wsgi w3m git rubygems screen;
	} elif (test -x /usr/bin/yum) then {
		sudo yum -y install python 
		sudo yum -y install python-devel
		sudo yum -y install python-setuptools
		sudo yum -y install python-setuptools-devel
		sudo yum -y install httpd
		sudo yum -y install mod_wsgi
		sudo yum -y install policycoreutils-python
		sudo yum -y install w3m
		sudo chkconfig --levels 235 httpd on
		sudo /etc/init.d/httpd start
	} fi;

	sudo easy_install virtualenv;
	sudo easy_install pip;
	sudo pip install virtualenvwrapper;
	sudo pip install Django

	if (test -f ~/.bashrc) then {
		confsh=".bashrc";
	} elif (test -f ~/.profile) then { 
		confsh=".profile";
	} fi;
	lv="/usr/local/bin"
	if (test ! -x $lv/virtualenvwrapper.sh) then {
		lv="/usr/bin"
	} fi;
	grep WORKON_HOME ~/$confsh > /dev/null 2>&1
	if (test "$?" != "0") then {
		cat >> ~/$confsh <<EOF
export PATH=\$PATH:/usr/local/bin
export WORKON_HOME=\$HOME/.virtualenvs
export PIP_VIRTUALENV_BASE=\$WORKON_HOME
export PIP_RESPECT_VIRTUALENV=true
source $lv/virtualenvwrapper.sh
EOF
		export WORKON_HOME=$HOME/.virtualenvs
		export PIP_VIRTUALENV_BASE=$WORKON_HOME
		export PIP_RESPECT_VIRTUALENV=true
		source /usr/local/bin/virtualenvwrapper.sh
	} fi;
}


# Instala  ependencias con pip, desde directorio con aplicacion
# Si falta copia configuraci<E1>ión local
function prepreq {
       sudo pip install -r requirements/local.txt
       if (test ! -f $nap/settings/local.py) then {
               cp $nap/settings/local-dist.py $nap/settings/local.py
       } fi;
       chmod +x ./manage.py bin/prepdjango.sh
}

# Instala Oracle instant Client y prepara para usar desde django
# Basado en http://marcelozambranav.blogspot.com/2012/08/how-to-install-oracle-sql-plus-on.html
function instalaoracle {
	if (test -x /usr/bin/apt-cache) then {
		r=`apt-cache search "oracle-instantclient.*basic" 2> /dev/null`;
	} elif (test -x /usr/bin/yum) then {
		r=`yum list installed "oracle-instantclient.*basic" | grep -a1 "installed" | tail -n 1 2> /dev/null`;
	} fi;
	if (test "$r" != "") then {
		# Version corta de Oracle InstantClient
		voib=`echo $r | sed -e "s/.*instantclient//g;s/-basic.*//g"`;
		# Version larga de Oracle InstantClient
		voibl=$voib;
		echo "Versión de Oracle InstantClient Basic instalada : $voib - ($voibl)";
		if (test "$voib" = "$voibl" -a "$voib" = "11.2") then {
			dialog --title "Oracle InstantClient Basic $voib"  --yesno "¿Usar la version ya instalada?" 10 60
			if (test "$?" = "0") then {
				return;
			} fi;
		} fi;
	}  fi;
	if (test ! -f /tmp/oracle-instantclient*-basic-*x86_64.rpm) then {
		echo "Descargue en /tmp la versión 11.2 más reciente de Oracle InstantClient Basic.  Se esperan  oracle-instantclient11.2-basic,  oracle-instantclient11.2-sqlplus, oracle-instantclient11.2-tools, oracle-instantclient11.2-devel"
		exit 1;
	} else {
		nvoib=`ls /tmp/oracle-instantclient*-basic-*x86_64.rpm | head -n 1 | sed -e "s/.*instantclient//g;s/-basic.*//g"`;
		if (test "$voib" != "" -a "$voib" != "$nvoib") then {
			echo "Versión instalada ($voib) y versión descargada ($nvoib) de Oracle InstantClient Basic diferentes";
			exit 1;
		} fi;
		voib=$nvoib;
		voibl=`ls /tmp/oracle-instantclient*-basic-*x86_64.rpm | head -n 1 | sed -e "s/.*basic-//g;s/.x86_64.*//g"`;
		echo "Versión de RPM de Oracle InstantClient Basic disponible en /tmp: $voib - ($voibl)";
	} fi;

	insrpm "RPM de Oracle InstantClient Basic" oracle-instantclient${voib}-basic "-$voibl.x86_64";
	insrpm "RPM de Oracle InstantClient sqlplus" oracle-instantclient${voib}-sqlplus "-$voibl.x86_64";
	insrpm "RPM de Oracle InstantClient Tools" oracle-instantclient${voib}-tools "-$voibl.x86_64";
	insrpm "RPM de Oracle InstantClient SDK" oracle-instantclient${voib}-devel "-$voibl.x86_64";


	if (test ! -f /etc/ld.so.conf.d/oracle.conf) then {
		if (test -f /tmp/oracle.conf) then {
			sudo rm /tmp/oracle.conf
		} fi;
		cat > /tmp/oracle.conf <<EOF
			/usr/lib/oracle/$voib/client64/lib/
EOF
		sudo mv /tmp/oracle.conf /etc/ld.so.conf.d/
		sudo ldconfig
	} fi;

	if (test "${ORACLE_HOME}" != "" -a "${ORACLE_HOME}" != "/usr/lib/oracle/${voib}/client64/" ) then {
		echo "ORACLE_HOME no es /usr/lib/oracle/${voib}/client64/ ";
		exit 1;
	} fi;

	sudo ORACLE_HOME=/usr/lib/oracle/11.2/client64/ pip install cx-oracle
}

# Verifica entorno y prepara variables
# Llena variables miruta, mius y migr
function inicializa {
	puerto=$1
	if (test "$puerto" = "") then {
		puerto=443
		echo "No se especificó puerto de apache por emplear, se empleara '$puerto'";
		echo "[ENTER] para continuar"
		read
	} fi;
	# Ruta de Apache
	apv=$2
	if (test "$apv" = "") then {
		apv="/etc/apache2/sites-available/wsgi"
		if (test -d "/etc/apache2/sites-available/") then {
			if (test "$puerto" = "443") then {
				apv="/etc/apache2/sites-available/default-ssl"
			} fi;
		} elif (test -f "/etc/httpd/conf/httpd.conf") then {
			apv="/etc/httpd/conf/httpd.conf"
		} fi;
	} fi;
	if (test ! -f "bin/prepdjango.sh") then {
		echo "Este script debe ejecutarse desde el directorio base con fuentes";
		exit 1;
	} fi;
	# Ruta a fuentes
	miruta=`pwd`;
	# usuario
	mius=`id -nu`;
	# grupo
	migr=`id -ng`;
	if (test "$mius" = "root") then { 
		mius=`export | grep "SUDO_UID[=]" | sed -e "s/.*=\"//g;s/\"//g"`;
		migr=`export | grep "SUDO_GID[=]" | sed -e "s/.*=\"//g;s/\"//g"`;
		if (test "$mius" = "0" -o "$mius" = "") then {
			echo "Ejecute este script como un usuario (con el cual se ejecutará el wsgi), no como root"
				exit 1;
		} fi;
	} fi;


}

# Prepara Apache para ejecutar aplicacion como WSGI
# wsgi 90 default /home/miusuario/des/nombrecompletoapp miusuario migrupo rutaweb $miruta/app/InterfacesContables/site_media/ $miruta/app/static/ $miruta/app/conf/apache
function wsgi {
	puerto=$1
	apv=$2
	miruta=$3
	mius=$4
	migr=$5
	rutaweb=$6
	media=$7
	static=$8
 	appconfapache=$9
	if (test "$puerto" = "") then {
		echo "Falta puerto como primer parametro de WSGI";
		exit 1;
	} fi;
	if (test ! -f "$apv") then {
		echo "Por crear $apv";
	} fi;
	if (test ! -d "$miruta") then {
		echo "Problema con ruta $miruta";
		exit 1;
	} fi;
	if (test "$mius" = "") then {
		echo "Problema con usuario $mius";
		exit 1;
	} fi;
	if (test "$migr" = "") then {
		echo "Problema con usuario $migr";
		exit 1;
	} fi;
	if (test "$rutaweb" = "") then {
		echo "Problema con rutaweb $rutaweb";
		exit 1;
	} fi;
	if (test ! -d "$media") then {
		echo "Problema con media $media";
		exit 1;
	} fi;
	if (test ! -d "$static") then {
		echo "Problema con static $static";
		exit 1;
	} fi;
	if (test ! -f "$appconfapache") then {
		echo "Problema con appconfapache $appconfapache";
		exit 1;
	} fi;
	ppython="/usr/lib/python2.7/site-packages"
	if (test ! -d "$ppython") then {
		ppython="/usr/lib/python2.7/dist-packages"
	} fi;
	if (test ! -d "$ppython") then {
		ppython="/usr/lib/python2.6/site-packages"
	} fi;
	if (test ! -d "$ppython") then {
		echo "No se conoce site-packages de python ($ppython)";
		exit 1;
	} fi;
	APACHE_LOG_DIR="/var/log/httpd";
	if (test ! -d $APACHE_LOG_DIR) then {
		APACHE_LOG_DIR="/var/log/apache2/";
	} fi;
	dappconfapache=`dirname $appconfapache`;
	ccom="
	Alias /site_media/ $media
	Alias /media/ $media
        Alias /static/ $static

        LogLevel warn

        WSGIDaemonProcess DOMAIN user=$mius group=$migr processes=1 threads=15 maximum-requests=10000 python-path=$ppython
        WSGIProcessGroup DOMAIN
        WSGIScriptAlias $rutaweb $appconfapache

        <Directory $media>
                Order deny,allow
                Allow from all
                Options -Indexes FollowSymLinks
        </Directory>

        <Directory $dappconfapache>
                Order deny,allow
                Allow from all
        </Directory>
";

	grep "WSGIScriptAlias $rutaweb" $apv > /dev/null 2>&1
	if (test "$?" != "0") then {
		if (test "$puerto" = "443" -a "$apv" = "/etc/apache2/sites-available/default-ssl") then {
			sudo ed $apv << EOF
/\/VirtualHost>
i
$ccom
.
w
q
EOF
		} else {
			vh="Listen $puerto
<VirtualHost *:$puerto>
        ServerAdmin webmaster@localhost

        DocumentRoot /var/www
        <Directory />
                Options FollowSymLinks
                AllowOverride None
        </Directory>
        <Directory /var/www/>
                Options Indexes FollowSymLinks MultiViews
                AllowOverride All
                Order allow,deny
                allow from all
        </Directory>

        ScriptAlias /cgi-bin/ /usr/lib/cgi-bin/
        <Directory \"/usr/lib/cgi-bin\">
                AllowOverride None
                Options +ExecCGI -MultiViews +SymLinksIfOwnerMatch
                Order allow,deny
                Allow from all
        </Directory>

        ErrorLog ${APACHE_LOG_DIR}/error.log

        # Possible values include: debug, info, notice, warn, error, crit,
        # alert, emerg.
        LogLevel warn

        CustomLog ${APACHE_LOG_DIR}/access.log combined

    Alias /doc/ \"/usr/share/doc/\"
    <Directory \"/usr/share/doc/\">
        Options Indexes MultiViews FollowSymLinks
        AllowOverride None
        Order deny,allow
        Deny from all
        Allow from 127.0.0.0/255.0.0.0 ::1/128
    </Directory>

$ccom
</VirtualHost>";
			if (test -f $apv) then {
                              sudo ed $apv << EOF
/\/VirtualHost>
a
$vh
.
w
q
EOF
			} else {
                               cat > /tmp/apv << EOF
$vh
EOF
				sudo cp /tmp/apv $apv
			} fi;
		} fi;
	} fi;

	grep "WSGIPythonPath " $apv > /dev/null 2>&1
	if (test "$?" != "0") then {
			sudo ed $apv << EOF
/\/VirtualHost>
a
        WSGIPythonPath $ppython
.
w
q
EOF
	} fi;
	if (test -x /usr/sbin/a2ensite) then {
		s=`basename $apv`;
		cmd="sudo a2ensite $s";
		echo "$cmd";
		eval "$cmd";
	} fi;
	if (test -x /usr/sbin/sestatus) then {
			sudo ed $apv << EOF
/WSGIPythonPath
a
	WSGISocketPrefix /var/run/wsgi";
.
w
q
EOF
	} fi;
	if (test -f "/etc/init.d/httpd") then {
		sudo service httpd stop
		r=`sudo semanage port -l | grep -w "http_port_t" | grep " $puerto"`
		if (test "$r" = "") then {
			sudo semanage port -a -t http_port_t -p tcp $puerto
		} fi;
		sudo service httpd start;
exit 1;
	} else {
		sudo service apache2 restart;
	} fi;
}

# Siempre instalamos lo necesario para desplegar django
prepdialog
if (test "$op1" = "") then {
      dialog --title "Instalando herramientas del sistemas operativo para desplegar con Django" --msgbox "Por instalar Apache, Python, Django, virtualenv, pip y virtualenvwrapper" 10 60
} else {
      echo "Instalando lo necesario en su sistema operativo para desplegar con django";
} fi;
instalapythondjango

# Lo demás que se haga depende de donde se ejecute
if (test "$op1" = "desp" -o -f "manage.py") then {
## DESPLIEGUE CON APACHE Y WSGI
	nomp=`grep DJANGO_SETTINGS_MODULE manage.py | sed -e "s/.*, \"//g;s/.settings\")//g;s/{{ //g;s/ }}//g"`
	if (test "$nomp" = "") then {
		echo "No pudo determinarse nombre de proyecto en manage.py";
		exit 1;
	} fi;
	if (test "$op2" = "") then {
		dialog --title "Desplegar $nomp sobre Apache con WSGI" --inputbo
x "Ingrese el puerto en el que operará la aplicación  WSGI sobre Apache (si no d
esea desplegar cancele)" 10 60 443 2> $tf3
		retv=$?
		puerto=$(cat $tf3)
		[ $retv -eq 1 -o $retv -eq 255 ] && exit

	} else {
		puerto="$op2"
	} fi;
	inicializa $puerto
	prepreq
	wsgi $puerto $apv $miruta $mius $migr "/" $miruta/$nomp/media/ $miruta/$nomp/static/ $miruta/$nomp/wsgi.py
	#wsgi $puerto $apv $miruta $mius $migr "/" $miruta/app/InterfacesContables/site_media/ $miruta/app/static/ $miruta/conf/apache/django.py
	dialog --title "Proyecto desplegado" --msgbox "Apache configurado con WSGI y reiniciado" 10 60
	#echo "Asegurese de habilitar el sitio de Apache (por ejemplo a2ensite default) y examinar";

} elif (test "$op1" != "lib") then {
## PREPARA ENTORN
	if (test -x /usr/sbin/sestatus) then {
		r=`/usr/sbin/sestatus | grep "SELinux status:" | sed -e "s/.*: *//g"`
		iv=`pwd | sed -e "s/\/var\/www.*/SI/g"`
		if (test "$r" = "enabled" -a "$iv" != "SI") then {
			echo "En sistemas con SELinux se recomienda instalar la aplicación dentro de /var/www";
			exit 1;
		} fi;
	} fi;
	nompr=$op1
	motorbd=$op2
	if (test "$motorbd" = "") then {
		dialog --title "Motor de base de datos" --menu "¿Qué motor de bases de datos configurar?" 10 60 5 s "SQLite" o "Oracle" 2> $tf3
		retv=$?
		c=$(cat $tf3)
		[ $retv -eq 1 -o $retv -eq 255 ] && exit
	} else {
		c=$motorbd
	} fi;

	case $c in
		[pP]*) 
		exit 1  
		;; 
		[oO]*) verificaoracle
		instalaoracle
		;;
		*) 
		;;
	esac

	vd=`python -c "import django; print(django.get_version())" | sed -e "s/\.//g;s/^\(..\).*/\1/g"`
	if (test "$?" != "0" -o "$vd" -lt "15") then {
		echo "No está instalado Django superior a 1.5";
		exit 1;
	} fi;

	if (test "$nompr" = "") then {
		dialog --title "Nombre de la aplicacion" --inputbox "Se recomienda corto, solo minusculas y sin espacios (pues también será nombre del módulo)"
		retv=$?
		nap=$(cat $tf3)
		[ $retv -eq 1 -o $retv -eq 255 ] && exit
	} else {
		nap=$nompr
	} fi;	

	django-admin.py startproject --template https://github.com/vtamara/plantilla-django/zipball/master --extension py,md,rst $nap

	cd $nap
	prepreq
	dialog --title "Entorno Instalado" --msgbox "Desarrolle con:
. ~/.bashrc
mkvirtualenv $nap --system-site-packages
workon $nap
cd $nap
make pip

Presione [ENTER] para iniciar servidor de desarrollo que puede
examinar en http://127.0.0.1:8000" 15 60;
	python manage.py runserver
} fi;

