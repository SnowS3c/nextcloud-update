#!/usr/bin/env bash
#===================================================================================
# NEXTCLOUD UPDATER
#         FILE: nextcloud-updater.sh
#        USAGE: ./nextcloud-updater.sh
#
#  DESCRIPTION: Update nextcloud service
#
#       AUTHOR: Antonio Sánchez (aslopez110@gmail.com)
#			 LICENSE: GNU General Public License v3.0
#      VERSION: 2022.01
#      CREATED: 24.01.2022
#  
#=================================================================================== 

#===============================================================================
#  COLORS AND TEXT
#===============================================================================
S_R="\e[0m"            	# Reset all attributes
S_B="\e[1m"             # Style BOLD
S_D="\e[2m"             # Style DIM
S_U="\e[4m"            	# Style UNDERLINE
S_I="\e[7m"             # Style INVERTED
S_DL="\e[K"             # Style DELETE TO END OF LINE

cursor_save()		 { echo -en "\e[s"; }			# Cursor SAVE POSITION
cursor_restore()	 { echo -en "\e[u"; }			# Cursor RESTORE POSITION
cursor_hide()		 { echo -en "\e[?25l"; }		# Cursor HIDE CURSOR
cursor_show()		 { echo -en "\e[?25h"; }		# Cursor SHOW CURSOR
cursor_move-up()	 { echo -en "\e[${1}A"; }		# Cursor MOVE UP $1 LINES
cursor_move-down()	 { echo -en "\e[${1}B"; }		# Cursor MOVE DOWN $1 LINES
cursor_move-left()	 { echo -en "\e[${1}D"; }		# Cursor MOVE LEFT $1 COLS
cursor_move-right()  { echo -en "\e[${1}C"; }		# Cursor MOVE RIGHT $1 COLS
cursor_move-begin()  { echo -en "\r"; }             # Cursor MOVE BEGIN POSITION IN CURRENT LINE
cursor_move-pos()    { echo -en "\e[${1};${2}H"; }  # Cursor MOVE LINE $1 COL $2

C_D="\e[39m"            # Color DEFAULT
C_R="\e[31m"            # Color RED
C_BR="\e[1m\e[31m"      # Color BOLD RED
C_LR="\e[91m"           # Color LIGHT RED
C_G="\e[32m"            # Color GREEN
C_BG="\e[1m\e[32m"      # Color BOLD GREEN
C_LG="\e[92m"           # Color LIGHT GREEN
C_Y="\e[33m"            # Color YELLOW
C_BY="\e[1m\e[33m"      # Color BOLD YELLOW
C_LY="\e[93m"           # Color LIGHT YELLOW
C_B="\e[34m"            # Color BLUE
C_BB="\e[1m\e[34m"      # Color BOLD BLUE
C_LB="\e[94m"           # Color LIGHT BLUE
C_M="\e[35m"            # Color MAGENTA
C_BM="\e[1m\e[35m"      # Color BOLD MAGENTA
C_LM="\e[95m"           # Color LIGHT MAGENTA
C_C="\e[36m"            # Color CYAN
C_BC="\e[1m\e[36m"      # Color BOLD CYAN
C_LC="\e[96m"           # Color LIGHT CYAN
C_N="\e[90m"            # Color GREY
C_LN="\e[37m"           # Color LIGHT GREY
B_R="\e[41m"            # Background RED
B_G="\e[42m"            # Background GREEN
B_Y="\e[43m"            # Background YELLOW
B_B="\e[44m"            # Background BLUE
B_M="\e[45m"            # Background MAGENTA
B_C="\e[46m"            # Background CYAN
B_LG="\e[47m"           # Background LIGHT GREY
B_DG="\e[100m"          # Background DARK GREY
B_LR="\e[101m"          # Background LIGHT RED
B_LG="\e[102m"          # Background LIGHT GREEN
B_LY="\e[103m"          # Background LIGHT YELLOW
B_LB="\e[104m"          # Background LIGHT BLUE
B_LM="\e[105m"          # Background LIGHT MAGENTA
B_LC="\e[106m"          # Background LIGHT CYAN
B_W="\e[107m"           # Background LIGHT WHITE

# Banner
banner=" ██████   █████                       █████             ████                          █████
░░██████ ░░███                       ░░███             ░░███                         ░░███ 
 ░███░███ ░███   ██████  █████ █████ ███████    ██████  ░███   ██████  █████ ████  ███████ 
 ░███░░███░███  ███░░███░░███ ░░███ ░░░███░    ███░░███ ░███  ███░░███░░███ ░███  ███░░███ 
 ░███ ░░██████ ░███████  ░░░█████░    ░███    ░███ ░░░  ░███ ░███ ░███ ░███ ░███ ░███ ░███ 
 ░███  ░░█████ ░███░░░    ███░░░███   ░███ ███░███  ███ ░███ ░███ ░███ ░███ ░███ ░███ ░███ 
 █████  ░░█████░░██████  █████ █████  ░░█████ ░░██████  █████░░██████  ░░████████░░████████
░░░░░    ░░░░░  ░░░░░░  ░░░░░ ░░░░░    ░░░░░   ░░░░░░  ░░░░░  ░░░░░░    ░░░░░░░░  ░░░░░░░░ 
                                                                                           
                                                                                           
                                                                                           
 █████  █████               █████            █████                                         
░░███  ░░███               ░░███            ░░███                                          
 ░███   ░███  ████████   ███████   ██████   ███████    ██████  ████████                    
 ░███   ░███ ░░███░░███ ███░░███  ░░░░░███ ░░░███░    ███░░███░░███░░███                   
 ░███   ░███  ░███ ░███░███ ░███   ███████   ░███    ░███████  ░███ ░░░                    
 ░███   ░███  ░███ ░███░███ ░███  ███░░███   ░███ ███░███░░░   ░███                        
 ░░████████   ░███████ ░░████████░░████████  ░░█████ ░░██████  █████                       
  ░░░░░░░░    ░███░░░   ░░░░░░░░  ░░░░░░░░    ░░░░░   ░░░░░░  ░░░░░                        
              ░███                                                                         
              █████                                                                        
             ░░░░░                                                                         "


#=== PARAMETERS=====================================================================
domain=
admin_user=
admin_pass=
user_database=
user_database_pass=
#===================================================================================

#=== FUNCTION ======================================================================
# NAME: error_info
# DESCRIPTION: echo error message and exit if exit code is supplied
#
# PARAMS
#	$1		Message to show
#	[$2]	Exit code
#===================================================================================
function error_info() {
	local msg="$1"
	local code="$2"
	echo -e "${C_R}$msg${C_D}" 1>&2
	[ "$code" ] && [ "$code" -ne 0 ] &>/dev/null && exit $code
}



#=== FUNCTION ======================================================================
#  NAME: check_dependencies
#  DESCRIPTION: check for packages dependencies not installed.
#
#  PACKAGES: curl, sudo, unzip
#===================================================================================
function check_dependencies(){
	echo -e "${C_Y}[*]${C_D} Checking dependencies..."
	for package in "$@"; do
			if ! which "$package" > /dev/null; then
					echo -en "\t${C_G}[+]${C_D} $package package not found. Installing...\n"
					apt update &>/dev/null
					apt install -y "$package"
			fi
	done
	echo -e "${C_Y}[*]${C_D} Done"
}

#===============================================================================
#  MAIN PROGRAM
#===============================================================================

# Check root privileges
[ "$(id -u)" -ne 0 ] && error_info "Administrative privileges needed" 1

# Check dependencies
check_dependencies curl sudo unzip || error_info "Cannot install packages dependencies" 2


clear
echo "$banner"
echo "Script for update nextcloud service"


if [ -z "$admin_user" ]; then
	read -p"Enter nextcloud admin username: " admin_user
	[ -z "$admin_user" ] && error_info "Username can't be empty"	4
fi

if [ -z "$admin_pass" ]; then
	cursor_hide
	read -s -p$"Enter password for nextcloud user $admin_user:"$'\n' admin_pass
	cursor_show
	[ -z "$admin_pass" ] && error_info "Password can't be empty" 5
fi

if [ -z "$domain" ]; then
	read -p"Enter domain/ip of the website: " domain
	[ -z "$domain" ] && error_info "Domain/ip can't be empty" 6
fi

echo -en "\t${C_G}[*]${C_D} Checking if new update exists... "
output_curl="$(curl -k -u "${admin_user}:${admin_pass}" -H 'X-Requested-With:XMLHttpRequest' https://${domain}/index.php/settings/admin/overview 2>/dev/null)"
[[ "$output_curl" =~ '{"message":' ]] && error_info "Error login. Bad credentials" 7

if update_notification="$(echo "$output_curl" | grep '<div id="updatenotification" ')"; then
	if echo "$output_curl" | grep 'isNewVersionAvailable&quot;:true' &>/dev/null; then
		echo -e "${C_G}New Version available${C_D}"
	elif echo "$output_curl" | grep 'isNewVersionAvailable&quot;:false' &>/dev/null; then
		echo -e "${C_G}Nextcloud is updated${C_D}"
		exit 0
	fi
fi


# Searching new version.
! new_version_url="$(echo "$output_curl" | grep '<div id="updatenotification"' | sed 's/&quot/ /g' | cut -d" " -f 42 | tr -d '[\\;]' | grep -E "^https://download.nextcloud.com/.*.zip$")" && error_info "Error: Bad url for download new version of nextcloud" 5


dir_nextcloud="/var/www/nextcloud/"
dir_nextcloud_bak="/root/nextcloud-bk/"
dir_temp=$(mktemp -u)
date_time="$(date +%Y%m%d)"

# Comprobar si existen las rutas
[ ! -d "$dir_temp" ] && mkdir "$dir_temp"
[ ! -d "$dir_nextcloud_bak" ] && mkdir "$dir_nextcloud_bak"

echo -ne "\t${C_G}[*] STARTING UPDATE${C_D}\n"
echo -ne "\t\t${C_G}[+]${C_D} Starting web maintenance mode\n"
! (cd "$dir_nextcloud" && sudo -u www-data php occ maintenance:mode --on) && error_info "[-] Error: Cannot start web maintenance mode" 1


echo -ne "\n\t\t${C_G}[+]${C_D} Starting nextcloud folder backup and database\n"
! rsync -Aavx "$dir_nextcloud" "$dir_nextcloud_bak/nextcloud-dirbkp_$date_time/" &>/dev/null && error_info "[-] Error: Cannot finish nextcloud backup" 1

if [ -z "$user_database" ]; then
	read -p "$(echo -e "\t\t\t${C_Y}[*]${C_D} Enter username of the database: ")" user_database
	[ -z "$user_database" ] && error_info "Username can't be empty" 6
fi
if [ -z "$user_database_pass" ]; then
	cursor_hide
	read -s -p "$(echo -e "\t\t\t${C_Y}[*]${C_D} Enter password for database user $user_database:\n")" user_database_pass
	cursor_show
	[ -z "$user_database_pass" ] && error_info "Password can't be empty" 5
fi
! mysqldump --single-transaction -h localhost -u"$user_database" -p"$user_database_pass" nextcloud > "$dir_nextcloud_bak/nextcloud-sqlbkp_$date_time.bak" && error_info "[-] Error: Cannot finish database backup" 1


echo -en "\n\t\t${C_G}[+]${C_D} Downloading new update and extracting\n"
! wget "$new_version_url" -O "$dir_temp/nextcloud.zip" && error_info "[-] Error: Update download failed" 1
! unzip "$dir_temp/nextcloud.zip" -d "$dir_temp/" &>/dev/null && error_info "[-] Error: Extracting failed" 1


echo -en "\n\t\t${C_G}[+]${C_D} Stopping apache2 service...\n"
! service apache2 stop && error_info "Error: Cannot stop apache2 service" 1


read -p "$(echo -e "\n\t\t${C_Y}[*] INFO${C_D}: You should comment cron jobs (Press enter to continue)")"
crontab -u www-data -e


echo -en "\n\t\t${C_G}[+]${C_D} Replacing the old folder for the new one\n"
! mv -v "$dir_nextcloud" "/var/www/nextcloud-old" && error_info "[-] Error: Cannot move current nextcloud folder" 1
! mv -v "$dir_temp/nextcloud/" "$dir_nextcloud" && error_info "[-] Error: Cannot move updated folder into nextcloud folder" 1


echo -en "\n\t\t${C_G}[+]${C_D} Copying previous configuration\n"
! cp -v "$dir_nextcloud_bak/nextcloud-dirbkp_$date_time/config/config.php" "$dir_nextcloud/config/config.php" && error_info "Error: Cannot copy config.php file into new installation" 1
! cp -vr "$dir_nextcloud_bak/nextcloud-dirbkp_$date_time/data/" "$dir_nextcloud/data/" && error_info "Error: Cannot copy data folder into new installation" 1


echo -en "\n\t\t${C_G}[+]${C_D} Adjust file ownership and permissions\n"
chown -R www-data:www-data "$dir_nextcloud"
find "$dir_nextcloud" -type d -exec chmod 750 {} \;
find "$dir_nextcloud" -type f -exec chmod 640 {} \;


echo -en "\n\t\t${C_G}[+]${C_D} Starting apache2 service\n"
! service apache2 restart && error_info "Error: Cannot start apache2 service" 1


echo -en "\n\t\t${C_G}[+]${C_D} Starting upgrade\n"
! (cd "$dir_nextcloud" && sudo -u www-data php occ upgrade) && error_info "Error: Cannot launch upgrade" 1

read -p "$(echo -e "\n\t\t${C_Y}[*] INFO${C_D}: Uncomment cron jobs (Press enter to continue)")"
crontab -u www-data -e

echo -en "\n\t\t${C_G}[+]${C_D} Stoping web maintenance mode\n"
! sed -i "s/\('maintenance' => \)true/\1false/" "$dir_nextcloud/config/config.php" && error_info "Error: Stop maintenance mode manually setting maintenance parameter to false in config.php"


echo -en "\n\t${C_G}[*] UPDATE FINISH${C_D}\n"