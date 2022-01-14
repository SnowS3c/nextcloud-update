#!/bin/bash

##############################################################################################
#       
#       Actualizador contenedor Nextcloud
#
#       Uso: copiar enlace de descarga de la nueva actualización y pasarla como parámetro
#            ./nextcloud-update.sh [url]
#
##############################################################################################


# Comprobar que se ejecuta con privilegios root
! [ "$(id -u)" -eq 0 ] && echo "Error: Se necesita privilegios root" && exit 1


# Comprobar si el paquete sudo está instalado
if ! which sudo > /dev/null; then
        echo -en "\t[+] Paquete sudo no encontrado. Instalando...\n"
        apt update &>/dev/null
        apt install -y sudo
fi

dir_nextcloud="/var/www/nextcloud/"
dir_nextcloud_bak="/root/nextcloud-bk/"
dir_temp=$(mktemp -u)
date_time="$(date +%Y%m%d)"

# Comprobar si existen las rutas
[ ! -d "$dir_temp" ] && mkdir "$dir_temp"
[ ! -d "$dir_nextcloud_bak" ] && mkdir "$dir_nextcloud_bak"

# Comprobar parametro introducido
if [ -n "$1" ]; then
        nextcloud_update_url="$1"
else
        echo "Error: Introducir url de descarga nueva version nextcloud"
        echo "Uso: $(basename "$0") [url]"
        exit 2
fi

# Funcion mostrar errores
function check_error(){
        mensaje="$1"
        echo -ne "\t[-] Error durante la actualizacion\n"
        echo -ne "\t[-] $mensaje\n"
        exit 3
}


echo -ne "\t[+] Iniciando el modo mantenimiento de la web\n"
if ! (cd "$dir_nextcloud" && sudo -u www-data php occ maintenance:mode --on); then
        check_error "Error en la inicializacion del modo mantenimiento"
fi


echo -ne "\t[+] Iniciando copia de seguridad del directorio y la base de datos\n"
if ! rsync -Aavx "$dir_nextcloud" "$dir_nextcloud_bak/nextcloud-dirbkp_$date_time/"; then
        check_error "Error durante realizacion de la copia de seguridad del directorio nextcloud"
fi

if ! mysqldump --single-transaction -h localhost -u adminer -pMiner22va nextcloud > "$dir_nextcloud_bak/nextcloud-sqlbkp_$date_time.bak"; then
        check_error "Error durante la realizacion de la copia de seguridad de la base de datos"
fi


echo -ne "\t[+] Iniciando la descarga de la actualizacion y extraccion\n"
if ! wget "$nextcloud_update_url" -O "$dir_temp/nextcloud.zip"; then
        check_error "Error en la descarga de la actualizacion"
fi

if ! unzip "$dir_temp/nextcloud.zip" -d "$dir_temp/"; then
        check_error "Error en la descompresion de la actualizacion"
fi


echo -ne "\t[+] Apagando el servicio apache2\n"
if ! service apache2 stop; then
        check_error "No se puede parar el servicio apache2"
fi

read -p"Comentar las tareas cron de nextcloud (Intro para continuar)"
crontab -u www-data -e


echo -ne "\t[+] Cambiando nombre del directorio actual y moviendo la nueva instalacion al directorio por defecto\n"
if ! mv "$dir_nextcloud" /var/www/nextcloud-old; then
        check_error "No se puede cambiar el nombre de la instalacion actual de nextcloud"
fi

if ! mv "$dir_temp/nextcloud/" "$dir_nextcloud"; then
        check_error "No se puede mover la actualizacion al directorio de nextcloud"
fi


echo -ne "\t[+] Copiando configuracion del antiguo directorio a la nueva instalacion\n"
if ! cp "$dir_nextcloud_bak/nextcloud-dirbkp_$date_time/config/config.php" "$dir_nextcloud/config/config.php"; then
        check_error "No se puede copiar el fichero config.php a la nueva instalacion"
fi
if ! cp -r "$dir_nextcloud_bak/nextcloud-dirbkp_$date_time/data/" "$dir_nextcloud/data/"; then
        check_error "No se puede copiar el directorio antiguo data a la nueva instalacion"
fi

echo -ne "\t[+] Configurando permisos de nueva instalacion\n"
chown -R www-data:www-data "$dir_nextcloud"
find "$dir_nextcloud" -type d -exec chmod 750 {} \;
find "$dir_nextcloud" -type f -exec chmod 640 {} \;

echo -ne "\t[+] Iniciando el servicio apache2\n"
if ! service apache2 restart; then
        check_error "No se puede iniciar el servicio apache2"
fi


echo -ne "\t[+] Iniciando upgrade\n"
if ! (cd "$dir_nextcloud" && sudo -u www-data php occ upgrade); then
        check_error "No se puede lanzar la actualizacion"
fi

read -p"Descomentar las tareas cron de nextcloud (Intro para continuar)"
crontab -u www-data -e

echo -en "\t[+] Comprobar: Cambiar parametro maintenace a false, fichero $dir_nextcloud/config/config.php\n"
