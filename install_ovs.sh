#!/bin/bash
# -------------------------------------------------------------------------------
# Filename:    install_ovs.sh
# Revision:    1.0
# Date:        2015/08/20
# Author:      扫地僧
# Email:       446369399@qq.com
# Website:     https://www.gitbook.com/book/yanjianwei/scripture-library/details  
# Description: Script to install the openvswitch 2.3.2 
# Notes:       This script uses the "chmod +x install_ovs.sh;./install_ovs.sh" command
# -------------------------------------------------------------------------------

ovs_version="2.3.2"

if [ "$(id -u)" != "0" ]; then
   echo "You need to be 'root' dude." 
   exit 1
fi
apt-get install gcc make automake
wget http://openvswitch.org/releases/openvswitch-$ovs_version.tar.gz

if [  -d openvswitch-$ovs_version ]
then
   rm -r openvswitch-$ovs_version
fi
tar -xzf openvswitch-$ovs_version.tar.gz

cd openvswitch-$ovs_version
#make clean
./configure --with-linux=/lib/modules/`uname -r`/build 2>/dev/null
make && make install
cd openvswitch-$ovs_version
#insmod ./datapath/linux/openvswitch.ko
make modules_install

mkdir -p /usr/local/etc/openvswitch
ovsdb-tool create /usr/local/etc/openvswitch/conf.db vswitchd/vswitch.ovsschema  2>/dev/null

ovsdb-server -v --remote=punix:/usr/local/var/run/openvswitch/db.sock \
             --remote=db:Open_vSwitch,Open_vSwitch,manager_options \
             --private-key=db:Open_vSwitch,SSL,private_key \
             --certificate=db:Open_vSwitch,SSL,certificate \
             --bootstrap-ca-cert=db:Open_vSwitch,SSL,ca_cert \
             --pidfile --detach

ovs-vsctl --no-wait init
ovs-vswitchd --pidfile --detach
ovs-vsctl show
depmod -A openvswitch
