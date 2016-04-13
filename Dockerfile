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

# Reconfigure Apache
RUN sed -i 's/AllowOverride None/AllowOverride All/g' /etc/httpd/conf/httpd.conf

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

# Setup Drush
RUN wget http://files.drush.org/drush.phar
RUN chmod +x drush.phar
RUN mv drush.phar /usr/local/bin/drush


# UTC Timezone & Networking
RUN ln -sf /usr/share/zoneinfo/UTC /etc/localtime \
	&& echo "NETWORKING=yes" > /etc/sysconfig/network

# Install Drupal.
RUN rm -rf /var/www/html
RUN cd /var/www && \
	drush dl drupal-7 && \
	mv /var/www/drupal* /var/www/html
RUN mkdir -p /var/www/html/sites/default/files && \
	chmod a+w /var/www/html/sites/default -R && \
	mkdir /var/www/html/sites/all/modules/contrib -p && \
	mkdir /var/www/html/sites/all/modules/custom && \
	mkdir /var/www/html/sites/all/themes/contrib -p && \
	mkdir /var/www/html/sites/all/themes/custom && \
	chown -R apache:apache /var/www/html

COPY supervisord.conf /etc/supervisord.conf
EXPOSE 22 80
CMD ["/usr/bin/supervisord"]

RUN cd /var/www/html && \
	drush si -y minimal --db-url=mysql://root:@localhost/drupal --account-pass=admin && \
	drush dl admin_menu devel && \
	drush en -y admin_menu simpletest devel && \
	drush vset "admin_menu_tweak_modules" 1 && \
	drush vset "admin_theme" "seven" && \
	drush vset "node_admin_theme" 1