
# Цель домашнего задания
Создать домашнюю сетевую лабораторию. Научится настраивать протокол OSPF в Linux-based системах.

OSPF — протокол динамической маршрутизации, использующий концепцию разделения на области в целях масштабирования. 
Административная дистанция OSPF — 110
Основные свойства протокола OSPF:
 - Быстрая сходимость
 - Масштабируемость (подходит для маленьких и больших сетей)
 - Безопасность (поддежка аутентиикации)
 - Эффективность (испольование алгоритма поиска кратчайшего пути)

При настроенном OSPF маршрутизатор формирует таблицу топологии с использованием результатов вычислений, основанных на алгоритме кратчайшего пути (SPF) Дейкстры. Алгоритм поиска кратчайшего пути основывается на данных о совокупной стоимости доступа к точке назначения. Стоимость доступа определятся на основе скорости интерфейса. 
Чтобы повысить эффективность и масштабируемость OSPF, протокол поддерживает иерархическую маршрутизацию с помощью областей (area). 

Схема сети.
[![net.jpg](https://s.iimg.su/s/04/zyeY9k8N8gkniMH9TM3E9zpvjicRvxQWMW0BEyS6.jpg)](https://iimg.su/i/r90fy)

[![router.jpg](https://s.iimg.su/s/04/OIvOIyVe1fGXtixM6pauVWYUVtlprRxrMyV5gWxy.jpg)](https://iimg.su/i/3f1yG)

Для начала нам необходимо узнать имена интерфейсов и их адреса. Сделать это можно с помощью двух способов:
~~~shell
root@router1:~# ip a | grep "inet " 
    inet 127.0.0.1/8 scope host lo
    inet 10.0.2.15/24 brd 10.0.2.255 scope global dynamic enp0s3
    inet 10.0.10.1/30 brd 10.0.10.3 scope global enp0s8
    inet 10.0.12.1/30 brd 10.0.12.3 scope global enp0s9
    inet 192.168.10.1/24 brd 192.168.10.255 scope global enp0s10
    inet 192.168.50.10/24 brd 192.168.50.255 scope global enp0s16
~~~

Зайти в интерфейс FRR и посмотреть информацию об интерфейсах

~~~shell
root@router1:~# vtysh

Hello, this is FRRouting (version 8.1).
Copyright 1996-2005 Kunihiro Ishiguro, et al.

router1# show interface brief
Interface       Status  VRF             Addresses
---------       ------  ---             ---------
enp0s3          up      default         10.0.2.15/24
enp0s8          up      default         10.0.10.1/30
enp0s9          up      default         10.0.12.1/30
enp0s10         up      default         192.168.10.1/24
enp0s16         up      default         192.168.50.10/24
lo              up      default         
~~~

Перезапускаем FRR и добавляем его в автозагрузку
~~~shell
systemct restart frr 
systemctl enable frr
~~~
Проверям, что OSPF перезапустился без ошибок
~~~shell
root@router1:~# systemctl status frr
● frr.service - FRRouting
     Loaded: loaded (/lib/systemd/system/frr.service; enabled; vendor preset: enabled)
     Active: active (running) since Mon 2024-11-04 21:02:04 UTC; 2h 1min ago
       Docs: https://frrouting.readthedocs.io/en/latest/setup.html
    Process: 31988 ExecStart=/usr/lib/frr/frrinit.sh start (code=exited, status=0/SUCCESS)
   Main PID: 32000 (watchfrr)
     Status: "FRR Operational"
      Tasks: 9 (limit: 1136)
     Memory: 13.2M
     CGroup: /system.slice/frr.service
             ├─32000 /usr/lib/frr/watchfrr -d -F traditional zebra ospfd staticd
             ├─32016 /usr/lib/frr/zebra -d -F traditional -A 127.0.0.1 -s 90000000
             ├─32021 /usr/lib/frr/ospfd -d -F traditional -A 127.0.0.1
             └─32024 /usr/lib/frr/staticd -d -F traditional -A 127.0.0.1
~~~
Запустим трассировку до адреса 192.168.30.1
~~~shell
root@router1:~# traceroute 192.168.30.1
traceroute to 192.168.30.1 (192.168.30.1), 30 hops max, 60 byte packets
 1  192.168.30.1 (192.168.30.1)  0.997 ms  0.868 ms  0.813 ms
~~~

Также мы можем проверить из интерфейса vtysh какие маршруты мы видим на данный момент:
~~~shell
root@router1:~# vtysh

Hello, this is FRRouting (version 8.1).
Copyright 1996-2005 Kunihiro Ishiguro, et al.

router1# show ip route ospf
Codes: K - kernel route, C - connected, S - static, R - RIP,
       O - OSPF, I - IS-IS, B - BGP, E - EIGRP, N - NHRP,
       T - Table, v - VNC, V - VNC-Direct, A - Babel, F - PBR,
       f - OpenFabric,
       > - selected route, * - FIB route, q - queued, r - rejected, b - backup
       t - trapped, o - offload failure

O   10.0.10.0/30 [110/1000] is directly connected, enp0s8, weight 1, 02:50:21
O>* 10.0.11.0/30 [110/200] via 10.0.12.2, enp0s9, weight 1, 00:01:00
O   10.0.12.0/30 [110/100] is directly connected, enp0s9, weight 1, 00:01:00
O   192.168.10.0/24 [110/100] is directly connected, enp0s10, weight 1, 02:50:21
O>* 192.168.20.0/24 [110/300] via 10.0.10.2, enp0s9, weight 1, 00:01:00
O>* 192.168.30.0/24 [110/200] via 10.0.12.2, enp0s9, weight 1, 00:01:00
~~~
