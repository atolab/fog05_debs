from debian:10-slim

LABEL authors="Gabriele Baldoni"



RUN DEBIAN_FRONTEND=noninteractive apt-get update -qq && \
    DEBIAN_FRONTEND=noninteractive apt-get -y install  python3 python3-pip jq git
COPY libzenoh-0.3.0-Linux.deb /root/
COPY fog05-0.2.0.tar.gz /root/
COPY docker_run.py /root
RUN dpkg -i /root/libzenoh-0.3.0-Linux.deb
RUN pip3 install pyangbind sphinx psutil netifaces jinja2 zenoh==0.3.0 yaks==0.3.0.post1
RUN cd /root && tar -xzvf fog05-0.2.0.tar.gz
COPY templates/Makefile_agent /root/agent/Makefile
RUN cd /root/agent && make install
RUN cd /root/ && git clone https://github.com/eclipse-fog05/sdk-python/ && cd sdk-python && make && make install
RUN cd /root && git clone https://github.com/eclipse-fog05/api-python/ && cd api-python && make install
RUN cd /root && git clone https://github.com/eclipse-fog05/plugin-os-linux
RUN cd /root && git clone https://github.com/eclipse-fog05/plugin-net-linuxbridge
RUN cd /root && git clone https://github.com/eclipse-fog05/plugin-fdu-native

COPY templates/Makefile_linux /root/plugin-os-linux/Makefile
COPY templates/Makefile_linuxbridge /root/plugin-net-linuxbridge/Makefile
COPY templates/Makefile_native /root/plugin-fdu-native/Makefile

RUN cd /root/plugin-os-linux && make install
RUN cd /root/plugin-net-linuxbridge && make install
RUN cd /root/plugin-fdu-native/ && make && make install

RUN mkdir -p /var/fos

CMD python3 /root/docker_run.py