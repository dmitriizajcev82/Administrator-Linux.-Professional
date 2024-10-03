# Цель домашнего задания
Научится проектировать централизованный сбор логов. Рассмотреть особенности разных платформ для сбора логов

Заходим на web-сервер:
~~~shell
mylab@UM560-XT-faed496e:~/Documents/vagrant_test$ vagrant ssh web
Welcome to Ubuntu 22.04.4 LTS (GNU/Linux 5.15.0-116-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/pro

 System information as of Thu Oct  3 06:20:55 PM UTC 2024

  System load:  0.13               Processes:             144
  Usage of /:   12.1% of 30.34GB   Users logged in:       0
  Memory usage: 14%                IPv4 address for eth0: 10.0.2.15
  Swap usage:   0%                 IPv4 address for eth1: 192.168.0.110


This system is built by the Bento project by Chef Software
More information can be found at https://github.com/chef/bento

Use of this system is acceptance of the OS vendor EULA and License Agreements.
~~~

Для правильной работы c логами, нужно, чтобы на всех хостах было настроено одинаковое время. 
~~~shell
root@web:/home/vagrant# timedatectl 
               Local time: Thu 2024-10-03 18:23:20 UTC
           Universal time: Thu 2024-10-03 18:23:20 UTC
                 RTC time: Thu 2024-10-03 18:23:20
                Time zone: Etc/UTC (UTC, +0000)
System clock synchronized: no
              NTP service: inactive
          RTC in local TZ: no
~~~
~~~shell
root@log:/home/vagrant# timedatectl 
               Local time: Thu 2024-10-03 18:24:00 UTC
           Universal time: Thu 2024-10-03 18:24:00 UTC
                 RTC time: Thu 2024-10-03 18:24:00
                Time zone: Etc/UTC (UTC, +0000)
System clock synchronized: no
              NTP service: inactive
          RTC in local TZ: no
~~~
Установим nginx:
~~~shell
root@web:/home/vagrant# apt update && apt install -y nginx 
~~~
Проверим, что nginx работает корректно:
~~~shell
root@web:/home/vagrant# systemctl status nginx
● nginx.service - A high performance web server and a reverse proxy server
     Loaded: loaded (/lib/systemd/system/nginx.service; enabled; vendor preset: enabled)
     Active: active (running) since Thu 2024-10-03 18:24:40 UTC; 1min 8s ago
       Docs: man:nginx(8)
    Process: 2232 ExecStartPre=/usr/sbin/nginx -t -q -g daemon on; master_process on; (code=exited, status=0/SUCCESS)
    Process: 2233 ExecStart=/usr/sbin/nginx -g daemon on; master_process on; (code=exited, status=0/SUCCESS)
   Main PID: 2323 (nginx)
      Tasks: 2 (limit: 1585)
     Memory: 4.0M
        CPU: 18ms
     CGroup: /system.slice/nginx.service
             ├─2323 "nginx: master process /usr/sbin/nginx -g daemon on; master_process on;"
             └─2326 "nginx: worker process" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" >

Oct 03 18:24:40 web systemd[1]: Starting A high performance web server and a reverse proxy server...
Oct 03 18:24:40 web systemd[1]: Started A high performance web server and a reverse proxy server.
~~~
~~~shell
root@web:/home/vagrant# ss -tln | grep 80
LISTEN 0      511          0.0.0.0:80        0.0.0.0:*          
LISTEN 0      511             [::]:80           [::]:*  
~~~

Также работу nginx можно проверить на хосте. В браузере ввведем в адерсную строку
[![nginx.jpg](https://s.iimg.su/s/03/oUXnc0pkekAMzNwUYw85WR7HkM196pyhE2w9QVC3.jpg)](https://iimg.su/i/M57Tn)

Откроем еще одно окно терминала и подключаемся по ssh к ВМ log. rsyslog должен быть установлен по умолчанию в нашей ОС, проверим это:
~~~shell
root@log:/home/vagrant# apt list rsyslog
Listing... Done
rsyslog/jammy-updates,jammy-security,now 8.2112.0-2ubuntu2.2 amd64 [installed,automatic]
N: There is 1 additional version. Please use the '-a' switch to see it
~~~
Все настройки Rsyslog хранятся в файле /etc/rsyslog.conf 
Для того, чтобы наш сервер мог принимать логи, нам необходимо внести следующие изменения в файл: 
Открываем порт 514 (TCP и UDP):

~~~shell
# provides UDP syslog reception
module(load="imudp")
input(type="imudp" port="514")

# provides TCP syslog reception
module(load="imtcp")
input(type="imtcp" port="514")

# provides kernel logging support and enable non-kernel klog messages
module(load="imklog" permitnonkernelfacility="on")

###########################
#### GLOBAL DIRECTIVES ####
###########################

#
# Use traditional timestamp format.
# To enable high precision timestamps, comment out the following line.
#
$ActionFileDefaultTemplate RSYSLOG_TraditionalFileFormat

# Filter duplicated messages
$RepeatedMsgReduction on

#
# Set the default permissions for all log files.
#
$FileOwner syslog
$FileGroup adm
$FileCreateMode 0640
$DirCreateMode 0755
$Umask 0022
$PrivDropToUser syslog
$PrivDropToGroup syslog

#
# Where to place spool and state files
#
$WorkDirectory /var/spool/rsyslog

#
# Include all config files in /etc/rsyslog.d/
#
$IncludeConfig /etc/rsyslog.d/*.conf
#Add remote logs
$template RemoteLogs, "/var/log/rsyslog/%HOSTNAME%/%PROGRAMNAME%.log"
*.* ?RemoteLogs
& ~
~~~
Далее сохраняем файл и перезапускаем службу rsyslog:
~~~shell
root@log:/home/vagrant# systemctl restart rsyslog 
~~~
У нас будут видны открытые порты TCP,UDP 514:
[![514.jpg](https://s.iimg.su/s/03/GpRqI158xdNOJ5UtiNG6UrkvAPwwVFqS5imR6kL0.jpg)](https://iimg.su/i/yzcBg)
Проверим версию nginx на сервере:
~~~shell
root@web:/home/vagrant# nginx -v
nginx version: nginx/1.18.0 (Ubuntu)
~~~
Находим в файле /etc/nginx/nginx.conf раздел с логами и приводим их к следующему виду:
~~~shell
error_log /var/log/nginx/error.log;
error_log syslog:server=192.168.0.115:514,tag=nginx_error;
access_log syslog:server=192.168.0.115:514,tag=nginx_access,severity=info combined;
~~~
Для Access-логов указываем удаленный сервер и уровень логов, которые нужно отправлять. Для error_log добавляем удаленный сервер. Если требуется чтобы логи хранились локально и отправлялись на удаленный сервер, требуется указать 2 строки. 	
Tag нужен для того, чтобы логи записывались в разные файлы.
По умолчанию, error-логи отправляют логи, которые имеют severity: error, crit, alert и emerg. Если требуется хранить или пересылать логи с другим severity, то это также можно указать в настройках nginx. 
~~~shell
root@web:/home/vagrant# nginx -t
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
~~~
Далее перезапускаем nginx:
~~~shell
root@web:/home/vagrant# systemctl restart nginx
~~~
Поскольку наше приложение работает без ошибок, файл nginx_error.log не будет создан. Чтобы сгенерировать ошибку, можно переместить файл веб-страницы, который открывает nginx - 
~~~shell
root@web:/home/vagrant# mv /var/www/html/index.nginx-debian.html /var/www/
~~~
Проверим работу сервера:
~~~shell
root@log:/home/vagrant# curl 192.168.0.110
<html>
<head><title>403 Forbidden</title></head>
<body>
<center><h1>403 Forbidden</h1></center>
<hr><center>nginx/1.18.0 (Ubuntu)</center>
</body>
</html>
~~~
Видим, что логи отправляются корректно. 
~~~shell
root@log:/home/vagrant# cat /var/log/rsyslog/web/nginx_access.log 
Oct  3 19:52:17 web nginx_access: 192.168.0.6 - - [03/Oct/2024:19:52:17 +0000] "GET / HTTP/1.1" 403 196 "-" "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 YaBrowser/24.6.0.0 Safari/537.36"
root@log:/home/vagrant# cat /var/log/rsyslog/web/nginx_error.log 
Oct  3 19:52:17 web nginx_error: 2024/10/03 19:52:17 [error] 3440#3440: *1 directory index of "/var/www/html/" is forbidden, client: 192.168.0.6, server: _, request: "GET / HTTP/1.1", host: "192.168.0.110"
~~~
