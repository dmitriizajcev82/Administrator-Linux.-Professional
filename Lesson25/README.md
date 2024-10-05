# Цель домашнего задания
Научиться создавать пользователей и добавлять им ограничения
## Описание домашнего задания
Запретить всем пользователям кроме группы admin логин в выходные (суббота и воскресенье), без учета праздников
## Введение
Почти все операционные системы Linux — многопользовательские. Администратор Linux должен уметь создать и настраивать пользователей.
В Linux есть 3 группы пользователей: 
 - Администраторы — привилегированные пользователи с полным доступом к системе. По умолчанию в ОС есть такой пользователь — root
 - Локальные пользователи — их учетные записи создает администратор, их права ограничены. Администраторы могут изменять права локальных пользователей
 - Системные пользователи — учетный записи, которые создаются системой для внутренних процессов и служб. Например пользователь — nginx

У каждого пользователя есть свой уникальный идентификатор — UID. 
Чтобы упростить процесс настройки прав для новых пользователей, их объединяют в группы. Каждая группа имеет свой набор прав и ограничений. Любой пользователь, создаваемый или добавляемый в такую группу, автоматически их наследует. Если при добавлении пользователя для него не указать группу, то у него будет своя, индивидуальная группа — с именем пользователя. Один пользователь может одновременно входить в несколько групп.
Информацию о каждом пользователе сервера можно посмотреть в файле /etc/passwd
Для более точных настроек пользователей можно использовать подключаемые модули аутентификации (PAM)
PAM (Pluggable Authentication Modules - подключаемые модули аутентификации) — набор библиотек, которые позволяют интегрировать различные методы аутентификации в виде единого API.
PAM решает следующие задачи: 
 - Аутентификация — процесс подтверждения пользователем своей подлинности. Например: ввод логина и пароля, ssh-ключ и т д. 
 - Авторизация — процесс наделения пользователя правами
 - Отчетность — запись информации о произошедших событиях
PAM может быть реализован несколькими способами: 
 - Модуль pam_time — настройка доступа для пользователя с учетом времени
 - Модуль pam_exec — настройка доступа для пользователей с помощью скриптов

Подключаемся к нашей созданной ВМ:
~~~shell
mylab@UM560-XT-faed496e:~/Documents/vagrant_test$ vagrant ssh
Welcome to Ubuntu 22.04.5 LTS (GNU/Linux 5.15.0-122-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/pro

 System information as of Sat Oct  5 19:22:28 UTC 2024

  System load:  0.23              Processes:               109
  Usage of /:   3.6% of 38.70GB   Users logged in:         0
  Memory usage: 22%               IPv4 address for enp0s3: 10.0.2.15
  Swap usage:   0%


Expanded Security Maintenance for Applications is not enabled.

0 updates can be applied immediately.

Enable ESM Apps to receive additional future security updates.
See https://ubuntu.com/esm or run: sudo pro status

New release '24.04.1 LTS' available.
Run 'do-release-upgrade' to upgrade to it.
~~~
Переходим в root-пользователя:
~~~shell
vagrant@pam:~$ sudo -i
~~~
Создаём пользователя otusadm и otus: 
~~~shell
root@pam:~# sudo useradd otusadm && sudo useradd otus
~~~
 Создаём пользователям пароли:
 ~~~shell
 echo "Otus2022!" | sudo passwd --stdin otusadm && echo "Otus2022!" | sudo passwd --stdin otus
 ~~~
 Для примера мы указываем одинаковые пароли для пользователя otus и otusadm
 Создаём группу admin:
 ~~~shell
 root@pam:~# sudo groupadd -f admin
 ~~~
 Добавляем пользователей vagrant,root и otusadm в группу admin:
~~~shell
root@pam:~# usermod otusadm -a -G admin && usermod root -a -G admin && usermod vagrant -a -G admin
~~~
После создания пользователей, нужно проверить, что они могут подключаться по SSH к нашей ВМ. Для этого пытаемся подключиться с хостовой машины: 
~~~shell
mylab@UM560-XT-faed496e:~/.ssh$ ssh otusadm@192.168.0.100
The authenticity of host '192.168.0.100 (192.168.0.100)' can't be established.
ED25519 key fingerprint is SHA256:fDtA7ko6gkoK/NW5nFg0g2UDQGMkYfKNBfWed+GNW+Y.
This key is not known by any other names
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added '192.168.0.100' (ED25519) to the list of known hosts.
otusadm@192.168.0.100's password: 
~~~
~~~shell
mylab@UM560-XT-faed496e:~/.ssh$ ssh otus@192.168.0.100
The authenticity of host '192.168.0.100 (192.168.0.100)' can't be established.
ED25519 key fingerprint is SHA256:fDtA7ko6gkoK/NW5nFg0g2UDQGMkYfKNBfWed+GNW+Y.
This key is not known by any other names
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added '192.168.0.100' (ED25519) to the list of known hosts.
otusadm@192.168.0.100's password: 
~~~
~~~shell
$ w
 20:55:52 up 28 min,  3 users,  load average: 0.00, 0.00, 0.00
USER     TTY      FROM             LOGIN@   IDLE   JCPU   PCPU WHAT
otusadm  pts/2    192.168.0.6      20:55    0.00s  0.00s  0.00s w
~~~
Далее настроим правило, по которому все пользователи кроме тех, что указаны в группе admin не смогут подключаться в выходные дни:
~~~shell
root@pam:/home/vagrant# cat /etc/group | grep admin
admin:x:118:otusadm,root,vagrant
~~~
Создадим файл-скрипт /usr/local/bin/login.sh
~~~shell
root@pam:/home/vagrant# nano /usr/local/bin/login.sh
~~~
Добавим права на исполнение файла:
~~~shell
root@pam:/home/vagrant# chmod +x /usr/local/bin/login.sh
~~~
Укажем в файле /etc/pam.d/sshd модуль pam_exec и наш скрипт:
~~~shell
root@pam:/home/vagrant# cat /etc/pam.d/sshd 
#%PAM-1.0
auth       substack     password-auth
auth       include      postlogin
auth required pam_exec.so debug /usr/local/bin/login.sh
account    required     dad
account    required     pam_nologin.so
account    include      password-auth
password   include      password-auth
# pam_selinux.so close should be the first session rule
session    required     pam_selinux.so close
session    required     pam_loginuid.so
# pam_selinux.so open should only be followed by sessions to be executed in the user context
session    required     pam_selinux.so open env_params
session    required     pam_namespace.so
session    optional     pam_keyinit.so force revoke
session    optional     pam_motd.so
session    include      password-auth
session    include      postlogin
~~~
Если Вы выполняете данную работу в выходные, то можно сразу попробовать подключиться к нашей ВМ. Если нет, тогда можно руками поменять время в нашей ОС.
~~~shell
root@pam:/home/vagrant# date 082512302022.00
Thu Aug 25 12:30:00 PM UTC 2022
~~~
~~~shell
mylab@UM560-XT-faed496e:~/.ssh$ ssh otusadm@192.168.0.100
otusadm@192.168.0.100's password:
/usr/local/bin/login.sh failed: exit code 1
Connection closed by 192.168.0.100 port 22
~~~