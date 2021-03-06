#!/bin/bash

set -e

# UBUNTU="ubuntu:bionic"
# DEBIAN="debian:10-slim"

lxc launch images:${IMAGE} build-api
sleep 2
# install deps
lxc exec build-api -- apt update
lxc exec build-api -- apt install build-essential devscripts lintian dh-make git python3 python3-dev python3-pip unzip sudo python3-all python-all cmake wget -y
lxc exec build-api -- pip3 install pyangbind sphinx stdeb
lxc exec build-api -- bash -c "cd /root/ && git clone https://github.com/atolab/zenoh-c -b 0.3.0 --depth 1 && cd zenoh-c && make && make install"
lxc exec build-api -- bash -c "cd /root/ && git clone https://github.com/atolab/zenoh-python -b 0.3.0 --depth 1 && cd zenoh-python && python3 setup.py install"
lxc exec build-api -- bash -c "cd /root/ && git clone https://github.com/atolab/yaks-python -b 0.3.0 --depth 1 && cd yaks-python && make install"

# clone repo
lxc exec build-api -- bash -c "cd /root/ && git clone https://github.com/eclipse-fog05/sdk-python -b ${BRANCH} --depth 1 fog05-sdk-${VERSION}"

# normalize version to facilitate build
lxc exec --env VERSION=${VERSION} build-api -- bash -c 'sed -i "s/0.2.0a/${VERSION}/g" /root/fog05-sdk-${VERSION}/setup.py'

# building a debian package
lxc exec build-api -- bash -c "cd /root/fog05-sdk-${VERSION} && make"
lxc exec build-api -- bash -c "cd /root && mkdir build && tar -czvf build/fog05-sdk-${VERSION}.tar.gz fog05-sdk-${VERSION}"
lxc exec build-api -- bash -c "cd /root/build && py2dsc fog05-sdk-${VERSION}.tar.gz"
lxc exec build-api -- bash -c "cd /root/build/deb_dist/fog05-sdk-${VERSION} && dpkg-buildpackage -rfakeroot -uc -us"
lxc exec build-api -- bash -c "cd /root/build/deb_dist/ && dpkg -I python3-fog05-sdk_${VERSION}-1_all.deb"



lxc file pull build-api/root/build/deb_dist/python3-fog05-sdk_${VERSION}-1_all.deb ../python3-fog05-sdk_${VERSION}-1_all.deb

lxc delete --force build-api