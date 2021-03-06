#!/bin/bash

set -e

UBUNTU="ubuntu:bionic"
DEBIAN="debian:10-slim"


docker pull ${IMAGE}
docker run -it -d --name build-api ${IMAGE} bash

# deps
docker exec build-api apt update
docker exec build-api apt install build-essential devscripts lintian dh-make git python3 python3-dev python3-pip unzip sudo python3-all python-all cmake wget -y
docker exec build-api pip3 install pyangbind sphinx stdeb
docker exec build-api bash -c "cd /root/ && git clone https://github.com/atolab/zenoh-c -b 0.3.0 --depth 1 && cd zenoh-c && make && make install"
docker exec build-api bash -c "cd /root/ && git clone https://github.com/atolab/zenoh-python -b 0.3.0 --depth 1 && cd zenoh-python && python3 setup.py install"
docker exec build-api bash -c "cd /root/ && git clone https://github.com/atolab/yaks-python -b 0.3.0 --depth 1 && cd yaks-python && make install"
docker exec build-api bash -c "cd /root/ && git clone https://github.com/eclipse-fog05/api-python -b ${BRANCH} --depth 1 fog05-api-${VERSION}"
# normalize version to facilitate build
docker exec -e VERSION=${VERSION} build-api bash -c 'sed -i "s/0.2.0a/${VERSION}/g" /root/fog05-api-${VERSION}/setup.py'

#build deb
docker exec build-api bash -c "cd /root && mkdir build && tar -czvf build/fog05-api-${VERSION}.tar.gz fog05-api-${VERSION}"
docker exec build-api bash -c "cd /root/build && py2dsc fog05-api-${VERSION}.tar.gz"
docker exec build-api bash -c "cd /root/build/deb_dist/fog05-${VERSION} && dpkg-buildpackage -rfakeroot -uc -us"
docker exec build-api bash -c "cd /root/build/deb_dist/ && dpkg -I python3-fog05_${VERSION}-1_all.deb"
docker cp build-api:/root/build/deb_dist/python3-fog05_${VERSION}-1_all.deb ../python3-fog05_${VERSION}-1_all.deb

docker container rm --force build-api