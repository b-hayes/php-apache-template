#!/usr/bin/env bash

# Lets use the project folder as the name for our docker container.
PROJECT=`basename $(pwd)`

# If port is Zero, a free port is assigned avoiding collisions with other projects.
PORT="5521"

# Run docker
#  -v "$(pwd)/docker/database:/var/lib/mysql" \
docker run -dit --name "$PROJECT-mysql" -p $PORT:3306 \
  -e MYSQL_ROOT_PASSWORD=localdev \
  mysql

# Show the user the container info
docker ps | grep $PROJECT

# create schema falling_trash collate utf8mb4_unicode_ci;
