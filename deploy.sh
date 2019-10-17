apt install hostapd gpsd mc git mosh ntp gpsd-clients screen tmux python-pip python-setuptools python-wheel bdist-wheel isc-dhcp-server vim-nox lsof tcpdump
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

mkdir /var/log/boatd

echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf


#tmux wants the US locale
echo "enable en_US UTF8 locale"
dpkg-reconfigure locales

#enable SSHD
systemctl enable ssh


#install platformio
wget https://raw.githubusercontent.com/platformio/platformio/develop/scripts/get-platformio.py
python get-platformio.py
#put platformio in the path
echo "export PATH=$PATH:/home/pi/.local/bin/" >> ~/.bashrc

export PATH=$PATH:/home/pi/.local/bin/


sudo pip install python-boatdclient

cd /home/pi
git clone --recursive https://github.com/abersailbot/dewi
cd dewi
cd boatd
sudo python setup.py install
cd ..
cd dewi-boatd-driver
sudo ln -s dewi_boatd_driver.py /usr/local/lib/python2.7/dist-packages

#gopro stuff, not sure if this is needed?
sudo pip install gopro goprocam
sudo apt install python-opencv
