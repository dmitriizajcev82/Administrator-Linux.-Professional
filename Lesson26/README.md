# Цель домашнего задания
Научиться настраивать резервное копирование с помощью утилиты Borg

## Описание домашнего задания
 - Настроить стенд Vagrant с двумя виртуальными машинами: backup_server и client. (Студент самостоятельно настраивает Vagrant)
 - Настроить удаленный бэкап каталога /etc c сервера client при помощи borgbackup. Резервные копии должны соответствовать следующим критериям:
    - директория для резервных копий /var/backup. Это должна быть отдельная точка монтирования. В данном случае для демонстрации размер не принципиален, достаточно будет и 2GB; (Студент самостоятельно настраивает)
    - репозиторий для резервных копий должен быть зашифрован ключом или паролем - на усмотрение студента;
    - имя бэкапа должно содержать информацию о времени снятия бекапа;
    - глубина бекапа должна быть год, хранить можно по последней копии на конец месяца, кроме последних трех. Последние три месяца должны содержать копии на каждый день. Т.е. должна быть правильно настроена политика удаления старых бэкапов;
    - резервная копия снимается каждые 5 минут. Такой частый запуск в целях демонстрации;
    - написан скрипт для снятия резервных копий. Скрипт запускается из соответствующей Cron джобы, либо systemd timer-а - на усмотрение студента;
    - настроено логирование процесса бекапа. Для упрощения можно весь вывод перенаправлять в logger с соответствующим тегом. Если настроите не в syslog, то обязательна ротация логов.
  
Тестовый стенд:
~~~shell
mylab@UM560-XT-faed496e:~/Documents/vagrant_test$ vagrant ssh server
Welcome to Ubuntu 22.04.4 LTS (GNU/Linux 5.15.0-116-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/pro

 System information as of Sat Oct 12 05:05:46 PM UTC 2024

  System load:  0.22               Processes:             157
  Usage of /:   12.1% of 30.34GB   Users logged in:       0
  Memory usage: 11%                IPv4 address for eth0: 10.0.2.15
  Swap usage:   0%                 IPv4 address for eth1: 192.168.0.100


This system is built by the Bento project by Chef Software
More information can be found at https://github.com/chef/bento

Use of this system is acceptance of the OS vendor EULA and License Agreements.
~~~
~~~shell
mylab@UM560-XT-faed496e:~/Documents/vagrant_test$ vagrant ssh client
Welcome to Ubuntu 22.04.4 LTS (GNU/Linux 5.15.0-116-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/pro

 System information as of Sat Oct 12 05:05:18 PM UTC 2024

  System load:  0.68               Processes:             177
  Usage of /:   12.1% of 30.34GB   Users logged in:       0
  Memory usage: 12%                IPv4 address for eth0: 10.0.2.16
  Swap usage:   0%                 IPv4 address for eth1: 192.168.0.101


This system is built by the Bento project by Chef Software
More information can be found at https://github.com/chef/bento

Use of this system is acceptance of the OS vendor EULA and License Agreements.
~~~
Устанавливаем на client и backup сервере borgbackup
~~~shell
root@server:/home/vagrant# apt install borgbackup
root@client:/home/vagrant# apt install borgbackup
~~~
На сервере backup создаем пользователя и каталог /var/backup (в домашнем задании нужно будет создать диск ~2Gb и примонтировать его) и назначаем на него права пользователя borg	

~~~shell
root@server:/home/vagrant# lsblk 
NAME                      MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
loop0                       7:0    0   87M  1 loop /snap/lxd/27037
loop1                       7:1    0 63.9M  1 loop /snap/core20/2105
loop2                       7:2    0 40.4M  1 loop /snap/snapd/20671
loop3                       7:3    0   87M  1 loop /snap/lxd/29351
sda                         8:0    0   64G  0 disk 
├─sda1                      8:1    0    1M  0 part 
├─sda2                      8:2    0    2G  0 part /boot
└─sda3                      8:3    0   62G  0 part 
  └─ubuntu--vg-ubuntu--lv 253:0    0   31G  0 lvm  /
sdb                         8:16   0    2G  0 disk /var/backup
~~~
На сервер backup создаем каталог ~/.ssh/authorized_keys в каталоге /home/borg
~~~shell
root@server:/home/vagrant# chown borg:borg /var/backup/
root@server:/home/vagrant# su - borg
borg@server:~$ 
borg@server:~$ mkdir .ssh
borg@server:~$ touch .ssh/authorized_keys
borg@server:~$ chmod 700 .ssh
borg@server:~$ chmod 600 .ssh/authorized_keys
~~~
Проверка работы скрипта:
~~~shell
root@client:~# systemctl list-timers --all
NEXT                        LEFT          LAST                        PASSED               UNIT                         ACTIVATES                     
Sat 2024-10-12 20:35:11 UTC 1h 45min left Tue 2024-07-23 18:02:42 UTC 2 months 20 days ago fwupd-refresh.timer          fwupd-refresh.service
Sun 2024-10-13 00:00:00 UTC 5h 10min left n/a                         n/a                  dpkg-db-backup.timer         dpkg-db-backup.service
Sun 2024-10-13 00:00:00 UTC 5h 10min left Sat 2024-10-12 18:11:38 UTC 38min ago            logrotate.timer              logrotate.service
Sun 2024-10-13 02:48:38 UTC 7h left       Sat 2024-10-12 18:20:36 UTC 29min ago            motd-news.timer              motd-news.service
Sun 2024-10-13 03:10:01 UTC 8h left       Sat 2024-10-12 18:12:00 UTC 37min ago            e2scrub_all.timer            e2scrub_all.service
Sun 2024-10-13 05:13:44 UTC 10h left      Tue 2024-07-23 18:02:42 UTC 2 months 20 days ago man-db.timer                 man-db.service
Sun 2024-10-13 18:26:36 UTC 23h left      Sat 2024-10-12 18:26:36 UTC 23min ago            systemd-tmpfiles-clean.timer systemd-tmpfiles-clean.service
Mon 2024-10-14 01:05:35 UTC 1 day 6h left Sat 2024-10-12 18:21:54 UTC 27min ago            fstrim.timer                 fstrim.service
Sat 2024-10-12 22:14:00 UTC 5h 10min left Sat 2024-10-12 22:08:38 UTC 4min ago             borg-backup.timer            borg-backup.service
~~~

Проверка логирования скрипта:
~~~shell
root@client:~# journalctl -u borg-backup.service -n21
Sat 2024-10-12 22:09:00 client systemd[1]: borg-backup.service: Consumed 1.861s CPU time.
Sat 2024-10-12 22:14:00 client systemd[1]: Starting borg-backup.service - Borg Backup...
Sat 2024-10-12 22:14:00 client borg[7206]: ------------------------------------------------------------------------------
Sat 2024-10-12 22:14:00 client borg[7206]: Repository: ssh://borg@192.168.0.100/var/backup
Sat 2024-10-12 22:14:00 client borg[7206]: Archive name: etc-2024-10-12_22:14:30
Sat 2024-10-12 22:14:00 client borg[7206]: Archive fingerprint: dc9f95fb0fe5020dffcfc756d3e86e9584c522ac287900c8de25dd1b683c86a3
Sat 2024-10-12 22:14:00 client borg[7206]: Time (start): Sat, 2024-10-12 22:14:00
Sat 2024-10-12 22:14:00 client borg[7206]: Time (end):   Sat, 2024-10-12 22:14:00
Sat 2024-10-12 22:14:00 client borg[7206]: Duration: 0.10 seconds
Sat 2024-10-12 22:14:00 client borg[7206]: Number of files: 541
Sat 2024-10-12 22:14:00 client borg[7206]: Utilization of max. archive size: 0%
Sat 2024-10-12 22:14:00 client borg[7206]: ------------------------------------------------------------------------------
Sat 2024-10-12 22:14:00 client borg[7206]:                        Original size      Compressed size    Deduplicated size
Sat 2024-10-12 22:14:00 client borg[7206]: This archive:                1.75 MB            776.09 kB                646 B
Sat 2024-10-12 22:14:00 client borg[7206]: All archives:                5.26 MB              2.33 MB            829.69 kB
Sat 2024-10-12 22:14:00 client borg[7206]:                        Unique chunks         Total chunks
Sat 2024-10-12 22:14:00 client borg[7206]: Chunk index:                     517                 1587
Sat 2024-10-12 22:14:00 client borg[7206]: ------------------------------------------------------------------------------
Sat 2024-10-12 22:14:00 client systemd[1]: borg-backup.service: Deactivated successfully.
Sat 2024-10-12 22:14:00 client systemd[1]: Finished borg-backup.service - Borg Backup.
Sat 2024-10-12 22:14:00 client systemd[1]: borg-backup.service: Consumed 1.875s CPU time.
~~~
