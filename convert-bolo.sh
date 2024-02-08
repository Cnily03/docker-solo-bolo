#!/bin/bash

sed -i s/solo/bolo/g ./extract.sh
sed -i s/solo/bolo/g ./docker-compose.yml
sed -i s/solo/bolo/g ./mysql/solo.init.sh
sed -i s/solo/bolo/g ./mysql/Dockerfile

sed -i s/b3log\/bolo/tangcuyu\/bolo-solo/g ./extract.sh
sed -i s/b3log\/bolo/tangcuyu\/bolo-solo/g ./docker-compose.yml