# -*-Makefile-*-

LINUX_PLUGIN_DIR = /etc/fos/plugins/plugin-os-linux
LINUX_PLUGIN_CONFFILE = /etc/fos/plugins/plugin-os-linux/linux_plugin.json


clean:
	echo "nothing to do..."

all:
	echo "Nothing to do..."


install:
	mkdir -p $(LINUX_PLUGIN_DIR)
	cp -r scripts $(LINUX_PLUGIN_DIR)
	cp linux_plugin $(LINUX_PLUGIN_DIR)
	cp fos_linux.service $(LINUX_PLUGIN_DIR)
	cp linux_plugin.json $(LINUX_PLUGIN_DIR)

