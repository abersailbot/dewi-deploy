
#!/bin/bash

#exit if any command fails
set -e 

if [ `whoami` != "root" ] ; then
    echo "Rerun as root"
    exit 1
fi


apt -y update
apt -y install hostapd gpsd mc git mosh ntp gpsd-clients screen tmux isc-dhcp-server vim-nox lsof tcpdump libyaml-dev python3-pip i2c-tools python3-gps
apt -y upgrade


cd /home/pi
git clone --recursive https://github.com/abersailbot/dewi
chown -R pi:pi /home/pi/dewi
cd /home/pi/dewi/dewi-deploy


cp gpsd /etc/default/gpsd
cp boatd-config.yaml /etc/
cp interfaces /etc/network/
cp *.rules /etc/udev/rules.d
cp iptables.ipv4.nat /etc
cp hostapd.conf /etc/hostapd
cp hostapd /etc/default/hostapd
cp isc-dhcp-server /etc/default/isc-dhcp-server
cp dhcpd.conf /etc/dhcp/dhcpd.conf
cp cmdline.txt /boot/cmdline.txt
cp motd /etc/motd
cp ntp.conf /etc/ntp.conf

mkdir /var/log/boatd

echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf


#tmux wants the US locale
echo "enable en_US UTF8 locale"
dpkg-reconfigure locales

#enable SSHD
systemctl enable ssh

#enable hostapd
systemctl unmask hostapd
systemctl enable hostapd

#install platformio
wget https://raw.githubusercontent.com/platformio/platformio/develop/scripts/get-platformio.py
python get-platformio.py
#put platformio in the path
echo "export PATH=$PATH:/home/pi/.local/bin/" >> ~/.bashrc

export PATH=$PATH:/home/pi/.local/bin/

pip3 install python-boatdclient


cd /home/pi/dewi/boatd
python setup.py install
cd ..
cd dewi-boatd-driver
ln -s dewi_boatd_driver.py /usr/local/lib/python3.9/dist-packages

#change boatd to run in python3
#sed -i 's@^#!/usr/bin/python$@#!/usr/bin/python3@' /usr/local/bin/boatd #python should be python3 in bullseye

#set the password to something more secure
usermod -p '$y$j9T$IwYFbW41/eIkEvEt2BpDT1$kMm4COOzc9kgDOmda7jLzv.GKR4pHZoYIA87R7LeZV6' pi

#install SSH keys
mkdir /home/pi/.ssh
chmod 700 /home/pi/.ssh
cp /home/pi/dewi/dewi-deploy/authorized_keys /home/pi/.ssh/authorized_keys
chmod 600 /home/pi/.ssh/authorized_keys
chown -R pi:pi /home/pi/.ssh

#set the timezone
rm /etc/localtime
ln -s /usr/share/zoneinfo/Etc/UTC /etc/localtime

#pi3/4 GPS fixes, turn off bluetooth
echo "dtoverlay=disable-bt" >> /boot/config.txt
systemctl disable hciuart

#gopro stuff, not sure if this is needed?
#sudo pip install gopro goprocam
#sudo apt install python-opencv
