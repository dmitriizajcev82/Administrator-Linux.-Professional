
# Написать скрипт для CRON, который раз в час будет формировать письмо и отправлять на заданную почту.

## Необходимая информация в письме:

 - Список IP адресов (с наибольшим кол-вом запросов) с указанием кол-ва запросов c момента последнего запуска скрипта;
 - Список запрашиваемых URL (с наибольшим кол-вом запросов) с указанием кол-ва запросов c момента последнего запуска скрипта;
 - Ошибки веб-сервера/приложения c момента последнего запуска;
 - Список всех кодов HTTP ответа с указанием их кол-ва с момента последнего запуска скрипта.
 - Скрипт должен предотвращать одновременный запуск нескольких копий, до его завершения.


Настройка отправки почтовых сообщений

[![aptinstallMAIL.jpg](https://s.iimg.su/s/25/MSqYBJqmKhwj8BAyLS1vD5KCK6Nbr0Sxskrjew90.jpg)](https://iimg.su/i/oDyhR)

Колличество строк в файле

[![670.jpg](https://s.iimg.su/s/25/B8rSK7jr7wuZmoZYoeI7rnwIHjQZnjFHMnCPGbZl.jpg)](https://iimg.su/i/lc4qy)

Настройка CRON

[![Screenshot from 2024-08-25 14.28.06.jpg](https://s.iimg.su/s/25/BLHxRQZl7ZcU7rQ64lTfHMRDFuswoT82pNQwHYvX.jpg)](https://iimg.su/i/IGxV4)

Результат работы скрипта

~~~shell
Return-Path: <root@ubuntu>
X-Original-To: root@localhost
Delivered-To: root@localhost
Received: by ubuntu.localdomain (Postfix, from userid 0)
	id 36C721256774; Sun, 25 Aug 2024 14:34:51 -0800 (PST)
Subject: NGINX Log Info
To: <root@localhost>
User-Agent: mail (GNU Mailutils 3.14)
Date: Sun, 25 Aug 2024 14:34:51 -0800
Message-Id: <20230213193451.36C72120533@ubuntu.localdomain>
From: root <root@ubuntu>
X-IMAPbase: 1676375448                    9
X-UID: 1
Status: O


128 195.208.184.200
100 89.208.230.2
28 176.57.208.169
26 195.208.184.200
26 176.57.208.169
22 176.57.208.169
21 83.222.11.43
20 89.191.229.231
20 176.57.208.169
20 176.57.208.169


Часто запрашиваемые адреса:
Количество запросов:116 URL:/wp-login.php
Количество запросов:74 URL:/
Количество запросов:57 URL:/xmlrpc.php
Количество запросов:19 URL:/robots.txt
Количество запросов:11 URL:/favicon.ico

Частые ошибки:
    498 200
     95 301
     51 404
     18 400
      3 500
      2 499
      1 405
      1 403
      1 304
~~~