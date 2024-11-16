# Домашнее задание VPN
## Цель домашнего задания
## Создать домашнюю сетевую лабораторию. Научится настраивать VPN-сервер в Linux-based системах.

Описание домашнего задания
 - Настроить VPN между двумя ВМ в tun/tap режимах, замерить скорость в туннелях, сделать вывод об отличающихся показателях
 - Поднять RAS на базе OpenVPN с клиентскими сертификатами, подключиться с локальной машины на ВМ

## 1. TUN/TAP режимы VPN


Устанавливаем нужные пакеты и отключаем SELinux
~~~shell
apt update
apt install openvpn iperf3 selinux-utils
setenforce 0
~~~
Настройка сервера

Cоздаем файл-ключ 
~~~shell
openvpn --genkey secret /etc/openvpn/static.key
~~~
Cоздаем конфигурационный файл OpenVPN 
~~~shell
vim /etc/openvpn/server.conf

dev tap 
ifconfig 10.10.10.1 255.255.255.0 
topology subnet 
secret /etc/openvpn/static.key 
comp-lzo 
status /var/log/openvpn-status.log 
log /var/log/openvpn.log  
verb 3 
~~~
Создаем service unit для запуска OpenVPN
~~~shell
 vim /etc/systemd/system/openvpn@.service

[Unit] 
Description=OpenVPN Tunneling Application On %I 
After=network.target 
[Service] 
Type=notify 
PrivateTmp=true 
ExecStart=/usr/sbin/openvpn --cd /etc/openvpn/ --config %i.conf 
[Install] 
WantedBy=multi-user.target
~~~
Запускаем сервис
~~~shell
root@server:/home/vagrant# systemctl status openvpn@server
● openvpn@server.service - OpenVPN Tunneling Application On server
     Loaded: loaded (/etc/systemd/system/openvpn@.service; enabled; vendor preset: enabled)
     Active: active (running) since Sat 2024-11-16 17:29:47 UTC; 17s ago
   Main PID: 2910 (openvpn)
     Status: "Pre-connection initialization successful"
      Tasks: 1 (limit: 1102)
     Memory: 1.6M
        CPU: 8ms
     CGroup: /system.slice/system-openvpn.slice/openvpn@server.service
             └─2910 /usr/sbin/openvpn --cd /etc/openvpn/ --config server.conf

~~~
Настройка клиента:

Cоздаем конфигурационный файл OpenVPN
~~~shell 
vim /etc/openvpn/server.conf

remote 192.168.56.10 
ifconfig 10.10.10.2 255.255.255.0 
topology subnet 
route 192.168.56.0 255.255.255.0 
secret /etc/openvpn/static.key
comp-lzo
status /var/log/openvpn-status.log 
log /var/log/openvpn.log 
verb 3 
~~~
 
На хост клиента копируем ключ
~~~shell
root@server:/home/vagrant# scp /etc/openvpn/static.key root@192.168.56.20:/etc/openvpn/
~~~
Создаем service unit для запуска OpenVPN
~~~shell
vim /etc/systemd/system/openvpn@.service
    
[Unit] 
Description=OpenVPN Tunneling Application On %I 
After=network.target 
[Service] 
Type=notify 
PrivateTmp=true 
ExecStart=/usr/sbin/openvpn --cd /etc/openvpn/ --config %i.conf 
[Install] 
WantedBy=multi-user.target
~~~

Запускаем сервис
~~~shell
root@client:/home/vagrant# systemctl status openvpn@server
● openvpn@server.service - OpenVPN Tunneling Application On server
     Loaded: loaded (/etc/systemd/system/openvpn@.service; enabled; vendor preset: enabled)
     Active: active (running) since Sat 2024-11-16 17:47:30 UTC; 17s ago
   Main PID: 2949 (openvpn)
     Status: "Initialization Sequence Completed"
      Tasks: 1 (limit: 1102)
     Memory: 1.6M
        CPU: 10ms
     CGroup: /system.slice/system-openvpn.slice/openvpn@server.service
             └─2949 /usr/sbin/openvpn --cd /etc/openvpn/ --config server.conf
~~~

необходимо замерить скорость в туннеле:
~~~shell
root@client:/home/vagrant#  iperf3 -c 10.10.10.1 -t 40 -i 5
Connecting to host 10.10.10.1, port 5201
[  5] local 10.10.10.2 port 56562 connected to 10.10.10.1 port 5201
[ ID] Interval           Transfer     Bitrate         Retr  Cwnd
[  5]   0.00-5.00   sec   203 MBytes   341 Mbits/sec   53    930 KBytes       
[  5]   5.00-10.00  sec   106 MBytes   178 Mbits/sec  908    308 KBytes       
[  5]  10.00-15.00  sec   105 MBytes   176 Mbits/sec   17    408 KBytes       
[  5]  15.00-20.00  sec   116 MBytes   195 Mbits/sec    0    575 KBytes       
[  5]  20.00-25.00  sec  98.8 MBytes   166 Mbits/sec    0    839 KBytes       
[  5]  25.00-30.00  sec   100 MBytes   168 Mbits/sec   13   1.13 MBytes       
[  5]  30.00-35.00  sec   102 MBytes   172 Mbits/sec    1   1005 KBytes       
[  5]  35.00-40.00  sec  98.8 MBytes   166 Mbits/sec    0   1.06 MBytes       
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bitrate         Retr
[  5]   0.00-40.00  sec   931 MBytes   195 Mbits/sec  992             sender
[  5]   0.00-40.10  sec   929 MBytes   194 Mbits/sec                  receiver

iperf Done.
~~~

Проверяем в режиме работы tun.

~~~shell
~~~shell
root@client:/home/vagrant#  iperf3 -c 10.10.10.1 -t 40 -i 5
Connecting to host 10.10.10.1, port 5201
[  5] local 10.10.10.2 port 56562 connected to 10.10.10.1 port 5201
[ ID] Interval           Transfer     Bitrate         Retr  Cwnd
[  5]   0.00-5.00   sec   203 MBytes   341 Mbits/sec   53    930 KBytes       
[  5]   5.00-10.00  sec   106 MBytes   178 Mbits/sec  908    308 KBytes       
[  5]  10.00-15.00  sec   105 MBytes   176 Mbits/sec   17    408 KBytes       
[  5]  15.00-20.00  sec   116 MBytes   195 Mbits/sec    0    575 KBytes       
[  5]  20.00-25.00  sec  98.8 MBytes   166 Mbits/sec    0    839 KBytes       
[  5]  25.00-30.00  sec   100 MBytes   168 Mbits/sec   13   1.13 MBytes       
[  5]  30.00-35.00  sec   102 MBytes   172 Mbits/sec    1   1005 KBytes       
[  5]  35.00-40.00  sec  98.8 MBytes   166 Mbits/sec    0   1.06 MBytes       
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bitrate         Retr
[  5]   0.00-40.00  sec   931 MBytes   195 Mbits/sec  992             sender
[  5]   0.00-40.10  sec   929 MBytes   194 Mbits/sec                  receiver

iperf Done.
~~~


## 2. RAS на базе OpenVPN 

Устанавливаем необходимые пакеты 
~~~shell
apt update
apt install openvpn easy-rsa
~~~
Переходим в директорию /etc/openvpn и инициализируем PKI
~~~shell
echo 'rasvpn' | /usr/share/easy-rsa/easyrsa gen-req server nopass
echo 'yes' | /usr/share/easy-rsa/easyrsa sign-req server server 
/usr/share/easy-rsa/easyrsa gen-dh
openvpn --genkey secret ca.key
~~~

Создаем конфигурационный файл сервера
~~~shell
port 1207 
proto udp 
dev tun 
ca /etc/openvpn/pki/ca.crt 
cert /etc/openvpn/pki/issued/server.crt 
key /etc/openvpn/pki/private/server.key 
dh /etc/openvpn/pki/dh.pem 
server 10.10.10.0 255.255.255.0 
ifconfig-pool-persist ipp.txt 
client-to-client 
client-config-dir /etc/openvpn/client 
keepalive 10 120 
comp-lzo 
persist-key 
persist-tun 
status /var/log/openvpn-status.log 
log /var/log/openvpn.log 
verb 3
~~~
Запускаем сервис
~~~shell
systemctl start openvpn@server
systemctl enable openvpn@server
~~~

На хост-машине:

Необходимо создать файл client.conf со следующим содержимым: 
~~~shell
dev tun 
proto udp 
remote 192.168.56.10 1207 
client 
resolv-retry infinite 
remote-cert-tls server 
ca ./ca.crt 
cert ./client.crt 
key ./client.key 
route 192.168.56.0 255.255.255.0 
persist-key 
persist-tun 
comp-lzo 
verb 3 
~~~
При успешном подключении проверяем пинг по внутреннему IP адресу  сервера в туннеле:
~~~shell
root@client:/home/vagrant# ping 10.10.10.1
PING 10.10.10.1 (10.10.10.1) 56(84) bytes of data.
64 bytes from 10.10.10.1: icmp_seq=1 ttl=64 time=1.19 ms
64 bytes from 10.10.10.1: icmp_seq=2 ttl=64 time=5.94 ms
64 bytes from 10.10.10.1: icmp_seq=3 ttl=64 time=4.70 ms
^C
--- 10.10.10.1 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2004ms
rtt min/avg/max/mdev = 1.195/3.945/5.940/2.010 ms
~~~
~~~shell
root@client:/home/vagrant# ip r
default via 10.0.2.2 dev eth0 proto dhcp metric 100 
10.0.2.0/24 dev eth0 proto kernel scope link src 10.0.2.15 metric 100 
10.10.10.0/24 via 172.16.10.5 dev tun0 
172.16.10.0/24 via 172.16.10.5 dev tun0 
172.16.10.5 dev tun0 proto kernel scope link src 172.16.10.6 
192.168.10.0/24 dev eth1 proto kernel scope link src 192.168.10.20 metric 101 
~~~

