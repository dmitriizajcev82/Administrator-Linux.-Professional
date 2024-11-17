# Цель домашнего задания
Создать домашнюю сетевую лабораторию. Изучить основы DNS, научиться работать с технологией Split-DNS в Linux-based системах

## Описание домашнего задания
  1. взять стенд https://github.com/erlong15/vagrant-bind 
добавить еще один сервер client2
завести в зоне dns.lab имена:
web1 - смотрит на клиент1
web2  смотрит на клиент2
завести еще одну зону newdns.lab
завести в ней запись
www - смотрит на обоих клиентов

2. настроить split-dns
клиент1 - видит обе зоны, но в зоне dns.lab только web1
клиент2 видит только dns.lab

После всех основных настроек виртульных машин проверим работу стенда.

Посмотреть с помощью команды SS: ss -tulpn
~~~shell
root@ns01 ~]# ss -ulpn
State       Recv-Q Send-Q                         Local Address:Port                                        Peer Address:Port              
UNCONN      0      0                                          *:111                                                    *:*                   users:(("rpcbind",pid=338,fd=6))
UNCONN      0      0                                          *:930                                                    *:*                   users:(("rpcbind",pid=338,fd=7))
UNCONN      0      0                              192.168.50.10:53                                                     *:*                   users:(("named",pid=30971,fd=512))
UNCONN      0      0                                  127.0.0.1:323                                                    *:*                   users:(("chronyd",pid=341,fd=5))
UNCONN      0      0                                          *:68                                                     *:*                   users:(("dhclient",pid=2449,fd=6))
UNCONN      0      0                                       [::]:111                                                 [::]:*                   users:(("rpcbind",pid=338,fd=9))
UNCONN      0      0                                       [::]:930                                                 [::]:*                   users:(("rpcbind",pid=338,fd=10))
UNCONN      0      0                                      [::1]:53                                                  [::]:*                   users:(("named",pid=30971,fd=513))
UNCONN      0      0                                      [::1]:323                                                 [::]:*                   users:(("chronyd",pid=341,fd=6))
~~~

Выполним проверку с клиента:
~~~shell
[vagrant@client ~]$ dig @192.168.50.10 web1.dns.lab

; <<>> DiG 9.11.4-P2-RedHat-9.11.4-26.P2.el7_9.9 <<>> @192.168.50.10 web1.dns.lab
; (1 server found)
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 49207
;; flags: qr aa rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 2, ADDITIONAL: 3

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
;; QUESTION SECTION:
;web1.dns.lab.			IN	A

;; ANSWER SECTION:
web1.dns.lab.		3600	IN	A	192.168.50.15

;; AUTHORITY SECTION:
dns.lab.		3600	IN	NS	ns01.dns.lab.
dns.lab.		3600	IN	NS	ns02.dns.lab.

;; ADDITIONAL SECTION:
ns01.dns.lab.		3600	IN	A	192.168.50.10
ns02.dns.lab.		3600	IN	A	192.168.50.11

;; Query time: 0 msec
;; SERVER: 192.168.50.10#53(192.168.50.10)
;; WHEN: Sun Mar 27 00:37:28 UTC 2022
;; MSG SIZE  rcvd: 127
~~~
~~~shell
[vagrant@client ~]$ dig @192.168.50.11 web2.dns.lab

; <<>> DiG 9.11.4-P2-RedHat-9.11.4-26.P2.el7_9.9 <<>> @192.168.50.11 web2.dns.lab
; (1 server found)
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 36834
;; flags: qr aa rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 2, ADDITIONAL: 3

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
;; QUESTION SECTION:
;web2.dns.lab.			IN	A

;; ANSWER SECTION:
web2.dns.lab.		3600	IN	A	192.168.50.16

;; AUTHORITY SECTION:
dns.lab.		3600	IN	NS	ns01.dns.lab.
dns.lab.		3600	IN	NS	ns02.dns.lab.

;; ADDITIONAL SECTION:
ns01.dns.lab.		3600	IN	A	192.168.50.10
ns02.dns.lab.		3600	IN	A	192.168.50.11

;; Query time: 2 msec
;; SERVER: 192.168.50.11#53(192.168.50.11)
;; WHEN: Sun Mar 27 00:37:28 UTC 2022
;; MSG SIZE  rcvd: 127
~~~

После внесения данных изменений можно перезапустить (по очереди) службу named на серверах ns01 и ns02.

Далее, нужно будет проверить работу Split-DNS с хостов client и client2. Для проверки можно использовать утилиту ping:

client
~~~shell
[root@client ~]# ping www.newdns.lab
PING www.newdns.lab (192.168.50.15) 56(84) bytes of data.
64 bytes from client (192.168.50.15): icmp_seq=1 ttl=64 time=0.014 ms
64 bytes from client (192.168.50.15): icmp_seq=2 ttl=64 time=0.066 ms
^C
--- www.newdns.lab ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1002ms
rtt min/avg/max/mdev = 0.014/0.040/0.066/0.026 ms
[root@client ~]# ping web1.dns.lab
PING web1.dns.lab (192.168.50.15) 56(84) bytes of data.
64 bytes from client (192.168.50.15): icmp_seq=1 ttl=64 time=0.015 ms
64 bytes from client (192.168.50.15): icmp_seq=2 ttl=64 time=0.068 ms
^C
--- web1.dns.lab ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1005ms
rtt min/avg/max/mdev = 0.015/0.041/0.068/0.027 ms
[root@client ~]# ping web2.dns.lab
ping: web2.dns.lab: Name or service not known
~~~

client2
~~~shell
[root@client2 ~]# ping www.newdns.lab
ping: www.newdns.lab: Name or service not known
[root@client2 ~]# 
[root@client2 ~]# ping web1.dns.lab
PING web1.dns.lab (192.168.50.15) 56(84) bytes of data.
64 bytes from 192.168.50.15 (192.168.50.15): icmp_seq=1 ttl=64 time=0.809 ms
^C
--- web1.dns.lab ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 0.809/0.809/0.809/0.000 ms
[root@client2 ~]# ping web2.dns.lab
PING web2.dns.lab (192.168.50.16) 56(84) bytes of data.
64 bytes from client2 (192.168.50.16): icmp_seq=1 ttl=64 time=0.037 ms
64 bytes from client2 (192.168.50.16): icmp_seq=2 ttl=64 time=0.065 ms
^C
--- web2.dns.lab ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1038ms
rtt min/avg/max/mdev = 0.037/0.051/0.065/0.014 ms
~~~