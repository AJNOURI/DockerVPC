#/bin/bash

echo ""
echo "Running container default IPs"
for id in $(docker ps --format "{{.ID}}")
do
    echo -n "$(docker inspect  -f '{{ .Name }}' $id) :"
    echo "  (eth0) [$id] $(docker inspect -f '{{ .NetworkSettings.IPAddress }}' $id )"
done
echo ""

