#!/bin/bash

set -e

# UBUNTU="ubuntu:bionic"
# DEBIAN="debian:10-slim"

lxc launch images:${IMAGE} build
sleep 2
# install deps
lxc exec build -- apt update
lxc exec build -- apt install build-essential devscripts lintian dh-make git wget jq unzip cmake sudo -y
lxc exec build -- pip3 install pyangbind sphinx
lxc exec build -- bash -c "cd /root/ && git clone https://github.com/atolab/zenoh-c -b 0.3.0 --depth 1 && cd zenoh-c && make && make install"
lxc exec build -- bash -c "cd /root/ && git clone https://github.com/atolab/zenoh-python -b 0.3.0 --depth 1 && cd zenoh-python && python3 setup.py install"
lxc exec build -- bash -c "cd /root/ && git clone https://github.com/atolab/yaks-python -b 0.3.0 --depth 1 && cd yaks-python && make install"
lxc exec build -- bash -c "cd /root/ && git clone https://github.com/eclipse-fog05/sdk-python -b master --depth 1 && cd sdk-python && make && make install"
lxc exec build -- bash -c "cd /root/ && git clone https://github.com/eclipse-fog05/api-python -b master  --depth 1 && cd api-python && make install"

# clone repo
lxc exec build -- bash -c "cd /root/ && git clone https://github.com/eclipse-fog05/plugin-fdu-lxd -b ${BRANCH} --depth 1"
# building a debian package

lxc exec build -- bash -c "mkdir /root/build && cd /root && cp -r plugin-fdu-lxd build/fog05-plugin-fdu-lxd-${VERSION} && cd build/fog05-plugin-fdu-lxd-${VERSION} && rm -rf .git && make clean && cd .. && tar -czvf fog05-plugin-fdu-lxd-${VERSION}.tar.gz fog05-plugin-fdu-lxd-${VERSION}"
lxc exec build -- bash -c "export DEBEMAIL=\"info@adlink-labs.tech\" && export DEBFULLNAME=\"ADLINK Technology Inc\" && cd /root/build/fog05-plugin-fdu-lxd-${VERSION} && dh_make -f ../fog05-plugin-fdu-lxd-${VERSION}.tar.gz -s -y"
lxc exec --env VERSION=${VERSION} build -- bash -c 'cd /root/build/fog05-plugin-fdu-lxd-${VERSION} && printf "override_dh_auto_install:\n\tmkdir -p \$\$(pwd)/debian/fog05-plugin-fdu-lxd/lib/systemd/system/\n\t\$(MAKE) lxd_PLUGIN_DIR=\$\$(pwd)/debian/fog05-plugin-fdu-lxd/etc/fos/plugins/plugin-fdu-lxd SYSTEMD_DIR=\$\$(pwd)/debian/fog05-plugin-fdu-lxd/lib/systemd/system/ install">> debian/rules'

sed -i "s/FOSVERSION/${VERSION}/g" templates/changelog
lxc file push templates/changelog build/root/build/fog05-plugin-fdu-lxd-${VERSION}/debian/changelog
lxc file push templates/postinst build/root/build/fog05-plugin-fdu-lxd-${VERSION}/debian/postinst
lxc file push templates/postrm build/root/build/fog05-plugin-fdu-lxd-${VERSION}/debian/postrm
lxc file push templates/control build/root/build/fog05-plugin-fdu-lxd-${VERSION}/debian/control
lxc file push templates/copyright build/root/build/fog05-plugin-fdu-lxd-${VERSION}/debian/copyright

lxc exec build -- bash -c "cd /root/build/fog05-plugin-fdu-lxd-${VERSION} && debuild --preserve-envvar PATH -us -uc  && ls -l ../"
lxc exec build -- bash -c "cd /root/build/ && dpkg -I fog05-plugin-fdu-lxd_${VERSION}-1_amd64.deb"


lxc file pull build/root/build/fog05-plugin-fdu-lxd_${VERSION}-1_amd64.deb ../fog05-plugin-fdu-lxd_${VERSION}-1_amd64_${IMAGE}.deb

lxc delete --force build