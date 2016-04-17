# centos-lamp
A CentOS 7 Docker LAMP suitable for local Drupal or WordPress development.

# features
- Centos 7
- Apache 2.4
- MariaDB 10.1
- PHP 5.6
- SSH
- phpMyAdmin
- Git
- Drush
- NodeJS

# example usage (recommend Ubuntu 14.10 or Fedora 23 for local development).

Create a project folder and database folder.

`mkdir -p project/database`

Move into the project folder.

`cd project`

Run the command to launch the docker and map project and database directory.

``docker run -d -p 8080:80 -p 8022:22 -v `pwd`:/var/www/html -v `pwd`/database:/var/lib/phpMyAdmin/upload -t otherdata/centos-lamp``

# usage notes

You can now move a copy of your Drupal or WordPress files into the project folder, and move an .sql dump into the database folder. 

To access the local docker visit http://localhost:8080.  

To access phpMyadmin visit http://localhost:8080/phpmyadmin.   
