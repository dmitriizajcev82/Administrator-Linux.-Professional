# Цель домашнего задания

Диагностировать проблемы и модифицировать политики SELinux для корректной работы приложений, если это требуется.

## Описание домашнего задания

1. Запустить nginx на нестандартном порту 3-мя разными способами:
 - переключатели setsebool;
 - добавление нестандартного порта в имеющийся тип;
 - формирование и установка модуля SELinux.

К сдаче:
 - README с описанием каждого решения (скриншоты и демонстрация приветствуются). 

1. Обеспечить работоспособность приложения при включенном selinux.
 - развернуть приложенный стенд https://github.com/mbfx/otus-linux-adm/tree/master/selinux_dns_problems; 
 - выяснить причину неработоспособности механизма обновления зоны (см. README);
 - предложить решение (или решения) для данной проблемы;
 - выбрать одно из решений для реализации, предварительно обосновав выбор;
 - реализовать выбранное решение и продемонстрировать его работоспособность

## Запуск nginx на нестандартном порту 3-мя разными способами 

Для начала проверим, что в ОС отключен файервол:
~~~shell
[root@selinux ~]# systemctl status firewalld
● firewalld.service - firewalld - dynamic firewall daemon
   Loaded: loaded (/usr/lib/systemd/system/firewalld.service; disabled; vendor preset: enabled)
   Active: inactive (dead)
     Docs: man:firewalld(1)

~~~

Также можно проверить, что конфигурация nginx настроена без ошибок:
~~~shell
[root@selinux ~]# nginx -t
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
~~~

Далее проверим режим работы SELinux:
~~~shell
[root@selinux ~]# getenforce
Enforcing
~~~

Должен отображаться режим Enforcing. Данный режим означает, что SELinux будет блокировать запрещенную активность.

Установим утилиты для работы с SELinux:
~~~shell
yum install policycoreutils-python
yum -q provides audit2why
~~~

Разрешим в SELinux работу nginx на порту TCP 4881 c помощью переключателей setsebool:
~~~shell
[root@selinux ~]# grep 1678027299.865:853 /var/log/audit/audit.log | audit2why
type=AVC msg=audit(1678027299.865:853): avc:  denied  { name_bind } for  pid=2940 comm="nginx" src=4881 scontext=system_u:system_r:httpd_t:s0 tcontext=system_u:object_r:unreserved_port_t:s0 tclass=tcp_socket permissive=0

        Was caused by:
        The boolean nis_enabled was set incorrectly. 
        Description:
        Allow nis to enabled

        Allow access by executing:
        # setsebool -P nis_enabled 1
~~~
Утилита audit2why покажет почему трафик блокируется. Исходя из вывода утилиты, мы видим, что нам нужно поменять параметр nis_enabled.
~~~shell
[root@selinux ~]# setsebool -P nis_enabled on
[root@selinux ~]# systemctl restart nginx
[root@selinux ~]# systemctl status nginx
● nginx.service - The nginx HTTP and reverse proxy server
   Loaded: loaded (/usr/lib/systemd/system/nginx.service; disabled; vendor preset: disabled)
   Active: active (running) since Mon 2024-09-30 17:33:36 UTC; 6s ago
  Process: 2955 ExecStart=/usr/sbin/nginx (code=exited, status=0/SUCCESS)
  Process: 2953 ExecStartPre=/usr/sbin/nginx -t (code=exited, status=0/SUCCESS)
  Process: 2952 ExecStartPre=/usr/bin/rm -f /run/nginx.pid (code=exited, status=0/SUCCESS)
 Main PID: 2957 (nginx)
   CGroup: /system.slice/nginx.service
           ├─2957 nginx: master process /usr/sbin/nginx
           └─2959 nginx: worker process

Sep 30 17:33:36 selinux systemd[1]: Starting The nginx HTTP and reverse proxy server...
Sep 30 17:33:36 selinux nginx[2953]: nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
Sep 30 17:33:36 selinux nginx[2953]: nginx: configuration file /etc/nginx/nginx.conf test is successful
Sep 30 17:33:36 selinux systemd[1]: Started The nginx HTTP and reverse proxy server.
~~~
Также можно проверить работу nginx из браузера. Заходим в любой браузер на хосте и переходим по адресу http://127.0.0.1:4881

[![Screenshot from 2024-09-30 20.35.49.jpg](https://s.iimg.su/s/30/E910SCZ7HMvgwZ5vGj8h1JRFAyb0K0HBKbw2VJTJ.jpg)](https://iimg.su/i/6anXt)

Проверить статус параметра можно с помощью команды:
~~~shell
[root@selinux ~]# getsebool -a | grep nis_enabled
nis_enabled --> on
~~~

Вернём запрет работы nginx на порту 4881 обратно. Для этого отключим nis_enabled:
~~~shell
[root@selinux ~]# setsebool -P nis_enabled off
[root@selinux ~]# systemctl restart nginx
Job for nginx.service failed because the control process exited with error code. See "systemctl status nginx.service" and "journalctl -xe" for details.
~~~

Теперь разрешим в SELinux работу nginx на порту TCP 4881 c помощью добавления нестандартного порта в имеющийся тип:
~~~shell
[root@selinux ~]# semanage port -l | grep http
http_cache_port_t              tcp      8080, 8118, 8123, 10001-10010
http_cache_port_t              udp      3130
http_port_t                    tcp      80, 81, 443, 488, 8008, 8009, 8443, 9000
pegasus_http_port_t            tcp      5988
pegasus_https_port_t           tcp      5989
~~~
Добавим порт в тип http_port_t:
~~~shell
[root@selinux ~]# semanage port -a -t http_port_t -p tcp 4881
[root@selinux ~]# semanage port -l | grep  http_port_t
http_port_t                    tcp      4881, 80, 81, 443, 488, 8008, 8009, 8443, 9000
pegasus_http_port_t            tcp      5988
~~~

Теперь перезапустим службу nginx и проверим её работу:
~~~shell
[root@selinux ~]#  systemctl restart nginx
[root@selinux ~]# systemctl status nginx
● nginx.service - The nginx HTTP and reverse proxy server
   Loaded: loaded (/usr/lib/systemd/system/nginx.service; disabled; vendor preset: disabled)
   Active: active (running) since Mon 2024-09-30 17:43:14 UTC; 7s ago
  Process: 3003 ExecStart=/usr/sbin/nginx (code=exited, status=0/SUCCESS)
  Process: 3001 ExecStartPre=/usr/sbin/nginx -t (code=exited, status=0/SUCCESS)
  Process: 3000 ExecStartPre=/usr/bin/rm -f /run/nginx.pid (code=exited, status=0/SUCCESS)
 Main PID: 3005 (nginx)
   CGroup: /system.slice/nginx.service
           ├─3005 nginx: master process /usr/sbin/nginx
           └─3006 nginx: worker process

Sep 30 17:43:14 selinux systemd[1]: Starting The nginx HTTP and reverse proxy server...
Sep 30 17:43:14 selinux nginx[3001]: nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
Sep 30 17:43:14 selinux nginx[3001]: nginx: configuration file /etc/nginx/nginx.conf test is successful
Sep 30 17:43:14 selinux systemd[1]: Started The nginx HTTP and reverse proxy server.
~~~
Также можно проверить работу nginx из браузера. Заходим в любой браузер на хосте и переходим по адресу http://127.0.0.1:4881

[![111.jpg](https://s.iimg.su/s/30/mDj5cFlUPQVG5MPWuql6x0oOkixfAVitW8hWrCwT.jpg)](https://iimg.su/i/QHOXh)

Удалить нестандартный порт из имеющегося типа можно с помощью команды:
~~~shell
[root@selinux ~]# semanage port -d -t http_port_t -p tcp 4881
[root@selinux ~]# semanage port -l | grep  http_port_t
http_port_t                    tcp      80, 81, 443, 488, 8008, 8009, 8443, 9000
pegasus_http_port_t            tcp      5988
[root@selinux ~]# systemctl restart nginx
Job for nginx.service failed because the control process exited with error code. See "systemctl status nginx.service" and "journalctl -xe" for details.
~~~

Разрешим в SELinux работу nginx на порту TCP 4881 c помощью формирования и установки модуля SELinux:

Попробуем снова запустить nginx:
~~~shell
[root@selinux ~]# systemctl start nginx
Job for nginx.service failed because the control process exited with error code. See "systemctl status nginx.service" and "journalctl -xe" for details.
~~~
Nginx не запуститься, так как SELinux продолжает его блокировать. Посмотрим логи SELinux, которые относятся к nginx: 
~~~shell
[root@selinux ~]# grep nginx /var/log/audit/audit.log
type=SOFTWARE_UPDATE msg=audit(1727716582.877:825): pid=2700 uid=0 auid=1000 ses=2 subj=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023 msg='sw="nginx-filesystem-1:1.20.1-10.el7.noarch" sw_type=rpm key_enforce=0 gpg_res=1 root_dir="/" comm="yum" exe="/usr/bin/python2.7" hostname=? addr=? terminal=? res=success'
type=SOFTWARE_UPDATE msg=audit(1727716582.997:826): pid=2700 uid=0 auid=1000 ses=2 subj=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023 msg='sw="nginx-1:1.20.1-10.el7.x86_64" sw_type=rpm key_enforce=0 gpg_res=1 root_dir="/" comm="yum" exe="/usr/bin/python2.7" hostname=? addr=? terminal=? res=success'
type=AVC msg=audit(1727716583.145:827): avc:  denied  { name_bind } for  pid=2773 comm="nginx" src=4881 scontext=system_u:system_r:httpd_t:s0 tcontext=system_u:object_r:unreserved_port_t:s0 tclass=tcp_socket permissive=0
type=SYSCALL msg=audit(1727716583.145:827): arch=c000003e syscall=49 success=no exit=-13 a0=6 a1=563bdeb8a8b8 a2=10 a3=7ffef9a51c20 items=0 ppid=1 pid=2773 auid=4294967295 uid=0 gid=0 euid=0 suid=0 fsuid=0 egid=0 sgid=0 fsgid=0 tty=(none) ses=4294967295 comm="nginx" exe="/usr/sbin/nginx" subj=system_u:system_r:httpd_t:s0 key=(null)
type=SERVICE_START msg=audit(1727716583.147:828): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=system_u:system_r:init_t:s0 msg='unit=nginx comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=failed'
type=SERVICE_START msg=audit(1727717616.288:940): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=system_u:system_r:init_t:s0 msg='unit=nginx comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
type=SERVICE_STOP msg=audit(1727718029.959:945): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=system_u:system_r:init_t:s0 msg='unit=nginx comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
type=AVC msg=audit(1727718029.972:946): avc:  denied  { name_bind } for  pid=2979 comm="nginx" src=4881 scontext=system_u:system_r:httpd_t:s0 tcontext=system_u:object_r:unreserved_port_t:s0 tclass=tcp_socket permissive=0
type=SYSCALL msg=audit(1727718029.972:946): arch=c000003e syscall=49 success=no exit=-13 a0=6 a1=55d3e322e8b8 a2=10 a3=7fffc0de5af0 items=0 ppid=1 pid=2979 auid=4294967295 uid=0 gid=0 euid=0 suid=0 fsuid=0 egid=0 sgid=0 fsgid=0 tty=(none) ses=4294967295 comm="nginx" exe="/usr/sbin/nginx" subj=system_u:system_r:httpd_t:s0 key=(null)
type=SERVICE_START msg=audit(1727718029.973:947): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=system_u:system_r:init_t:s0 msg='unit=nginx comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=failed'
type=SERVICE_START msg=audit(1727718194.567:951): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=system_u:system_r:init_t:s0 msg='unit=nginx comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
type=SERVICE_STOP msg=audit(1727718542.616:955): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=system_u:system_r:init_t:s0 msg='unit=nginx comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
type=AVC msg=audit(1727718542.629:956): avc:  denied  { name_bind } for  pid=3026 comm="nginx" src=4881 scontext=system_u:system_r:httpd_t:s0 tcontext=system_u:object_r:unreserved_port_t:s0 tclass=tcp_socket permissive=0
type=SYSCALL msg=audit(1727718542.629:956): arch=c000003e syscall=49 success=no exit=-13 a0=6 a1=558b1377e8b8 a2=10 a3=7fff0a850190 items=0 ppid=1 pid=3026 auid=4294967295 uid=0 gid=0 euid=0 suid=0 fsuid=0 egid=0 sgid=0 fsgid=0 tty=(none) ses=4294967295 comm="nginx" exe="/usr/sbin/nginx" subj=system_u:system_r:httpd_t:s0 key=(null)
type=SERVICE_START msg=audit(1727718542.630:957): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=system_u:system_r:init_t:s0 msg='unit=nginx comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=failed'
type=AVC msg=audit(1727718617.628:958): avc:  denied  { name_bind } for  pid=3038 comm="nginx" src=4881 scontext=system_u:system_r:httpd_t:s0 tcontext=system_u:object_r:unreserved_port_t:s0 tclass=tcp_socket permissive=0
type=SYSCALL msg=audit(1727718617.628:958): arch=c000003e syscall=49 success=no exit=-13 a0=6 a1=555ded7b78b8 a2=10 a3=7ffe88aa1270 items=0 ppid=1 pid=3038 auid=4294967295 uid=0 gid=0 euid=0 suid=0 fsuid=0 egid=0 sgid=0 fsgid=0 tty=(none) ses=4294967295 comm="nginx" exe="/usr/sbin/nginx" subj=system_u:system_r:httpd_t:s0 key=(null)
type=SERVICE_START msg=audit(1727718617.629:959): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=system_u:system_r:init_t:s0 msg='unit=nginx comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=failed'
type=AVC msg=audit(1727718629.776:960): avc:  denied  { name_bind } for  pid=3049 comm="nginx" src=4881 scontext=system_u:system_r:httpd_t:s0 tcontext=system_u:object_r:unreserved_port_t:s0 tclass=tcp_socket permissive=0
type=SYSCALL msg=audit(1727718629.776:960): arch=c000003e syscall=49 success=no exit=-13 a0=6 a1=5634eaba08b8 a2=10 a3=7ffc1ca37a30 items=0 ppid=1 pid=3049 auid=4294967295 uid=0 gid=0 euid=0 suid=0 fsuid=0 egid=0 sgid=0 fsgid=0 tty=(none) ses=4294967295 comm="nginx" exe="/usr/sbin/nginx" subj=system_u:system_r:httpd_t:s0 key=(null)
type=SERVICE_START msg=audit(1727718629.777:961): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=system_u:system_r:init_t:s0 msg='unit=nginx comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=failed'
type=AVC msg=audit(1727718689.114:962): avc:  denied  { name_bind } for  pid=3061 comm="nginx" src=4881 scontext=system_u:system_r:httpd_t:s0 tcontext=system_u:object_r:unreserved_port_t:s0 tclass=tcp_socket permissive=0
type=SYSCALL msg=audit(1727718689.114:962): arch=c000003e syscall=49 success=no exit=-13 a0=6 a1=5605398ad8b8 a2=10 a3=7ffd7d6225d0 items=0 ppid=1 pid=3061 auid=4294967295 uid=0 gid=0 euid=0 suid=0 fsuid=0 egid=0 sgid=0 fsgid=0 tty=(none) ses=4294967295 comm="nginx" exe="/usr/sbin/nginx" subj=system_u:system_r:httpd_t:s0 key=(null)
type=SERVICE_START msg=audit(1727718689.114:963): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=system_u:system_r:init_t:s0 msg='unit=nginx comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=failed'
~~~
Воспользуемся утилитой audit2allow для того, чтобы на основе логов SELinux сделать модуль, разрешающий работу nginx на нестандартном порту: 
~~~shell
[root@selinux ~]# grep nginx /var/log/audit/audit.log | audit2allow -M nginx
******************** IMPORTANT ***********************
To make this policy package active, execute:

semodule -i nginx.pp
~~~

Audit2allow сформировал модуль, и сообщил нам команду, с помощью которой можно применить данный модуль:
~~~shell
semodule -i nginx.pp
~~~
Попробуем снова запустить nginx:
~~~shell
[root@selinux ~]# systemctl start nginx
[root@selinux ~]# systemctl status nginx
● nginx.service - The nginx HTTP and reverse proxy server
   Loaded: loaded (/usr/lib/systemd/system/nginx.service; disabled; vendor preset: disabled)
   Active: active (running) since Mon 2024-09-30 17:55:20 UTC; 8s ago
  Process: 3088 ExecStart=/usr/sbin/nginx (code=exited, status=0/SUCCESS)
  Process: 3086 ExecStartPre=/usr/sbin/nginx -t (code=exited, status=0/SUCCESS)
  Process: 3085 ExecStartPre=/usr/bin/rm -f /run/nginx.pid (code=exited, status=0/SUCCESS)
 Main PID: 3090 (nginx)
   CGroup: /system.slice/nginx.service
           ├─3090 nginx: master process /usr/sbin/nginx
           └─3092 nginx: worker process

Sep 30 17:55:20 selinux systemd[1]: Starting The nginx HTTP and reverse proxy server...
Sep 30 17:55:20 selinux nginx[3086]: nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
Sep 30 17:55:20 selinux nginx[3086]: nginx: configuration file /etc/nginx/nginx.conf test is successful
Sep 30 17:55:20 selinux systemd[1]: Started The nginx HTTP and reverse proxy server.
~~~
После добавления модуля nginx запустился без ошибок. При использовании модуля изменения сохранятся после перезагрузки. 
Просмотр всех установленных модулей:
~~~shell
[root@selinux ~]# semodule -l
abrt	1.4.1
accountsd	1.1.0
acct	1.6.0
afs	1.9.0
aiccu	1.1.0
aide	1.7.1
...
~~~
Для удаления модуля воспользуемся командой:
~~~shell
[root@selinux ~]# semodule -r nginx
libsemanage.semanage_direct_remove_key: Removing last nginx module (no other nginx module exists at another priority).
~~~

