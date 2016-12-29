# CentOS LAMP
A CentOS 7 Docker LAMP suitable for local Drupal or WordPress development. This is meant to simulate a development environment compatible with cPanel hosting. This container is ideal for running on Linux, Windows or Mac as everything is in one container.

# Features
- CentOS 7
- Apache 2.4 (w/ SSL)
- MariaDB 10.1
- PHP 7.0 or 5.6
- SSH
- phpMyAdmin
- Git
- Drush
- NodeJS

# Example Usage with Data Inside Docker

 Download and run this container with: 
``docker run -d -p 8080:80 -p 8443:443 -p 8220:22 -t otherdata/centos-lamp:7``

Or to run it with older PHP 5.6 run the container with:
``docker run -d -p 8080:80 -p 8443:443 -p 8220:22 -t otherdata/centos-lamp:5.6``

To access the web server visit https://localhost:8443 or http://localhost:8080

To access phpMyadmin visit https://localhost:8080/phpmyadmin

Attach to the container by running:
`sudo docker exec -i -t "your container id" /bin/bash`

Put your web code in /var/www/html/ inside the docker.

# Example Usage with Data Outside of Docker

Create a project folder and database folder:
`mkdir -p project/database`
`mkdir -p project/html`

Move into the project folder:
`cd project`

Run the command to launch the docker and map project and database directory:
``docker run -d -p 8080:80 -p 8443:443 -p 8022:22 -v `pwd`/html:/var/www/html -v `pwd`/database:/var/lib/phpMyAdmin/upload -t otherdata/centos-lamp:7``

You can now move a copy of your Drupal or WordPress files into the html folder and move an .sql dump into the database folder (Or upload it using phpMyAdmin). 

To access the web server visit https://localhost:8443 or http://localhost:8080

To access phpMyadmin visit https://localhost:8080/phpmyadmin