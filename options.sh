check_php_if_exist(){
php -v > /dev/null
if [[ $? -eq 0 ]]; then
return 0
else
return 1
fi
}

mysql_secure_installation(){
mysql_secure_installation 
}
warn_php(){
if ( check_php_if_exist -eq 0 ); then
echo 'You already have another PHP version...'
echo "Do you want to continue?"
    read -p "[Y/y]/[N/n] " confirm
    case $confirm in
        [Yy]* ) echo 'Ok, continue...' ;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no. ";;
    esac
fi
}

http_firewall-cmd(){
#systemctl is-active --quiet firewalld 
service firewalld status  > /dev/null 2>&1
[[ $? -eq 0 ]] &&
echo "The following action will add 'http & https' rules using firewalld-cmd:"
echo "Do you want to continue?"
    read -p "[Y/y]/[N/n] " confirm
    case $confirm in
        [Yy]* ) echo 'Adding...' 
		firewall-cmd --permanent --add-service=http
		firewall-cmd --permanent --add-service=https
		firewall-cmd --reload
		firewall-cmd --list-all
		;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no. ";;
    esac
}

off_preinstall_check(){
INST="/tmp/installed_soft.log"
NOT_INST="/tmp/not_installed_soft.log"
SOFT="nginx php-fpm php php-opcache php-cli php-gd php-curl php-mysql"
PUSH="nginx php-fpm"
:> "$INST" && :> "$NOT_INST"
echo -e 'Checking that the product already is installed...\n'
for i in $SOFT
do if rpm -q "$i" >> "$INST"; then
echo -e "$i is installed..\n"
else
echo -e " "$i" not installed..\n"
echo "$i" >> "$NOT_INST"
fi; done
SIZE=$(stat -c%s "$NOT_INST")
[[ "$SIZE" -eq 0 ]] && echo -e 'All is installed...\n' &&  exit 0 ||
[[ X=$(  echo "$SOFT" | sed 's/ \+/\n/g' | cmp -s "$NOT_INST" > /dev/null; echo $?) -eq 0 ]] &&
echo -e 'Nothing is installed...\n' ||
echo -e 'There are missing components...\n'
}

off_installer(){
local X=`awk '{print $1}' $NOT_INST`
echo "Do you want to install "$X"?"
    read -p "[Y/y]/[N/n] " confirm
    case $confirm in
        [Yy]* )  
		yum -y clean all
	        yum -y update
		yum -y install $X
		;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no. ";;
    esac
}

full_setting_off_repo(){
INDEX_PATH_DIR="/var/www/${HOSTNAME}"
CONF_PATH_DIR="/etc/nginx/conf.d/"
echo -e "Create by ${HOSTNAME}\n"
echo -e 'Create web directory...\n'
[ -d "$INDEX_PATH_DIR" ] || mkdir -p "$INDEX_PATH_DIR"
echo -e "Created derectory path ${HOSTNAME}\n"
echo -e 'Create logs files...\n'
sudo touch /var/log/nginx/access_${HOSTNAME}.log
sudo touch /var/log/nginx/error_${HOSTNAME}.log
echo -e 'Check who is owner original "/var/log/nginx/access.log" file...\n'
ls -l /var/log/nginx/access.log | awk '{print $3}'
ls -l /var/log/nginx/access.log | awk '{print $4}'
echo -e 'Set variables...\n'
username=$(sudo ls -l /var/log/nginx/access.log | awk '{print $3}')
usergroup=$(sudo ls -l /var/log/nginx/access.log | awk '{print $4}')
echo -e 'Chown the owner of your files...\n'
chown $username:$usergroup /var/log/nginx/access_${HOSTNAME}.log
chown $username:$usergroup /var/log/nginx/error_${HOSTNAME}.log
echo -e 'Copy nginx.conf...\n'
. ./nginx.file
echo -e 'Copy index.php...\n'
. ./index.file
echo -e 'Change in the nginx.conf - default server {} | sed -i s/80 default_server;/80;/\n'
sed -i 's/listen       80 default_server;/listen       80;/' /etc/nginx/nginx.conf
echo -e 'change default user/group on php-fpm...\n'
sed -i 's/user = apache/user = nginx/' /etc/php-fpm.d/www.conf
sed -i 's/group = apache/group = nginx/' /etc/php-fpm.d/www.conf
echo 'Print version...'
for i in `which $PUSH`; do $i -v; done
}

finish_off(){
ExIP=$(curl -s icanhazip.com)
InIP=$(hostname -i)
echo
echo
echo -e "Start & Enable "$PUSH"?\n"
    read -p "[Y/y]/[N/n] " confirm
    case $confirm in
        [Yy]* ) for i in $PUSH; do systemctl enable --now $i ; done;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no. ";;
    esac
echo
echo 'Follow the link:'
echo "ExIP: http://${ExIP}/"
echo "InIP: http://${InIP}/"
echo
}

repo_preinstall_check(){
INST="/tmp/installed_soft.log"
NOT_INST="/tmp/not_installed_soft.log"
SOFT="nginx rh-php70 rh-php70-php rh-php70-php-fpm"
PUSH="nginx"
:> "$INST" && :> "$NOT_INST"
echo -e 'Checking that the product already is installed...\n'
for i in $SOFT
do if rpm -q "$i" >> "$INST"; then
echo -e "$i is installed..\n"
else
echo -e " "$i" not installed..\n"
echo "$i" >> "$NOT_INST"
fi; done
SIZE=$(stat -c%s "$NOT_INST")
[[ "$SIZE" -eq 0 ]] && echo -e 'All is installed...\n' &&  exit 0 ||
[[ X=$(  echo "$SOFT" | sed 's/ \+/\n/g' | cmp -s "$NOT_INST" > /dev/null; echo $?) -eq 0 ]] &&
echo -e 'Nothing is installed...\n' ||
echo -e 'There are missing components...\n'
}

repo_installer(){
local X=`awk '{print $1}' $NOT_INST`
echo "Do you want to install "$X"?"
    read -p "[Y/y]/[N/n] " confirm
    case $confirm in
        [Yy]* ) 
		yum -y clean all
		yum -y update
		yum -y install centos-release-scl.noarch
		yum -y install $X
		;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no. ";;
    esac
}

full_setting_added_repo(){
INDEX_PATH_DIR="/var/www/${HOSTNAME}"
CONF_PATH_DIR="/etc/nginx/conf.d/"
echo -e "Create by ${HOSTNAME}\n"
echo -e 'Create web directory...\n'
[ -d "$INDEX_PATH_DIR" ] || mkdir -p "$INDEX_PATH_DIR"
echo -e "Created derectory path ${HOSTNAME}\n"
echo -e 'Create logs files...\n'
sudo touch /var/log/nginx/access_${HOSTNAME}.log
sudo touch /var/log/nginx/error_${HOSTNAME}.log
#echo -e 'check who is owner original "/var/log/nginx/access.log" file...\n'
#ls -l /var/log/nginx/access.log | awk '{print $3}'
#ls -l /var/log/nginx/access.log | awk '{print $4}'
#echo -e 'set variables...\n'
#username=$(sudo ls -l /var/log/nginx/access.log | awk '{print $3}')
#usergroup=$(sudo ls -l /var/log/nginx/access.log | awk '{print $4}')
#echo -e 'chown the owner of your files...\n'
#chown $username:$usergroup /var/log/nginx/access_${HOSTNAME}.log
#chown $username:$usergroup /var/log/nginx/error_${HOSTNAME}.log
echo -e 'Copy nginx.conf...\n'
. ./nginx.file
echo -e 'Copy index.php...\n'
. ./index.file
echo -e 'Change in the nginx.conf - default server {} | sed -i s/80 default_server;/80;/\n'
sed -i 's/listen       80 default_server;/listen       80;/' /etc/nginx/nginx.conf
echo -e 'change default user/group on php-fpm...\n'
sed -i 's/user = apache/user = nginx/' /etc/opt/rh/rh-php70/php-fpm.d/www.conf
sed -i 's/group = apache/group = nginx/' /etc/opt/rh/rh-php70/php-fpm.d/www.conf
echo 'Print version...'
for i in `which $PUSH`; do $i -v; done; rpm -qa |grep fpm
}


### HALF WITH MariaDB:
### off_repo
off_preinstall_with_db_check(){
INST="/tmp/installed_soft.log"
NOT_INST="/tmp/not_installed_soft.log"
SOFT="nginx php-fpm php php-opcache php-cli php-gd php-curl php-mysql mariadb-server mariadb-client"
PUSH="nginx php-fpm mariadb"
:> "$INST" && :> "$NOT_INST"
echo -e 'Checking that the product already is installed...\n'
for i in $SOFT
do if rpm -q "$i" >> "$INST"; then
echo -e "$i is installed..\n"
else
echo -e " "$i" not installed..\n"
echo "$i" >> "$NOT_INST"
fi; done
SIZE=$(stat -c%s "$NOT_INST")
[[ "$SIZE" -eq 0 ]] && echo -e 'All is installed...\n' &&  exit 0 ||
[[ X=$(  echo "$SOFT" | sed 's/ \+/\n/g' | cmp -s "$NOT_INST" > /dev/null; echo $?) -eq 0 ]] &&
echo -e 'Nothing is installed...\n' ||
echo -e 'There are missing components...\n'
}

full_setting_off_repo_with_db(){
INDEX_PATH_DIR="/var/www/${HOSTNAME}"
CONF_PATH_DIR="/etc/nginx/conf.d/"
echo -e "Create by ${HOSTNAME}\n"
echo -e 'Create web directory...\n'
[ -d "$INDEX_PATH_DIR" ] || mkdir -p "$INDEX_PATH_DIR"
echo -e "Created derectory path ${HOSTNAME}\n"
echo -e 'Create logs files...\n'
sudo touch /var/log/nginx/access_${HOSTNAME}.log
sudo touch /var/log/nginx/error_${HOSTNAME}.log
echo -e 'Check who is owner original "/var/log/nginx/access.log" file...\n'
ls -l /var/log/nginx/access.log | awk '{print $3}'
ls -l /var/log/nginx/access.log | awk '{print $4}'
echo -e 'Set variables...\n'
username=$(sudo ls -l /var/log/nginx/access.log | awk '{print $3}')
usergroup=$(sudo ls -l /var/log/nginx/access.log | awk '{print $4}')
echo -e 'Chown the owner of your files...\n'
chown $username:$usergroup /var/log/nginx/access_${HOSTNAME}.log
chown $username:$usergroup /var/log/nginx/error_${HOSTNAME}.log
echo -e 'Copy nginx.conf...\n'
. ./nginx.file
echo -e 'Copy index.php...\n'
. ./index.file
echo -e 'Change in the nginx.conf - default server {} | sed -i s/80 default_server;/80;/\n'
sed -i 's/listen       80 default_server;/listen       80;/' /etc/nginx/nginx.conf
echo -e 'change default user/group on php-fpm...\n'
sed -i 's/user = apache/user = nginx/' /etc/php-fpm.d/www.conf
sed -i 's/group = apache/group = nginx/' /etc/php-fpm.d/www.conf
echo 'Print version...'
#for i in `which $PUSH`; do $i -v; done
rpm -qa |grep 'nginx'
rpm -qa |grep 'fpm'
rpm -qa |grep 'mariadb'
}



### added_repo
repo_preinstall_with_db_check(){
INST="/tmp/installed_soft.log"
NOT_INST="/tmp/not_installed_soft.log"
SOFT="nginx rh-php70 rh-php70-php rh-php70-php-fpm mariadb-server mariadb-client"
PUSH="nginx mariadb"
:> "$INST" && :> "$NOT_INST"
echo -e 'Checking that the product already is installed...\n'
for i in $SOFT
do if rpm -q "$i" >> "$INST"; then
echo -e "$i is installed..\n"
else
echo -e " "$i" not installed..\n"
echo "$i" >> "$NOT_INST"
fi; done
SIZE=$(stat -c%s "$NOT_INST")
[[ "$SIZE" -eq 0 ]] && echo -e 'All is installed...\n' &&  exit 0 ||
[[ X=$(  echo "$SOFT" | sed 's/ \+/\n/g' | cmp -s "$NOT_INST" > /dev/null; echo $?) -eq 0 ]] &&
echo -e 'Nothing is installed...\n' ||
echo -e 'There are missing components...\n'
}

repo_installer_with_db(){
local X=`awk '{print $1}' $NOT_INST`
echo "Do you want to install "$X"?"
    read -p "[Y/y]/[N/n] " confirm
    case $confirm in
        [Yy]* )
                yum -y clean all
.		./db_repo.sh
                yum -y update
                yum -y install $X
                ;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no. ";;
    esac
}

full_setting_added_with_db_repo(){
INDEX_PATH_DIR="/var/www/${HOSTNAME}"
CONF_PATH_DIR="/etc/nginx/conf.d/"
echo -e "Create by ${HOSTNAME}\n"
echo -e 'Create web directory...\n'
[ -d "$INDEX_PATH_DIR" ] || mkdir -p "$INDEX_PATH_DIR"
echo -e "Created derectory path ${HOSTNAME}\n"
echo -e 'Create logs files...\n'
sudo touch /var/log/nginx/access_${HOSTNAME}.log
sudo touch /var/log/nginx/error_${HOSTNAME}.log
echo -e 'Copy nginx.conf...\n'
. ./nginx.file
echo -e 'Copy index.php...\n'
. ./index.file
echo -e 'Change in the nginx.conf - default server {} | sed -i s/80 default_server;/80;/\n'
sed -i 's/listen       80 default_server;/listen       80;/' /etc/nginx/nginx.conf
echo -e 'change default user/group on php-fpm...\n'
sed -i 's/user = apache/user = nginx/' /etc/opt/rh/rh-php70/php-fpm.d/www.conf
sed -i 's/group = apache/group = nginx/' /etc/opt/rh/rh-php70/php-fpm.d/www.conf
echo 'Print version...'
rpm -qa |grep 'nginx'
rpm -qa |grep 'fpm'
rpm -qa |grep 'mariadb'
}

