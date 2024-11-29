# Цель домашнего задания
Научиться настраивать LDAP-сервер и подключать к нему LDAP-клиентов

~~~shell
mylab@UM560-XT-faed496e:~/Documents/vagrant_test$ vagrant up
Bringing machine 'ipa.otus.lan' up with 'virtualbox' provider...
Bringing machine 'client1.otus.lan' up with 'virtualbox' provider...
Bringing machine 'client2.otus.lan' up with 'virtualbox' provider...
~~~

Запустим chrony и добавим его в автозагрузку:
~~~shell
[root@ipa vagrant]# systemctl status chronyd 
● chronyd.service - NTP client/server
     Loaded: loaded (/usr/lib/systemd/system/chronyd.service; enabled; preset: enabled)
     Active: active (running) since Fri 2024-11-29 22:07:47 MSK; 39s ago
       Docs: man:chronyd(8)
             man:chrony.conf(5)
   Main PID: 4036 (chronyd)
      Tasks: 1 (limit: 11999)
     Memory: 1004.0K
        CPU: 38ms
     CGroup: /system.slice/chronyd.service
             └─4036 /usr/sbin/chronyd -F 2
~~~
~~~shell
[root@ipa vagrant]# systemctl stop firewalld
[root@ipa vagrant]# systemctl disable firewalld
[root@ipa vagrant]# setenforce 0
~~~
Поменяем в файле /etc/selinux/config, параметр Selinux на disabled
vi /etc/selinux/config
~~~shell
# This file controls the state of SELinux on the system.
# SELINUX= can take one of these three values:
#     enforcing - SELinux security policy is enforced.
#     permissive - SELinux prints warnings instead of enforcing.
#     disabled - No SELinux policy is loaded.
SELINUX=disabled
# SELINUXTYPE= can take one of these three values:
#     targeted - Targeted processes are protected,
#     minimum - Modification of targeted policy. Only selected processes are protected. 
#     mls - Multi Level Security protection.
SELINUXTYPE=targeted
~~~

Для дальнейшей настройки FreeIPA нам потребуется, чтобы DNS-сервер хранил запись о нашем LDAP-сервере. В рамках данной лабораторной работы мы не будем настраивать отдельный DNS-сервер и просто добавим запись в файл /etc/hosts
vi /etc/hosts
~~~shell
127.0.0.1   localhost localhost.localdomain 
127.0.1.1 ipa.otus.lan ipa
192.168.57.10 ipa.otus.lan ipa
~~~

Установим FreeIPA-сервер:
~~~shell
[root@ipa vagrant]# yum install -y ipa-server
Last metadata expiration check: 0:03:35 ago on Fri Nov 29 22:07:45 2024.
Dependencies resolved.
======================================================================================================================================================================
 Package                                               Architecture             Version                                             Repository                   Size
======================================================================================================================================================================
Installing:
 ipa-server                                            x86_64                   4.12.2-1.el9                                        appstream                   400 k
~~~
Запустим скрипт установки: ipa-server-install
~~~shell
[root@ipa vagrant]# ipa-server-install

The log file for this installation can be found in /var/log/ipaserver-install.log
==============================================================================
This program will set up the IPA Server.
Version 4.12.2

This includes:
  * Configure a stand-alone CA (dogtag) for certificate management
  * Configure the NTP client (chronyd)
  * Create and configure an instance of Directory Server
  * Create and configure a Kerberos Key Distribution Center (KDC)
  * Configure Apache (httpd)
  * Configure SID generation
  * Configure the KDC to enable PKINIT

To accept the default shown in brackets, press the Enter key.

Do you want to configure integrated DNS (BIND)? [no]: no

Enter the fully qualified domain name of the computer
on which you're setting up server software. Using the form
<hostname>.<domainname>
Example: master.example.com


Server host name [ipa.otus.lan]: 

The domain name has been determined based on the host name.

Please confirm the domain name [otus.lan]: 

The kerberos protocol requires a Realm name to be defined.
This is typically the domain name converted to uppercase.

Please provide a realm name [OTUS.LAN]: 
Certain directory server operations require an administrative user.
This user is referred to as the Directory Manager and has full access
to the Directory for system management tasks and will be added to the
instance of directory server created for IPA.
The password must be at least 8 characters long.

Directory Manager password: 
Password (confirm): 

The IPA server requires an administrative user, named 'admin'.
This user is a regular system account used for IPA server administration.

IPA admin password: 
Password (confirm): 

Invalid IP address 127.0.1.1 for ipa.otus.lan: cannot use loopback IP address 127.0.1.1
Trust is configured but no NetBIOS domain name found, setting it now.
Enter the NetBIOS name for the IPA domain.
Only up to 15 uppercase ASCII letters, digits and dashes are allowed.
Example: EXAMPLE.


NetBIOS domain name [OTUS]: 

Do you want to configure chrony with NTP server or pool address? [no]: no

The IPA Master Server will be configured with:
Hostname:       ipa.otus.lan
IP address(es): 192.168.57.10
Domain name:    otus.lan
Realm name:     OTUS.LAN

The CA will be configured with:
Subject DN:   CN=Certificate Authority,O=OTUS.LAN
Subject base: O=OTUS.LAN
Chaining:     self-signed

Continue to configure the system with these values? [no]: yes

The following operations may take some minutes to complete.
Please wait until the prompt is returned.
~~~
После успешной установки FreeIPA, проверим, что сервер Kerberos может выдать нам билет: 

~~~shell
[root@ipa vagrant]# klist
Ticket cache: KCM:0
Default principal: admin@OTUS.LAN

Valid starting     Expires            Service principal
11/29/24 22:21:17  11/30/24 22:04:49  krbtgt/OTUS.LAN@OTUS.LAN
~~~

После добавления DNS-записи откроем c нашей хост-машины веб-страницу
[![identety.jpg](https://s.iimg.su/s/29/4J7LHIXkIhbtEyISNWyJEf0akifzHsBqwbLVX0Wa.jpg)](https://iimg.su/i/ccYlx)

Откроется окно управления FreeIPA-сервером. В имени пользователя укажем admin, в пароле укажем наш IPA admin password и нажмём войти. 

[![in.jpg](https://s.iimg.su/s/29/lADLMmrhZmqDpQD4DSUNTotZ33iC59ydYec4E4rD.jpg)](https://iimg.su/i/NbMgH)

[![Screenshot from 2024-11-29 22.35.45.jpg](https://s.iimg.su/s/29/T01GevBAtjmC7GTZnWTSuyqrkB2Nv8BXxcfMumML.jpg)](https://iimg.su/i/SvoaI)