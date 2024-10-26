# Домашнее задание
    Сценарии iptables

## Цель:
    Написать сценарии iptables.

## Что нужно сделать?

 - реализовать knocking port. centralRouter может попасть на ssh inetrRouter через knock скрипт
пример в материалах.
 - добавить inetRouter2, который виден(маршрутизируется (host-only тип сети для виртуалки)) с хоста или форвардится порт через локалхост.
 - запустить nginx на centralServer.
 - пробросить 80й порт на inetRouter2 8080.
 - дефолт в инет оставить через inetRouter.


Port knocking — это сетевой защитный механизм, действие которого основано на следующем принципе: сетевой порт является по-умолчанию закрытым, но до тех пор, пока на него не поступит заранее определённая последовательность пакетов данных, которая «заставит» порт открыться. Например, вы можете сделать «невидимым» для внешнего мира порт SSH, и открытым только для тех, кто знает нужную последовательность.

[![port.jpg](https://s.iimg.su/s/26/ujby94N5Xp4FUDaR73vVECGajmBWGBDDjyAkVVPT.jpg)](https://iimg.su/i/UbDWD)

У себя создадим скрипт, которым будем проверять удаленный хост:
~~~shell
#!/bin/bash
HOST=$1
shift
for ARG in "$@"
do
        sudo nmap -Pn --max-retries 0 -p $ARG $HOST
done
~~~

листинг iptables inetRouter1
~~~shell
*nat
:PREROUTING ACCEPT [2:120]
:POSTROUTING ACCEPT [0:0]
:OUTPUT ACCEPT [16:1320]
-A POSTROUTING ! -d 192.168.0.0/16 -o eth0 -j MASQUERADE
COMMIT
# Completed on Sat Oct   19:59:49 2024

*filter
:INPUT DROP [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
:TRAFFIC - [0:0]
:SSH-INPUT - [0:0]
:SSH-INPUTTWO - [0:0]
# TRAFFIC chain for Port Knocking. The correct port sequence in this example is  8881 -> 7777-> 9991; any other sequence will drop the traffic

-A INPUT -j TRAFFIC
-A TRAFFIC -p icmp --icmp-type any -j ACCEPT
-A TRAFFIC -m state --state ESTABLISHED,RELATED -j ACCEPT
-A TRAFFIC -m state --state NEW -m tcp -p tcp --dport 22 -m recent --rcheck --seconds 30 --name SSH2 -j ACCEPT
-A TRAFFIC -m state --state NEW -m tcp -p tcp -m recent --name SSH2 --remove -j DROP
-A TRAFFIC -m state --state NEW -m tcp -p tcp --dport 9991 -m recent --rcheck --name SSH1 -j SSH-INPUTTWO
-A TRAFFIC -m state --state NEW -m tcp -p tcp -m recent --name SSH1 --remove -j DROP
-A TRAFFIC -m state --state NEW -m tcp -p tcp --dport 7777 -m recent --rcheck --name SSH0 -j SSH-INPUT
-A TRAFFIC -m state --state NEW -m tcp -p tcp -m recent --name SSH0 --remove -j DROP
-A TRAFFIC -m state --state NEW -m tcp -p tcp --dport 8881 -m recent --name SSH0 --set -j DROP
-A SSH-INPUT -m recent --name SSH1 --set -j DROP
-A SSH-INPUTTWO -m recent --name SSH2 --set -j DROP
-A TRAFFIC -j DROP
COMMIT
# END or further rules
~~~

листинг iptables inetRouter2
~~~shell
*filter
:INPUT ACCEPT [218:15967]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [153:14447]
-A FORWARD -d 192.168.0.2/32 -i eth0 -o eth1 -p tcp -m tcp --dport 80 -j ACCEPT
COMMIT


*nat
:PREROUTING ACCEPT [3:184]
:INPUT ACCEPT [3:184]
:OUTPUT ACCEPT [69:5342]
:POSTROUTING ACCEPT [69:5342]
-A PREROUTING -d 10.0.2.15/32 -p tcp -m tcp --dport 8080 -j DNAT --to-destination 192.168.0.2:80
-A OUTPUT -d 10.0.2.15/32 -p tcp -m tcp --dport 80 -j DNAT --to-destination 192.168.0.2
-A POSTROUTING -d 192.168.0.2/32 -p tcp -m tcp --dport 80 -j SNAT --to-source 192.168.255.3
COMMIT
~~~

Проверяем работу port knocking
~~~shell
[root@centralRouter ~]# /vagrant/port.sh 192.168.255.1 8881 7777 9991

Starting Nmap 6.40 ( http://nmap.org ) at 2023-05-01 18:03 UTC
Warning: 192.168.255.1 giving up on port because retransmission cap hit (0).
Nmap scan report for 192.168.255.1
Host is up (0.00074s latency).
PORT     STATE    SERVICE
8881/tcp filtered unknown
MAC Address: 08:00:27:93:B2:D9 (Cadmus Computer Systems)

Nmap done: 1 IP address (1 host up) scanned in 0.36 seconds

Starting Nmap 6.40 ( http://nmap.org ) at 2023-05-01 18:03 UTC
Warning: 192.168.255.1 giving up on port because retransmission cap hit (0).
Nmap scan report for 192.168.255.1
Host is up (0.00054s latency).
PORT     STATE    SERVICE
7777/tcp filtered cbt
MAC Address: 08:00:27:93:B2:D9 (Cadmus Computer Systems)

Nmap done: 1 IP address (1 host up) scanned in 0.34 seconds

Starting Nmap 6.40 ( http://nmap.org ) at 2023-05-01 18:03 UTC
Warning: 192.168.255.1 giving up on port because retransmission cap hit (0).
Nmap scan report for 192.168.255.1
Host is up (0.00051s latency).
PORT     STATE    SERVICE
9991/tcp filtered issa
MAC Address: 08:00:27:93:B2:D9 (Cadmus Computer Systems)

Nmap done: 1 IP address (1 host up) scanned in 0.35 seconds
~~~
Запустить nginx на centralServer
~~~shell
vagrant ssh centralServer
curl localhost:8080
HTTP/1.1 200 OK
Server: nginx/1.2.4
Date: Sat, 26 Oct 2024 20:16:47 GMT
Content-Type: text/html
Content-Length: 612
Connection: keep-alive
Accept-Ranges: bytes
~~~

Дефолт в инет оставить через inetRouter
~~~shell
[root@centralServer ~]# traceroute -I ya.ru
traceroute to ya.ru (87.250.250.242), 30 hops max, 60 byte packets
 1  gateway (192.168.0.1)  0.219 ms  0.149 ms  0.111 ms
 2  192.168.255.1 (192.168.255.1)  0.479 ms  0.526 ms  0.459 ms
 3  * * *
 4  192.168.88.1 (192.168.88.1)  2.537 ms  2.869 ms  2.832 ms
 5  172.16.253.52 (172.16.253.52)  2.875 ms  2.929 ms  2.880 ms
 6  172.16.253.244 (172.16.253.244)  4.290 ms  2.862 ms  3.140 ms
 7  atlant.asr.intelsc.net (188.191.160.129)  3.099 ms  2.561 ms  2.754 ms
 8  77.94.162.185 (77.94.162.185)  3.520 ms  3.488 ms  3.540 ms
 9  ae1-atlant-mmts9-msk.naukanet.ru (77.94.160.53)  4.392 ms  4.458 ms  4.410 ms
10  styri.yndx.net (195.208.208.116)  5.243 ms  5.170 ms  5.212 ms
~~~
