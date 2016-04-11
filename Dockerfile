FROM centos:centos7
MAINTAINER Wesley Render <info@otherdata.com>

# Install varioius utilities
RUN yum -y install curl wget unzip git \
iproute python-setuptools hostname inotify-tools yum-utils which

# Install OpenSSH server and SSH client
RUN yum install -y openssh-server
RUN yum install -y openssh-clients

#Configure SSH
RUN ssh-keygen -b 1024 -t rsa -f /etc/ssh/ssh_host_key
RUN ssh-keygen -b 1024 -t rsa -f /etc/ssh/ssh_host_rsa_key
RUN ssh-keygen -b 1024 -t dsa -f /etc/ssh/ssh_host_dsa_key
RUN sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config
RUN sed -ri 's/#UsePAM no/UsePAM no/g' /etc/ssh/sshd_config

#Set root password
RUN echo root:docker | chpasswd

# Install passwd
RUN yum install -y passwd


# Install EPEL Repository
RUN yum -y install epel-release

# Install Python and Supervisor
RUN yum -y install python-setuptools
RUN mkdir -p /var/log/supervisor
RUN easy_install supervisor

# Install Apache
RUN yum -y install httpd

# Install Remi Updated PHP 7
RUN wget http://rpms.remirepo.net/enterprise/remi-release-7.rpm
RUN rpm -Uvh remi-release-7.rpm
RUN yum-config-manager --enable remi-php70

RUN yum -y install php php-devel php-gd php-pdo php-soap php-xmlrpc php-xml

# Install phpMyAdmin
RUN yum -y install phpmyadmin
RUN sed -i 's/Require ip 127.0.0.1//g' /etc/httpd/conf.d/phpMyAdmin.conf
RUN sed -i 's/Require ip ::1/Require all granted/g' /etc/httpd/conf.d/phpMyAdmin.conf
RUN sed -i 's/Allow from 127.0.0.1/Allow from all/g' /etc/httpd/conf.d/phpMyAdmin.conf
RUN sed -i "s/'cookie'/'config'/g" /etc/phpMyAdmin/config.inc.php
RUN sed -i "s/\['user'\] .*= '';/\['user'\] = 'root';/g" /etc/phpMyAdmin/config.inc.php
RUN sed -i "/AllowNoPassword.*/ {N; s/AllowNoPassword.*FALSE/AllowNoPassword'] = TRUE/g}" /etc/phpMyAdmin/config.inc.php


# Install MariaDB
COPY MariaDB.repo /etc/yum.repos.d/MariaDB.repo
RUN yum clean all
RUN yum -y install mariadb-server mariadb-client
VOLUME /var/lib/mysql
EXPOSE 3306

# -----------------------------------------------------------------------------
# UTC Timezone & Networking
# -----------------------------------------------------------------------------
RUN ln -sf /usr/share/zoneinfo/UTC /etc/localtime \
	&& echo "NETWORKING=yes" > /etc/sysconfig/network


COPY supervisord.conf /etc/supervisord.conf
EXPOSE 22 80
CMD ["/usr/bin/supervisord"]
