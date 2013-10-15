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
op=$1
tf3=/tmp/dialog_3_$$
# Verifica parametros y entorno e inicializa variables 


# Instala un RPM ubicado en /tmp/ via alien, por ejemplo para instalar /tmp/oracle-instantclient11.2-basic-11.2.0.4.0-1.x86_64.rpm usar:
# insrpm "RPM de Oracle InstantClient Basic" oracle-instantclient11.2-basic "-11.02.04.x86_64";
function insrpm {
	nom=$1;
	deb=$2;
	vl=$3
	apt-cache policy ${deb} | grep "Installed" > /dev/null 2>&1
	if (test "$?" != "0") then {
		rpm=$3;
		if (test "$rpm" = "") then {
			rpm="$deb${vl}.rpm";
		} fi;
		if (test ! -f "/tmp/$rpm") then {
			echo "Descargue en /tmp RPM de $nom ($rpm)";
			exit 1;
		} else {
			sudo alien -i /tmp/$rpm
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

# Instala lo basico de Python y Django
function instalapythondjango {
	sudo apt-get install python-dev python-setuptools python-imaging \
		python-m2crypto make sqlite3 alien libaio1 libmemcached-dev \
		apache2 apache2.2-common apache2-mpm-prefork apache2-utils \
		libexpat1 ssl-cert libapache2-mod-wsgi;

	sudo easy_install virtualenv;
	sudo easy_install pip;
	sudo pip install virtualenvwrapper;

	grep WORKON_HOME ~/.bashrc > /dev/null 2>&1
	if (test "$?" != "0") then {
		cat >> ~/.bashrc <<EOF
export PATH=\$PATH:/usr/local/bin
export WORKON_HOME=\$HOME/.virtualenvs
export PIP_VIRTUALENV_BASE=\$WORKON_HOME
export PIP_RESPECT_VIRTUALENV=true
source /usr/local/bin/virtualenvwrapper.sh
EOF
		export WORKON_HOME=$HOME/.virtualenvs
		export PIP_VIRTUALENV_BASE=$WORKON_HOME
		export PIP_RESPECT_VIRTUALENV=true
		source /usr/local/bin/virtualenvwrapper.sh
	} fi;
}

# Instala Oracle instant Client y prepara para usar desde django
# Basado en http://marcelozambranav.blogspot.com/2012/08/how-to-install-oracle-sql-plus-on.html
function instalaoracle {
	r=`apt-cache search "oracle-instantclient.*basic" 2> /dev/null`;
	if (test "$r" != "") then {
		# Version corta de Oracle InstantClient
		voib=`echo $r | sed -e "s/.*instantclient//g;s/-basic.*//g"`;
		# Version larga de Oracle InstantClient
		voibl=$voib;
		echo "Versión de Oracle InstantClient Basic instalada : $voib - ($voibl)";
	}  fi;
	if (test ! -f /tmp/oracle-instantclient*-basic-*x86_64.rpm) then {
		echo "Descargue en /tmp la versión más reciente del RPM de Oracle InstantClient Basic de http://download.oracle.com/otn/linux/instantclient/"
		exit 1;
	} else {
		nvoib=`ls /tmp/oracle-instantclient*-basic-*x86_64.rpm | head -n 1 | sed -e "s/.*instantclient//g;s/-basic.*//g"`;
		if (test "$voib" != "" -a "$voib" != "$nvoib") then {
			echo "Versión instalada y versión descargada de Oracle InstantClient Basic diferentes";
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
		if (test "$puerto" != "443") then {
			apv="/etc/apache2/sites-available/wsgi"
		} else {
			apv="/etc/apache2/sites-available/default-ssl"
		} fi;
		echo "[ENTER] para continuar"
		read
	} fi;
	if (test ! -f "bin/prepara.sh") then {
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
	sitemedia=$7
	static=$8
 	appconfapache=$9
	if (test "$puerto" = "") then {
		echo "Falta puerto como primer parametro de WSGI";
		exit 1;
	} fi;
	if (test ! -f "$apv") then {
		echo "Problema con $apv";
		exit 1;
	} fi;

	ccom="
	Alias /site_media/ $sitemedia
        Alias /static/ $static

        LogLevel warn

        WSGIDaemonProcess DOMAIN user=$mius group=$migr processes=1 threads=15 maximum-requests=10000 python-path=/usr/lib/python2.7/site-packages
        WSGIProcessGroup DOMAIN
        WSGIScriptAlias $rutaweb $appconfapache/django.wsgi

        <Directory $sitemedia>
                Order deny,allow
                Allow from all
                Options -Indexes FollowSymLinks
        </Directory>

        <Directory $appconfapache>
                Order deny,allow
                Allow from all
        </Directory>
";

	grep "WSGIScriptAlias $rutaweb" $apv > /dev/null 2>&1
	if (test "$?" != "0") then {
		if (test "$puerto" = "443") then {
			sudo ed $apv << EOF
/\/VirtualHost>
i
$ccom
.
w
q
EOF
		} fi;
	} else {
		grep "WSGIScriptAlias /" $apv > /dev/null 2>&1
		if (test "$?" != "0") then {
			sudo ed $apv << EOF
/\/VirtualHost>
a
Listen $puerto
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
        <Directory "/usr/lib/cgi-bin">
                AllowOverride None
                Options +ExecCGI -MultiViews +SymLinksIfOwnerMatch
                Order allow,deny
                Allow from all
        </Directory>

        ErrorLog \${APACHE_LOG_DIR}/error.log

        # Possible values include: debug, info, notice, warn, error, crit,
        # alert, emerg.
        LogLevel warn

        CustomLog \${APACHE_LOG_DIR}/access.log combined

    Alias /doc/ "/usr/share/doc/"
    <Directory "/usr/share/doc/">
        Options Indexes MultiViews FollowSymLinks
        AllowOverride None
        Order deny,allow
        Deny from all
        Allow from 127.0.0.0/255.0.0.0 ::1/128
    </Directory>

$ccom
</VirtualHost>
.
w
q
EOF
		} fi;
	} fi;

	grep "WSGIPythonPath " $apv > /dev/null 2>&1
	if (test "$?" != "0") then {
			sudo ed $apv << EOF
/\/VirtualHost>
a
        WSGIPythonPath /usr/lib/python2.7/site-packages/
.
w
q
EOF
	} fi;

	sudo service apache2 restart;
}

function pipymensaje { 
	(cd app/InterfacesContables; sudo make pip);
	echo "-------------------";
	echo "Paquetes instalados en sistema y Apache configurado con WSGI y reiniciado.";
	echo "Asegurese de habilitar el sitio de Apache (por ejemplo a2ensite default) y examinar";
	echo "Empiece a desarrollar con:";
	echo "  . ~/.bashrc";
	echo "  mkvirtualenv ic --system-site-packages";
	echo "  workon ic";
	echo "  cd app/InterfacesContables";
	echo "  make pip";
}


if (test "$op" = "ini") then {
	dialog --title "Ayuda a iniciar proyecto con Django" --msgbox "Por instalar Apache, Python, Django, virtualenv, pip y virtualenvwrapper" 10 60

		instalapythondjango

		dialog --title "Motor de base de datos" --menu "¿Qué motor de bases de datos configurar?" 10 60 5 s "SQLite" p "PostgreSQL" o "Oracle" 2> $tf3
		retv=$?
		c=$(cat $tf3)
		[ $retv -eq 1 -o $retv -eq 255 ] && exit

		case $c in
		p) 
		exit 1  
		;; 
	o) verificaoracle
		instalaoracle
		;;
	*) 
		;;
	esac

		vd=`python -c "import django; print(django.get_version())"`
		if (test "$?" != "0" -o "$vd" -lt "1.5") then {
			echo "No está instalado Django superior a 1.5";
			exit 1;
		} fi;

	dialog --title "Nombre de la aplicacion" --inputbox "Se recomienda solo minusculas, sin espacios y corto" 10 60 2> $tf3
		retv=$?
		nap=$(cat $tf3)
		[ $retv -eq 1 -o $retv -eq 255 ] && exit

		django-admin.py startproject --template https://github.com/vtamara/django-base-template/zipball/master --extension py,md,rst $nap

		cd $nap
		sudo pip install -r requirements/local.txt
		cp $nap/settings/local-dist.py $nap/settings/local.py
		python manage.py syncdb
		python manage.py migrate
		python manage.py runserver


		exit 1

		inicializa $par
#wsgi 443 $apv $miruta $mius $migr "/" $miruta/app/InterfacesContables/site_media/ $miruta/app/static/ $miruta/app/conf/apache
#pipymensaje
} fi;

