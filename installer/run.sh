#!/bin/bash

sudo apt-get update -y
sudo apt-get full-upgrade -y
sudo apt-get install software-properties-common build-essential -y
sudo apt-get install dhcpcd5 lighttpd git hostapd dnsmasq iptables-persistent vnstat qrencode php7.4-cgi dkms libelf-dev hcxtools hcxdumptool -y
cd
git clone https://github.com/aircrack-ng/rtl8812au.git
cd rtl8812au
sed -i 's/CONFIG_PLATFORM_I386_PC = y/CONFIG_PLATFORM_I386_PC = n/g' Makefile
sed -i 's/CONFIG_PLATFORM_ARM64_RPI = n/CONFIG_PLATFORM_ARM64_RPI = y/g' Makefile
make && make install

sudo systemctl enable lighttpd.service
sudo systemctl enable dhcpcd.service
sudo lighttpd-enable-mod fastcgi-php    
sudo service lighttpd force-reload
sudo systemctl restart lighttpd.service
sudo sed -i -E 's/^session\.cookie_httponly\s*=\s*(0|([O|o]ff)|([F|f]alse)|([N|n]o))\s*$/session.cookie_httponly = 1/' /etc/php/7.4/cgi/php.ini
sudo sed -i -E 's/^;?opcache\.enable\s*=\s*(0|([O|o]ff)|([F|f]alse)|([N|n]o))\s*$/opcache.enable = 1/' /etc/php/7.4/cgi/php.ini
sudo phpenmod opcache

echo "net.ipv4.ip_forward=1" | sudo tee /etc/sysctl.d/99-sysctl.conf > /dev/null
sudo sysctl -p /etc/sysctl.d/99-sysctl.conf 
sudo /etc/init.d/procps restart

printf "[NetDev]
Name=br0
Kind=bridge
" > /etc/systemd/network/bridge-br0.netdev

printf "
[Match]
Name=eth0

[Network]
Bridge=br0
" > /etc/systemd/network/br0-member-eth0.network


systemctl enable systemd-networkd
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
iptables-save | sudo tee /etc/iptables/rules.v4
systemctl unmask hostapd.service
systemctl enable hostapd.service

printf "
driver=nl80211
ctrl_interface=/var/run/hostapd
ctrl_interface_group=0
beacon_int=100
auth_algs=1
wpa_key_mgmt=WPA-PSK
ssid=KALI-PI
channel=1
hw_mode=g
wpa_passphrase=ChangeMe
interface=wlan0
bridge=br0
wpa=2
wpa_pairwise=CCMP
country_code=
## Rapberry Pi 3 specific to on board WLAN/WiFi
#ieee80211n=1 # 802.11n support (Raspberry Pi 3)
#wmm_enabled=1 # QoS support (Raspberry Pi 3)
#ht_capab=[HT40][SHORT-GI-20][DSSS_CCK-40] # (Raspberry Pi 3)

## NetAttack bridge AP mode (disabled by default)
#bridge=br0
" > /etc/hostapd/hostapd.conf

printf "
# NetAttack default configuration
hostname
clientid
persistent
option rapid_commit
option domain_name_servers, domain_name, domain_search, host_name
option classless_static_routes
option ntp_servers
require dhcp_server_identifier
slaac private
nohook lookup-hostname

# NetAttack wlan0 configuration
#denyinterfaces wlan0 eth0
interface wlan0
#interface br0
static ip_address=10.3.141.1/24
static routers=10.3.141.1
static domain_name_server=8.8.8.8 8.8.4.4
" > /etc/dhcpcd.conf
sudo systemctl umask lighttpd
sudo systemctl enable lighttpd
cat ${PWD}/lighttpd.conf > /etc/lighttpd/lighttpd.conf

sudo systemctl restart dhcpcd
sudo systemctl enable dnsmasq
sudo systemctl enable hostapd
sudo systemctl reboot
