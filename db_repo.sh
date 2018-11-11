cat <<EOF > /etc/yum.repos.d/mariadb.repo
# MariaDB 10.2 CentOS repository list - created 2018-11-11 11:42 UTC
# http://downloads.mariadb.org/mariadb/repositories/
[mariadb]
name = MariaDB
baseurl = http://yum.mariadb.org/10.2/centos7-amd64
gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
gpgcheck=1
EOF
