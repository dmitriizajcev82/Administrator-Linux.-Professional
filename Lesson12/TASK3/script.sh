#!/bin/bash

#Устанавливаем NGINX:

apt install nginx -y

#Для запуска нескольких экземпляров сервиса модифицируем исходный service для использования различной конфигурации, а также PID-файлов. Для этого создадим новый Unit для работы с шаблонами (/etc/systemd/system/nginx@.service):

cat >> /etc/systemd/system/nginx@.service << EOF
# Stop dance for nginx
# =======================
#
# ExecStop sends SIGSTOP (graceful stop) to the nginx process.
# If, after 5s (--retry QUIT/5) nginx is still running, systemd takes control
# and sends SIGTERM (fast shutdown) to the main process.
# After another 5s (TimeoutStopSec=5), and if nginx is alive, systemd sends
# SIGKILL to all the remaining processes in the process group (KillMode=mixed).
#
# nginx signals reference doc:
# http://nginx.org/en/docs/control.html
#
[Unit]
Description=A high performance web server and a reverse proxy server
Documentation=man:nginx(8)
After=network.target nss-lookup.target

[Service]
Type=forking
PIDFile=/run/nginx-%I.pid
ExecStartPre=/usr/sbin/nginx -t -c /etc/nginx/nginx-%I.conf -q -g 'daemon on; master_process on;'
ExecStart=/usr/sbin/nginx -c /etc/nginx/nginx-%I.conf -g 'daemon on; master_process on;'
ExecReload=/usr/sbin/nginx -c /etc/nginx/nginx-%I.conf -g 'daemon on; master_process on;' -s reload
ExecStop=-/sbin/start-stop-daemon --quiet --stop --retry QUIT/5 --pidfile /run/nginx-%I.pid
TimeoutStopSec=5
KillMode=mixed

[Install]
WantedBy=multi-user.target
EOF

#Далее необходимо создать два файла конфигурации (/etc/nginx/nginx-first.conf, /etc/nginx/nginx-second.conf). Их можно сформировать из стандартного конфига /etc/nginx/nginx.conf, с модификацией путей до PID-файлов и разделением по портам:

cp /etc/nginx/nginx.conf /etc/nginx/nginx-first.conf
sed -i 's/\/run\/nginx.pid/\/run\/nginx-first.pid/g' /etc/nginx/nginx-first.conf

TEMPVAR=$(cat /etc/nginx/nginx-first.conf | grep -n "include /etc/nginx/sites-enabled" | grep -v \# | awk '{print $1}')
TEMPVAR="${TEMPVAR::-1}"
sed -i $TEMPVAR"s/^/#/" /etc/nginx/nginx-first.conf
sed -i $TEMPVAR'a\ ' /etc/nginx/nginx-first.conf
sed -i $TEMPVAR'a\        }' /etc/nginx/nginx-first.conf
sed -i $TEMPVAR'a\          listen 9001;' /etc/nginx/nginx-first.conf
sed -i $TEMPVAR'a\        server {' /etc/nginx/nginx-first.conf
sed -i $TEMPVAR'a\ ' /etc/nginx/nginx-first.conf

cp /etc/nginx/nginx.conf /etc/nginx/nginx-second.conf
sed -i 's/\/run\/nginx.pid/\/run\/nginx-second.pid/g' /etc/nginx/nginx-second.conf

TEMPVAR=$(cat /etc/nginx/nginx-second.conf | grep -n "include /etc/nginx/sites-enabled" | grep -v \# | awk '{print $1}')
TEMPVAR="${TEMPVAR::-1}"
sed -i $TEMPVAR"s/^/#/" /etc/nginx/nginx-second.conf
sed -i $TEMPVAR'a\ ' /etc/nginx/nginx-second.conf
sed -i $TEMPVAR'a\        }' /etc/nginx/nginx-second.conf
sed -i $TEMPVAR'a\          listen 9002;' /etc/nginx/nginx-second.conf
sed -i $TEMPVAR'a\        server {' /etc/nginx/nginx-second.conf
sed -i $TEMPVAR'a\ ' /etc/nginx/nginx-second.conf

#Запускаем сервисы:

systemctl start nginx@first
systemctl start nginx@second
