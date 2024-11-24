# Цель домашнего задания
Научиться настраивать VLAN и LACP. 

## Описание домашнего задания
в Office1 в тестовой подсети появляется сервера с доп интерфейсами и адресами
в internal сети testLAN: 
- testClient1 - 10.10.10.254
- testClient2 - 10.10.10.254
- testServer1- 10.10.10.1 
- testServer2- 10.10.10.1

Равести вланами:
testClient1 <-> testServer1
testClient2 <-> testServer2

Между centralRouter и inetRouter "пробросить" 2 линка (общая inernal сеть) и объединить их в бонд, проверить работу c отключением интерфейсов

По итогу выполнения домашнего задания у нас должна получиться следующая топология сети:
[![hosts.jpg](https://s.iimg.su/s/24/eQ5m93xfolujOLt88DgI38btrWDOgjimSZmYFHgr.jpg)](https://iimg.su/i/bwhzE)

Перед настройкой VLAN и LACP  установим на хосты следующие утилиты:
 - vim
 - traceroute
 - tcpdump
 - net-tools

Проверим настройку интерфейса, если настройка произведена правильно, то с хоста testClient1 будет проходить ping до хоста testServer1:
~~~shell
[vagrant@testClient1 ~]$ ip a 
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 52:54:00:03:15:fa brd ff:ff:ff:ff:ff:ff
    inet 10.0.2.15/24 brd 10.0.2.255 scope global dynamic noprefixroute eth0
       valid_lft 80162sec preferred_lft 80162sec
    inet6 fe80::5054:ff:fe03:15fa/64 scope link 
       valid_lft forever preferred_lft forever
3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:cb:35:ae brd ff:ff:ff:ff:ff:ff
    inet6 fe80::e1b1:ec7e:6337:dd54/64 scope link noprefixroute 
       valid_lft forever preferred_lft forever
4: eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:91:64:3c brd ff:ff:ff:ff:ff:ff
    inet 192.168.56.21/24 brd 192.168.56.255 scope global noprefixroute eth2
       valid_lft forever preferred_lft forever
    inet6 fe80::a00:27ff:fe91:643c/64 scope link 
       valid_lft forever preferred_lft forever
5: eth1.1@eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    link/ether 08:00:27:cb:35:ae brd ff:ff:ff:ff:ff:ff
    inet 10.10.10.254/24 brd 10.10.10.255 scope global noprefixroute eth1.1
       valid_lft forever preferred_lft forever
    inet6 fe80::a00:27ff:fecb:35ae/64 scope link 
       valid_lft forever preferred_lft forever
~~~

~~~shell
[vagrant@testClient1 ~]$ ping 10.10.10.254
PING 10.10.10.254 (10.10.10.254) 56(84) bytes of data.
64 bytes from 10.10.10.254: icmp_seq=1 ttl=64 time=0.081 ms
64 bytes from 10.10.10.254: icmp_seq=2 ttl=64 time=0.083 ms
64 bytes from 10.10.10.254: icmp_seq=3 ttl=64 time=0.082 ms
64 bytes from 10.10.10.254: icmp_seq=4 ttl=64 time=0.080 ms
^C
--- 10.10.10.254 ping statistics ---
4 packets transmitted, 4 received, 0% packet loss, time 3056ms
rtt min/avg/max/mdev = 0.080/0.081/0.083/0.009 ms
~~~

~~~shell
[vagrant@testClient1 ~]$ ping yandex.ru
PING yandex.ru () 56(84) bytes of data.
64 bytes from yandex.ru (): icmp_seq=1 ttl=63 time=12.1 ms
64 bytes from yandex.ru (): icmp_seq=2 ttl=63 time=11.7 ms
64 bytes from yandex.ru (): icmp_seq=3 ttl=63 time=11.9 ms
^C
--- yandex.ru ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2005ms
rtt min/avg/max/mdev = 11.677/11.887/12.102/0.173 ms
~~~
~~~shell
[vagrant@inetRouter ~]$ ping 192.168.255.2
PING 192.168.255.2 (192.168.255.2) 56(84) bytes of data.
64 bytes from 192.168.255.2: icmp_seq=1 ttl=64 time=0.694 ms
64 bytes from 192.168.255.2: icmp_seq=2 ttl=64 time=0.573 ms
64 bytes from 192.168.255.2: icmp_seq=3 ttl=64 time=0.601 ms

--- 192.168.255.2 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2026ms
rtt min/avg/max/mdev = 0.573/0.622/0.694/0.059 ms
~~~
~~~shell
[root@centralRouter ~]# ping 192.168.255.1
PING 192.168.255.1 (192.168.255.1) 56(84) bytes of data.
64 bytes from 192.168.255.1: icmp_seq=1 ttl=64 time=0.917 ms
64 bytes from 192.168.255.1: icmp_seq=2 ttl=64 time=0.730 ms
^C
--- 192.168.255.1 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1060ms
rtt min/avg/max/mdev = 0.730/0.823/0.917/0.097 ms
~~~
