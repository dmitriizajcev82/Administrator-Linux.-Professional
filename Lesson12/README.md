# Домашнее задание
- Написать service, который будет раз в 30 секунд мониторить лог на предмет наличия ключевого слова (файл лога и ключевое слово должны задаваться в /etc/default).

- Установить spawn-fcgi и создать unit-файл (spawn-fcgi.sevice) с помощью переделки init-скрипта (https://gist.github.com/cea2k/1318020).

- Доработать unit-файл Nginx (nginx.service) для запуска нескольких инстансов сервера с разными конфигурационными файлами одновременно.

Для начала создаём файл с конфигурацией для сервиса в директории /etc/default - из неё сервис будет брать необходимые переменные.

~~~shell
root@systemd:/home/vagrant# cat > /etc/default/watchlog
# Configuration file for my watchlog service
# Place it to /etc/default

# File and word in that file that we will be monit
WORD="ALERT"
LOG=/var/log/watchlog.log
~~~

Затем создаем /var/log/watchlog.log и пишем туда строки на своё усмотрение,
плюс ключевое слово ‘ALERT’

~~~shell
root@systemd:/home/vagrant# cat > /var/log/watchlog.log
12345
123
qwerty
ALERT 
~~~

Создадим скрипт:

~~~shell
root@systemd:/home/vagrant# cat > /opt/watchlog.sh
#!/bin/bash

WORD=$1
LOG=$2
DATE=`date`

if grep $WORD $LOG &> /dev/null
then
logger "$DATE: I found word, Master!"
else
exit 0
fi
~~~

Добавим права на запуск файла:

~~~shell
root@systemd:/home/vagrant# chmod +x /opt/watchlog.sh
~~~

Создадим юнит для сервиса:

~~~shell
root@systemd:/home/vagrant# cat > /etc/systemd/system/watchlog.service
[Unit]
Description=My watchlog service

[Service]
Type=oneshot
EnvironmentFile=/etc/default/watchlog
ExecStart=/opt/watchlog.sh $WORD $LOG
~~~

Создадим юнит для таймера:

~~~shell
root@systemd:/home/vagrant# cat > /etc/systemd/system/watchlog.timer
[Unit]
Description=Run watchlog script every 30 second

[Timer]
# Run every 30 second
OnUnitActiveSec=30
Unit=watchlog.service

[Install]
WantedBy=multi-user.target
~~~

Запуск сервиса

~~~shell
root@systemd:/# systemctl start watchlog.timer
root@systemd:/# systemctl start watchlog.service
root@systemd:/# systemctl enable watchlog.timer
~~~

И убедиться в результате:

~~~shell
root@systemd:/# tail -n 1000 /var/log/syslog  | grep word
Aug 10 19:13:32 nfss systemd[1]: Started Dispatch Password Requests to Console Directory Watch.
Aug 10 19:31:03 nfss root: Sat Aug 10 19:31:03 UTC 2024: I found word, Master!
Aug 10 19:31:56 nfss root: Sat Aug 10 19:31:56 UTC 2024: I found word, Master!
Aug 10 19:32:56 nfss root: Sat Aug 10 19:32:56 UTC 2024: I found word, Master!
Aug 10 19:33:56 nfss root: Sat Aug 10 19:33:56 UTC 2024: I found word, Master!
Aug 10 19:34:56 nfss root: Sat Aug 10 19:34:56 UTC 2024: I found word, Master!
Aug 10 19:35:56 nfss root: Sat Aug 10 19:35:56 UTC 2024: I found word, Master!
Aug 10 19:36:56 nfss root: Sat Aug 10 19:36:56 UTC 2024: I found word, Master!
Aug 10 19:37:56 nfss root: Sat Aug 10 19:37:56 UTC 2024: I found word, Master!
Aug 10 19:38:56 nfss root: Sat Aug 10 19:38:56 UTC 2024: I found word, Master!
Aug 10 19:39:56 nfss root: Sat Aug 10 19:39:56 UTC 2024: I found word, Master!
Aug 10 19:40:56 nfss root: Sat Aug 10 19:40:56 UTC 2024: I found word, Master!
Aug 10 19:41:56 nfss root: Sat Aug 10 19:41:56 UTC 2024: I found word, Master!
~~~

Устанавливаем spawn-fcgi и необходимые для него пакеты:

~~~shell
root@systemd:/# apt install spawn-fcgi php php-cgi php-cli \
  apache2 libapache2-mod-fcgid -y
~~~

необходимо создать файл с настройками для будущего сервиса в файле /etc/spawn-fcgi/fcgi.conf.

~~~shell
root@systemd:/etc# cat > /etc/systemd/system/spawn-fcgi.service
[Unit]
Description=Spawn-fcgi startup service by Otus
After=network.target

[Service]
Type=simple
PIDFile=/var/run/spawn-fcgi.pid
EnvironmentFile=/etc/spawn-fcgi/fcgi.conf
ExecStart=/usr/bin/spawn-fcgi -n $OPTIONS
KillMode=process

[Install]
WantedBy=multi-user.target
~~~

Убеждаемся, что все успешно работает:

~~~shell
root@systemd:/etc# systemctl start spawn-fcgi
root@systemd:/etc# systemctl status spawn-fcgi
● spawn-fcgi.service - Spawn-fcgi startup service by Otus
   Loaded: loaded (/etc/systemd/system/spawn-fcgi.service; disabled; vendor preset: enabled)
   Active: active (running) since Sat 2024-08-10 19:49:37 UTC; 7s ago
 Main PID: 21303 (php-cgi)
    Tasks: 33
   Memory: 14.8M
      CPU: 16ms
   CGroup: /system.slice/spawn-fcgi.service
           ├─21303 /usr/bin/php-cgi
           ├─21306 /usr/bin/php-cgi
           ├─21307 /usr/bin/php-cgi
           ├─21308 /usr/bin/php-cgi
           ├─21309 /usr/bin/php-cgi
           ├─21310 /usr/bin/php-cgi
           ├─21311 /usr/bin/php-cgi
           ├─21312 /usr/bin/php-cgi
           ├─21313 /usr/bin/php-cgi
           ├─21314 /usr/bin/php-cgi
           ├─21315 /usr/bin/php-cgi
           ├─21316 /usr/bin/php-cgi
           ├─21317 /usr/bin/php-cgi
           ├─21318 /usr/bin/php-cgi
           ├─21319 /usr/bin/php-cgi
           ├─21320 /usr/bin/php-cgi
           ├─21321 /usr/bin/php-cgi
           ├─21322 /usr/bin/php-cgi
           ├─21323 /usr/bin/php-cgi
           ├─21324 /usr/bin/php-cgi
           ├─21325 /usr/bin/php-cgi
           ├─21326 /usr/bin/php-cgi
           ├─21327 /usr/bin/php-cgi
           ├─21328 /usr/bin/php-cgi
           ├─21329 /usr/bin/php-cgi
           ├─21330 /usr/bin/php-cgi
           ├─21331 /usr/bin/php-cgi
           ├─21332 /usr/bin/php-cgi
           ├─21333 /usr/bin/php-cgi
           ├─21334 /usr/bin/php-cgi
           ├─21335 /usr/bin/php-cgi
           ├─21336 /usr/bin/php-cgi
           └─21337 /usr/bin/php-cgi

Aug 10 19:49:37 systemd systemd[1]: Started Spawn-fcgi startup service by Otus.
~~~

Установим Nginx из стандартного репозитория:

~~~shell
root@systemd:/etc# apt install nginx -y
~~~

Доработать unit-файл Nginx (nginx.service) для запуска нескольких инстансов сервера с разными конфигурационными файлами одновременно

Проверим работу:

~~~shell
root@systemd:/home/vagrant# systemctl status nginx@first
● nginx@first.service - A high performance web server and a reverse proxy server
   Loaded: loaded (/etc/systemd/system/nginx@.service; disabled; vendor preset: enabled)
   Active: active (running) since Sat 2024-08-10 20:12:08 UTC; 2min 11s ago
     Docs: man:nginx(8)
  Process: 12788 ExecStart=/usr/sbin/nginx -c /etc/nginx/nginx-%I.conf -g daemon on; master_proce
  Process: 12784 ExecStartPre=/usr/sbin/nginx -t -c /etc/nginx/nginx-%I.conf -q -g daemon on; mas
 Main PID: 12789 (nginx)
   CGroup: /system.slice/system-nginx.slice/nginx@first.service
           ├─12789 nginx: master process /usr/sbin/nginx -c /etc/nginx/nginx-first.conf -g daemon
           └─12790 nginx: worker process                                                         

Aug 10 20:12:08 systemd systemd[1]: Starting A high performance web server and a reverse proxy se
Aug 10 20:12:08 systemd systemd[1]: Started A high performance web server and a reverse proxy ser
Aug 10 20:13:00 systemd systemd[1]: Started A high performance web server and a reverse proxy ser
lines 1-14/14 (END)
root@systemd:/home/vagrant# systemctl status nginx@second
● nginx@second.service - A high performance web server and a reverse proxy server
   Loaded: loaded (/etc/systemd/system/nginx@.service; disabled; vendor preset: enabled)
   Active: active (running) since Sat 2024-08-10 20:12:08 UTC; 2min 21s ago
     Docs: man:nginx(8)
  Process: 12796 ExecStart=/usr/sbin/nginx -c /etc/nginx/nginx-%I.conf -g daemon on; master_proce
  Process: 12793 ExecStartPre=/usr/sbin/nginx -t -c /etc/nginx/nginx-%I.conf -q -g daemon on; mas
 Main PID: 12799 (nginx)
   CGroup: /system.slice/system-nginx.slice/nginx@second.service
           ├─12799 nginx: master process /usr/sbin/nginx -c /etc/nginx/nginx-second.conf -g daemo
           └─12800 nginx: worker process                                                         

Aug 10 20:12:08 systemd systemd[1]: Starting A high performance web server and a reverse proxy se
Aug 10 20:12:08 systemd systemd[1]: nginx@second.service: Failed to parse PID from file /run/ngin
Aug 10 20:12:08 systemd systemd[1]: Started A high performance web server and a reverse proxy ser
lines 1-14/14 (END)
~~~

посмотреть, какие порты слушаются:

~~~shell
root@systemd:/home/vagrant# ss -tnulp | grep nginx
tcp    LISTEN     0      128       *:9001                  *:*                   users:(("nginx",pid=12790,fd=6),("nginx",pid=12789,fd=6))
tcp    LISTEN     0      128       *:9002                  *:*                   users:(("nginx",pid=12800,fd=6),("nginx",pid=12799,fd=6))
tcp    LISTEN     0      128       *:80                    *:*                   users:(("nginx",pid=12718,fd=6),("nginx",pid=12716,fd=6))
tcp    LISTEN     0      128      :::80                   :::*                   users:(("nginx",pid=12718,fd=7),("nginx",pid=12716,fd=7))
~~~

Просмотреть список процессов

~~~shell
root@systemd:/home/vagrant# ps afx | grep nginx
12882 pts/0    S+     0:00                                      \_ grep --color=auto nginx
12716 ?        Ss     0:00 nginx: master process /usr/sbin/nginx -g daemon on; master_process on;
12718 ?        S      0:00  \_ nginx: worker process
12789 ?        Ss     0:00 nginx: master process /usr/sbin/nginx -c /etc/nginx/nginx-first.conf -g daemon on; master_process on;
12790 ?        S      0:00  \_ nginx: worker process
12799 ?        Ss     0:00 nginx: master process /usr/sbin/nginx -c /etc/nginx/nginx-second.conf -g daemon on; master_process on;
12800 ?        S      0:00  \_ nginx: worker process
~~~