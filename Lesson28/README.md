# Цель домашнего задания
Научится менять базовые сетевые настройки в Linux-based системах.

## Описание домашнего задания

1. Скачать и развернуть Vagrant-стенд https://github.com/erlong15/otus-linux/tree/network
2. Построить следующую сетевую архитектуру:
Сеть office1
- 192.168.2.0/26      - dev
- 192.168.2.64/26     - test servers
- 192.168.2.128/26    - managers
- 192.168.2.192/26    - office hardware

Сеть office2
- 192.168.1.0/25      - dev
- 192.168.1.128/26    - test servers
- 192.168.1.192/26    - office hardware

Сеть central
- 192.168.0.0/28     - directors
- 192.168.0.32/28    - office hardware
- 192.168.0.64/26    - wifi




Итого должны получиться следующие сервера:
 - inetRouter
 - centralRouter
 - office1Router
 - office2Router
 - centralServer
 - office1Server
 - office2Server


[![net.jpg](https://s.iimg.su/s/14/uLJObVqGp8zxu2XnPtgGx8Xf02rO58wA5TIcPugn.jpg)](https://iimg.su/i/XxmIP)

 ## Задание состоит из 2-х частей: теоретической и практической.
В теоретической части требуется: 
 - Найти свободные подсети
 - Посчитать количество узлов в каждой подсети, включая свободные
 - Указать Broadcast-адрес для каждой подсети
 - Проверить, нет ли ошибок при разбиении

В практической части требуется: 
 - Соединить офисы в сеть согласно логической схеме и настроить роутинг
 - Интернет-трафик со всех серверов должен ходить через inetRouter
 - Все сервера должны видеть друг друга (должен проходить ping)
 - У всех новых серверов отключить дефолт на NAT (eth0), который vagrant поднимает для связи

Расчет всех сетей:

Directors:

[![192 168 0 0.jpg](https://s.iimg.su/s/14/w992gOUmGfJJXQ4ocnOX1gJZJg6whl3r4dT0gNtD.jpg)](https://iimg.su/i/d8ZQM)

Office hardware:

[![0 32.jpg](https://s.iimg.su/s/14/rqx60mzJGjeSOdIR51SOPzDSavpD2RuFmVDGRqIz.jpg)](https://iimg.su/i/Yr4UZ)

Wifi(mgt network):

[![0 64.jpg](https://s.iimg.su/s/14/uV6ngmQj8PlHBJYwYZrCQ2QL51IQgHi1V8gevDaz.jpg)](https://iimg.su/i/N0KhL)

Dev:

[![2 0.jpg](https://s.iimg.su/s/14/yiCfun9RGUVDvYQ9sgCMNuQxSDKoDRpZTvZaQpzx.jpg)](https://iimg.su/i/C6cqY)

Test:

[![2 64.jpg](https://s.iimg.su/s/14/JPpONWiIezdzDY0JC9x6yVQ90j9MI5MZYqVUAWxk.jpg)](https://iimg.su/i/7VP0C)

Managers:

[![2 128.jpg](https://s.iimg.su/s/14/JRg7Bx5BIRRmWb97Cp0mav5qDDzDucwH6ZEqlQU4.jpg)](https://iimg.su/i/HphH3)

Office hardware:

[![2 192.jpg](https://s.iimg.su/s/14/SEyvTbyZMjblnZ8n3rC6MfTXk6KMUwFGpHUroFCJ.jpg)](https://iimg.su/i/pPZhg)

Dev:

[![1 0.jpg](https://s.iimg.su/s/14/zcO8xHWKCjnhSokuqY2yqxXRrKFrtg1eUpeZ72T0.jpg)](https://iimg.su/i/2Q1TG)

Test:

[![1 128.jpg](https://s.iimg.su/s/14/chTJvt22nX3RAxzVzhi4niOwZ6nJPl7wPymbQvnJ.jpg)](https://iimg.su/i/DT7dl)

Office:

[![1 192.jpg](https://s.iimg.su/s/14/nijDbZBii1CkVJDIvwAgNSI2XvhOW9ExJQWMjQVm.jpg)](https://iimg.su/i/9APX6)

Inet — central:

[![255 0.jpg](https://s.iimg.su/s/14/twj6SyUurgQwmN8aSZrb2bMM9YHGHwRJQWKM96rK.jpg)](https://iimg.su/i/WwLwx)


После создания таблицы топологии, мы видим, что ошибок в задании нет, также мы сразу видим следующие свободные сети: 

 - 192.168.0.16/28 
 - 192.168.0.48/28
 - 192.168.0.128/25
 - 192.168.255.64/26
 - 192.168.255.32/27
 - 192.168.255.16/28
 - 192.168.255.8/29  
 - 192.168.255.4/30 

Изучив таблицу топологии сети и Vagrant-стенд из задания, мы можем построить полную схему сети:


[![topol.jpg](https://s.iimg.su/s/14/0KcMDnIHWYuuV80emSb5eC9PomTBsVGIxra0bfWn.jpg)](https://iimg.su/i/5tTYJ)

Запустим хосты:
~~~shell
mylab@UM560-XT-faed496e:~/Documents/vagrant_test$ vagrant up
~~~
[![host.jpg](https://s.iimg.su/s/14/g1pbDPcwQES2qMuKkr9UZksni9EIE3WT2lMHJ6TN.jpg)](https://iimg.su/i/Lkctt)


Подключиться по SSH к хосту:
~~~shell
mylab@UM560-XT-faed496e:~/Documents/vagrant_test$ vagrant ssh inetRouter
~~~

Проверить, что отключен другой файервол:
~~~shell
vagrant@inetRouter:~$ systemctl status ufw
● ufw.service - Uncomplicated firewall
     Loaded: loaded (/lib/systemd/system/ufw.service; enabled; vendor preset: enabled)
     Active: active (exited) since Mon 2024-10-14 19:46:42 UTC; 27min ago
       Docs: man:ufw(8)
   Main PID: 540 (code=exited, status=0/SUCCESS)
        CPU: 1ms

Warning: some journal files were not opened due to insufficient permissions.
~~~

Если служба будет запущена, то нужно её отключить и удалить из автозагрузки:
~~~shell
vagrant@inetRouter:~$ sudo systemctl stop ufw
vagrant@inetRouter:~$ sudo systemctl disable ufw
~~~

Посмотреть список всех маршрутов на других серверах:
 ~~~shell
 root@office1Server:/home/vagrant# ip r
default via 10.0.2.2 dev eth0 proto dhcp src 10.0.2.15 metric 100 
10.0.2.0/24 dev eth0 proto kernel scope link src 10.0.2.15 metric 100 
10.0.2.2 dev eth0 proto dhcp scope link src 10.0.2.15 metric 100 
10.0.2.3 dev eth0 proto dhcp scope link src 10.0.2.15 metric 100 
192.168.2.128/26 dev eth1 proto kernel scope link src 192.168.2.130 
192.168.50.0/24 dev eth2 proto kernel scope link src 192.168.50.21 
 ~~~
 ~~~shell
 vagrant@office2Router:~$ ip r
default via 10.0.2.2 dev eth0 proto dhcp src 10.0.2.15 metric 100 
10.0.2.0/24 dev eth0 proto kernel scope link src 10.0.2.15 metric 100 
10.0.2.2 dev eth0 proto dhcp scope link src 10.0.2.15 metric 100 
10.0.2.3 dev eth0 proto dhcp scope link src 10.0.2.15 metric 100 
192.168.1.0/25 dev eth2 proto kernel scope link src 192.168.1.1 
192.168.1.128/26 dev eth3 proto kernel scope link src 192.168.1.129 
192.168.1.192/26 dev eth4 proto kernel scope link src 192.168.1.193 
192.168.50.0/24 dev eth5 proto kernel scope link src 192.168.50.30 
192.168.255.4/30 dev eth1 proto kernel scope link src 192.168.255.6 
 ~~~
 ~~~shell
 root@office1Server:/home/vagrant# ping 8.8.8.8
PING 8.8.8.8 (8.8.8.8) 56(84) bytes of data.
64 bytes from 8.8.8.8: icmp_seq=1 ttl=63 time=0.285 ms
64 bytes from 8.8.8.8: icmp_seq=2 ttl=63 time=0.384 ms
64 bytes from 8.8.8.8: icmp_seq=3 ttl=63 time=0.413 ms
64 bytes from 8.8.8.8: icmp_seq=4 ttl=63 time=0.386 ms
64 bytes from 8.8.8.8: icmp_seq=5 ttl=63 time=0.422 ms
64 bytes from 8.8.8.8: icmp_seq=6 ttl=63 time=0.442 ms
64 bytes from 8.8.8.8: icmp_seq=7 ttl=63 time=0.462 ms
^C
--- 8.8.8.8 ping statistics ---
7 packets transmitted, 7 received, 0% packet loss, time 6126ms
rtt min/avg/max/mdev = 0.285/0.399/0.462/0.053 ms

 ~~~

 ~~~shell
 root@office1Server:/home/vagrant# traceroute 8.8.8.8
traceroute to 8.8.8.8 (8.8.8.8), 30 hops max, 60 byte packets
 1  _gateway (10.0.2.2)  0.127 ms  0.143 ms  0.121 ms
 2  192.168.0.1 (192.168.0.1)  1.405 ms  2.602 ms  2.607 ms
 3  spbr-bras31.sz.ip.rostelecom.ru ()  7.572 ms  7.625 ms  7.574 ms
 4  ge9-0-vl9-1g.erx1440-1-vluk.nwtelecom.ru ()  7.488 ms  ()  7.434 ms  7.533 ms
 5   ()  7.548 ms  7.521 ms  ()  7.411 ms
 6  ()  7.339 ms  8.852 ms  8.728 ms
 7   ()  8.764 ms 74.125.244.180 ()  3.657 ms  5.983 ms
 8   ()  20.707 ms  20.521 ms 142.251.61.219 ()  9.153 ms
 9   ()  9.098 ms  13.229 ms  (  13.299 ms
10  * *  ()  13.313 ms
11  * * *
12  * * *
13  * * *
14  * * *
15  * * *
16  * * *
17  * * *
18  * * *
19  dns.google (8.8.8.8)  33.535 ms  33.439 ms *
 ~~~