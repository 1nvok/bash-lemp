#!/bin/env bash
export PATH="/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin"
source ./options.sh

echo 'Install back-end web stack (LEMP):'
echo 'Taken repository MariaDB: https://downloads.mariadb.org/mariadb/repositories/'
echo "Taken repository Nginx: http://nginx.org/packages/centos/$releasever/$basearch/"
echo '---------------------------------------------------------------------------------'
echo '1) Install from Official repository. (without MariaDB)'
echo '2) Install using the added repository. (without MariaDB)'
echo '3) Install from Official repository. (with MariaDB)'
echo '4) Install using the added repository. (with MariaDB)'
echo '5) Exit.'

read select
case $select in
     1)
off_preinstall_check
warn_php
off_installer
full_setting_off_repo
finish_off
http_firewall-cmd
[[ "$?" -eq 0  ]] && echo -e 'cheers! \n' || exit 1
;;
     2)
repo_preinstall_check
warn_php
repo_installer
full_setting_added_repo
finish_off
http_firewall-cmd
[[ "$?" -eq 0  ]] && echo -e 'cheers! \n' || exit 1
;;
     3)
off_preinstall_with_db_check
warn_php
repo_installer
full_setting_off_repo_with_db
finish_off
mysql_secure_installation
http_firewall-cmd
[[ "$?" -eq 0  ]] && echo -e 'cheers! \n' || exit 1
;;
     4)
repo_preinstall_with_db_check
warn_php
repo_installer_with_db
full_setting_added_with_db_repo
finish_off
mysql_secure_installation
http_firewall-cmd
[[ "$?" -eq 0  ]] && echo -e 'cheers! \n' || exit 1
;;
     5)
exit 0
;; 
     *)
echo "Select some solution..."
;;
esac

