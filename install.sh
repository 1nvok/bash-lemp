#!/bin/env bash
export PATH="/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin"
source ./options.conf

echo 'Install back-end web stack (LEMP):'
echo '1) Install from Official repository.'
echo '2) Install using the added repository.'
echo '3) Exit.'

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
finish_off
http_firewall-cmd
[[ "$?" -eq 0  ]] && echo -e 'cheers! \n' || exit 1
;;
     3)
exit 0
;; 
     *)
echo "Select some solution..."
;;
esac
