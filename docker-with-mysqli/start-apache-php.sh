#!/usr/bin/env bash

# Lets use the project folder as the name for our docker container.
PROJECT=`basename $(pwd)`

# If port is Zero, a free port is assigned avoiding collisions with other projects.
PORT="5520"

# Run docker
#  -v `pwd`/docker/php.ini:/usr/local/etc/php/conf.d/php.ini \
docker run -dit --name "$PROJECT" -p $PORT:80 \
  -v `pwd`:/var/www/html \
  -v `pwd`/docker/apache.conf:/etc/apache2/sites-enabled/000-default.conf \
  php:8.1-apache

docker exec $PROJECT docker-php-ext-install mysqli
docker exec $PROJECT apachectl restart

# Show the user the container info
docker ps | grep $PROJECT
# https://docs.docker.com/network/network-tutorial-standalone/
echo "Type docker inspect network bridge to see the ip addresses given to stand alone containers.
You will need these ips to connect containers together without docker compose."
