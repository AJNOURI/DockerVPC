#!/bin/bash

# AJN: ajn.bin@gmail.com

echo ''
echo ''
# Stop running containers
echo 'Stopping all running containers...'
if [[ -n $(docker ps -q) ]]; then
    docker stop $(docker ps -q)
else
    echo "No running containers."
fi

# Removing stopped containers
echo ''
echo ''
echo 'Removing all stopped containers...'
if [[ -n $(docker ps -a -q) ]]; then
    docker rm $(docker ps -a -q)
else
    echo "No containers found."
fi

# Delete all images:
# Before doing so, make sure you are generating image from Dockerfile 
# or have pushed your image to DockerHub

function del_images(){
    if [[ -n $(docker images -q) ]]; then
        docker rmi -f $(docker images -q)
    else
        echo "No images found."
    fi
}

echo ''
echo ''
echo -e 'Erasing all images...\nMake sure you are generating image from a Dockerfile \nor have pushed your images to DockerHub.'

while true; do
    read -p '*** Do you want to continue? ' resp
    case $resp in
        [Yy]* ) del_images; break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes [Yy]* or no [Nn]*";;
    esac
done
