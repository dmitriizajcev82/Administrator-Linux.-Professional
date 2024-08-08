# Описание домашнего задания 
- Основная часть: 
    - vagrant up должен поднимать 2 настроенных виртуальных машины (сервер NFS и клиента) без дополнительных ручных действий;
    - на сервере NFS должна быть подготовлена и экспортирована директория; 
    - в экспортированной директории должна быть поддиректория с именем upload с правами на запись в неё; 
    - экспортированная директория должна автоматически монтироваться на клиенте при старте виртуальной машины (systemd, autofs или fstab — любым способом);
    - монтирование и работа NFS на клиенте должна быть организована с использованием NFSv3.


Проверяем работу стенда.

~~~shell
mylab@UM560-XT-faed496e:~/Documents/vagrant_test$ vagrant status
Current machine states:

nfss                      running (virtualbox)
nfsc                      running (virtualbox)
~~~

## Заходим на сервер:

~~~shell
vagrant@nfss:~$ sudo apt install nfs-kernel-server
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
The following additional packages will be installed:
  keyutils libnfsidmap1 nfs-common rpcbind
Suggested packages:
  watchdog
The following NEW packages will be installed:
  keyutils libnfsidmap1 nfs-common nfs-kernel-server rpcbind
0 upgraded, 5 newly installed, 0 to remove and 0 not upgraded.
Need to get 521 kB of archives.
After this operation, 1,973 kB of additional disk space will be used.
Do you want to continue? [Y/n] 
Get:1 http://archive.ubuntu.com/ubuntu jammy-updates/main amd64 libnfsidmap1 amd64 1:2.6.1-1ubuntu1.2 [42.9 kB]
Get:2 http://archive.ubuntu.com/ubuntu jammy/main amd64 rpcbind amd64 1.2.6-2build1 [46.6 kB]
Get:3 http://archive.ubuntu.com/ubuntu jammy/main amd64 keyutils amd64 1.6.1-2ubuntu3 [50.4 kB]
Get:4 http://archive.ubuntu.com/ubuntu jammy-updates/main amd64 nfs-common amd64 1:2.6.1-1ubuntu1.2 [241 kB]
Get:5 http://archive.ubuntu.com/ubuntu jammy-updates/main amd64 nfs-kernel-server amd64 1:2.6.1-1ubuntu1.2 [140 kB]
Fetched 521 kB in 1s (423 kB/s)        
Selecting previously unselected package libnfsidmap1:amd64.
(Reading database ... 64051 files and directories currently installed.)
Preparing to unpack .../libnfsidmap1_1%3a2.6.1-1ubuntu1.2_amd64.deb ...
Unpacking libnfsidmap1:amd64 (1:2.6.1-1ubuntu1.2) ...
Selecting previously unselected package rpcbind.
Preparing to unpack .../rpcbind_1.2.6-2build1_amd64.deb ...
Unpacking rpcbind (1.2.6-2build1) ...
Selecting previously unselected package keyutils.
Preparing to unpack .../keyutils_1.6.1-2ubuntu3_amd64.deb ...
Unpacking keyutils (1.6.1-2ubuntu3) ...
Selecting previously unselected package nfs-common.
Preparing to unpack .../nfs-common_1%3a2.6.1-1ubuntu1.2_amd64.deb ...
Unpacking nfs-common (1:2.6.1-1ubuntu1.2) ...
Selecting previously unselected package nfs-kernel-server.
Preparing to unpack .../nfs-kernel-server_1%3a2.6.1-1ubuntu1.2_amd64.deb ...
Unpacking nfs-kernel-server (1:2.6.1-1ubuntu1.2) ...
Setting up libnfsidmap1:amd64 (1:2.6.1-1ubuntu1.2) ...
Setting up rpcbind (1.2.6-2build1) ...
Created symlink /etc/systemd/system/multi-user.target.wants/rpcbind.service → /lib/systemd/system
/rpcbind.service.
Created symlink /etc/systemd/system/sockets.target.wants/rpcbind.socket → /lib/systemd/system/rpc
bind.socket.
Setting up keyutils (1.6.1-2ubuntu3) ...
Setting up nfs-common (1:2.6.1-1ubuntu1.2) ...

Creating config file /etc/idmapd.conf with new version

Creating config file /etc/nfs.conf with new version
Adding system user `statd' (UID 114) ...
Adding new user `statd' (UID 114) with group `nogroup' ...
Not creating home directory `/var/lib/nfs'.
Created symlink /etc/systemd/system/multi-user.target.wants/nfs-client.target → /lib/systemd/syst
em/nfs-client.target.
Created symlink /etc/systemd/system/remote-fs.target.wants/nfs-client.target → /lib/systemd/syste
m/nfs-client.target.
auth-rpcgss-module.service is a disabled or a static unit, not starting it.
nfs-idmapd.service is a disabled or a static unit, not starting it.
nfs-utils.service is a disabled or a static unit, not starting it.
proc-fs-nfsd.mount is a disabled or a static unit, not starting it.
rpc-gssd.service is a disabled or a static unit, not starting it.
rpc-statd-notify.service is a disabled or a static unit, not starting it.
rpc-statd.service is a disabled or a static unit, not starting it.
rpc-svcgssd.service is a disabled or a static unit, not starting it.
rpc_pipefs.target is a disabled or a static unit, not starting it.
var-lib-nfs-rpc_pipefs.mount is a disabled or a static unit, not starting it.
Setting up nfs-kernel-server (1:2.6.1-1ubuntu1.2) ...
Created symlink /etc/systemd/system/nfs-client.target.wants/nfs-blkmap.service → /lib/systemd/sys
tem/nfs-blkmap.service.
Created symlink /etc/systemd/system/multi-user.target.wants/nfs-server.service → /lib/systemd/sys
tem/nfs-server.service.
nfs-mountd.service is a disabled or a static unit, not starting it.
nfsdcld.service is a disabled or a static unit, not starting it.

Creating config file /etc/exports with new version

Creating config file /etc/default/nfs-kernel-server with new version
Processing triggers for man-db (2.10.2-1) ...
Processing triggers for libc-bin (2.35-0ubuntu3.8) ...
Scanning processes...                                                                            
Scanning linux images...                                                                         

Running kernel seems to be up-to-date.

No services need to be restarted.

No containers need to be restarted.

No user sessions are running outdated binaries.

No VM guests are running outdated hypervisor (qemu) binaries on this host.
~~~

Проверяем наличие слушающих портов

~~~shell
root@nfss:/home/vagrant# ss -tnplu
Netid    State     Recv-Q     Send-Q            Local Address:Port          Peer Address:Port    Process                                                                                          
udp      UNCONN    0          0                       0.0.0.0:42442              0.0.0.0:*        users:(("rpc.mountd",pid=2980,fd=12))                                                           
udp      UNCONN    0          0                       0.0.0.0:40451              0.0.0.0:*        users:(("rpc.mountd",pid=2980,fd=4))                                                            
udp      UNCONN    0          0                 127.0.0.53%lo:53                 0.0.0.0:*        users:(("systemd-resolve",pid=556,fd=13))                                                       
udp      UNCONN    0          0              10.0.2.15%enp0s3:68                 0.0.0.0:*        users:(("systemd-network",pid=1739,fd=18))                                                      
udp      UNCONN    0          0                     127.0.0.1:603                0.0.0.0:*        users:(("rpc.statd",pid=2971,fd=5))                                                             
udp      UNCONN    0          0                       0.0.0.0:111                0.0.0.0:*        users:(("rpcbind",pid=2418,fd=5),("systemd",pid=1,fd=59))                                       
udp      UNCONN    0          0                       0.0.0.0:49785              0.0.0.0:*        users:(("rpc.mountd",pid=2980,fd=8))                                                            
udp      UNCONN    0          0                       0.0.0.0:50317              0.0.0.0:*                                                                                                        
udp      UNCONN    0          0                       0.0.0.0:34200              0.0.0.0:*        users:(("rpc.statd",pid=2971,fd=8))                                                             
udp      UNCONN    0          0                          [::]:38988                 [::]:*        users:(("rpc.statd",pid=2971,fd=10))                                                            
udp      UNCONN    0          0                          [::]:111                   [::]:*        users:(("rpcbind",pid=2418,fd=7),("systemd",pid=1,fd=75))                                       
udp      UNCONN    0          0                          [::]:37589                 [::]:*                                                                                                        
udp      UNCONN    0          0                          [::]:33526                 [::]:*        users:(("rpc.mountd",pid=2980,fd=6))                                                            
udp      UNCONN    0          0                          [::]:37244                 [::]:*        users:(("rpc.mountd",pid=2980,fd=10))                                                           
udp      UNCONN    0          0                          [::]:48048                 [::]:*        users:(("rpc.mountd",pid=2980,fd=14))                                                           
tcp      LISTEN    0          128                     0.0.0.0:22                 0.0.0.0:*        users:(("sshd",pid=812,fd=3))                                                                   
tcp      LISTEN    0          4096                    0.0.0.0:49681              0.0.0.0:*        users:(("rpc.mountd",pid=2980,fd=13))                                                           
tcp      LISTEN    0          64                      0.0.0.0:2049               0.0.0.0:*                                                                                                        
tcp      LISTEN    0          64                      0.0.0.0:44143              0.0.0.0:*                                                                                                        
tcp      LISTEN    0          4096                    0.0.0.0:111                0.0.0.0:*        users:(("rpcbind",pid=2418,fd=4),("systemd",pid=1,fd=58))                                       
tcp      LISTEN    0          4096              127.0.0.53%lo:53                 0.0.0.0:*        users:(("systemd-resolve",pid=556,fd=14))                                                       
tcp      LISTEN    0          4096                    0.0.0.0:41395              0.0.0.0:*        users:(("rpc.mountd",pid=2980,fd=5))                                                            
tcp      LISTEN    0          4096                    0.0.0.0:37783              0.0.0.0:*        users:(("rpc.statd",pid=2971,fd=9))                                                             
tcp      LISTEN    0          4096                    0.0.0.0:48993              0.0.0.0:*        users:(("rpc.mountd",pid=2980,fd=9))                                                            
tcp      LISTEN    0          128                        [::]:22                    [::]:*        users:(("sshd",pid=812,fd=4))                                                                   
tcp      LISTEN    0          64                         [::]:2049                  [::]:*                                                                                                        
tcp      LISTEN    0          4096                       [::]:36467                 [::]:*        users:(("rpc.mountd",pid=2980,fd=11))                                                           
tcp      LISTEN    0          4096                       [::]:111                   [::]:*        users:(("rpcbind",pid=2418,fd=6),("systemd",pid=1,fd=74))                                       
tcp      LISTEN    0          4096                       [::]:33389                 [::]:*        users:(("rpc.mountd",pid=2980,fd=15))                                                           
tcp      LISTEN    0          4096                       [::]:56413                 [::]:*        users:(("rpc.statd",pid=2971,fd=11))                                                            
tcp      LISTEN    0          4096                       [::]:37821                 [::]:*        users:(("rpc.mountd",pid=2980,fd=7))                                                            
tcp      LISTEN    0          64                         [::]:35597                 [::]:*    
~~~

Создаём и настраиваем директорию, которая будет экспортирована в будущем 

~~~shell
root@nfss:/home/vagrant#  mkdir -p /srv/share/upload
root@nfss:/home/vagrant# chown -R nobody:nogroup /srv/share
root@nfss:/home/vagrant# chmod 0777 /srv/share/upload
~~~

Cоздаём в файле /etc/exports структуру, которая позволит экспортировать ранее созданную директорию:

~~~shell
root@nfss:/home/vagrant# cat << EOF > /etc/exports 
/srv/share 192.168.50.11/32(rw,sync,root_squash)
EOF
~~~

Экспортируем ранее созданную директорию:

~~~shell
root@nfss:/home/vagrant# exportfs -r
exportfs: /etc/exports [4]: Neither 'subtree_check' or 'no_subtree_check' specified for export "192.168.50.11/32:/srv/share".
  Assuming default behaviour ('no_subtree_check').
  NOTE: this default has changed since nfs-utils version 1.0.x
~~~

~~~shell
root@nfss:/home/vagrant# exportfs -s 
/srv/share  192.168.50.11/32(sync,wdelay,hide,no_subtree_check,sec=sys,rw,secure,root_squash,no_all_squash)
root@nfss:/home/vagrant# exportfs -s
/srv/share  192.168.50.11/32(sync,wdelay,hide,no_subtree_check,sec=sys,rw,secure,root_squash,no_all_squash)
~~~

## Настраиваем клиент NFS

~~~shell
mylab@UM560-XT-faed496e:~/Documents/vagrant_test$ vagrant ssh nfsc
Welcome to Ubuntu 22.04.4 LTS (GNU/Linux 5.15.0-117-generic x86_64)
~~~

Дальнейшие действия выполняются от имени пользователя имеющего повышенные привилегии, разрешающие описанные действия. 
Установим пакет с NFS-клиентом

~~~shell
root@nfsc:/home/vagrant#  apt install nfs-common
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
The following additional packages will be installed:
~~~

Добавляем в /etc/fstab строку 

~~~shell
root@nfsc:/home/vagrant# echo "192.168.50.10:/srv/share/ /mnt nfs vers=3,noauto,x-systemd.automount 0 0" >> /etc/fstab
~~~

~~~shell
root@nfsc:/home/vagrant# systemctl daemon-reload 
root@nfsc:/home/vagrant# systemctl restart remote-fs.target
~~~

~~~shell
root@nfsc:/home/vagrant# mount | grep mnt
nsfs on /run/snapd/ns/lxd.mnt type nsfs (rw)
systemd-1 on /mnt type autofs (rw,relatime,fd=56,pgrp=1,timeout=0,minproto=5,maxproto=5,direct,pipe_ino=27449)
~~~

## Проверка работоспособности

Заходим на сервер. 

~~~shell
mylab@UM560-XT-faed496e:~/Documents/vagrant_test$ vagrant ssh nfss
Welcome to Ubuntu 22.04.4 LTS (GNU/Linux 5.15.0-117-generic x86_64)
~~~

Заходим в каталог /srv/share/upload.
Создаём тестовый файл touch check_file.

~~~shell
root@nfss:/home/vagrant# cd /srv/share/upload
root@nfss:/srv/share/upload# touch check_file
root@nfss:/srv/share/upload# ll
total 8
drwxrwxrwx 2 nobody nogroup 4096 Aug  8 18:32 ./
drwxr-xr-x 3 nobody nogroup 4096 Aug  8 18:21 ../
-rw-r--r-- 1 root   root       0 Aug  8 18:32 check_file
~~~

Заходим на клиент.

~~~shell
mylab@UM560-XT-faed496e:~/Documents/vagrant_test$ vagrant ssh nfsc
Welcome to Ubuntu 22.04.4 LTS (GNU/Linux 5.15.0-117-generic x86_64)
~~~

Заходим в каталог /mnt/upload. 
Проверяем наличие ранее созданного файла.

~~~shell
vagrant@nfsc:/mnt/upload$ ll
total 8
drwxrwxrwx 2 nobody nogroup 4096 Aug  8 18:32 ./
drwxr-xr-x 3 nobody nogroup 4096 Aug  8 18:21 ../
-rw-r--r-- 1 root   root       0 Aug  8 18:32 check_file
~~~
- Проверяем сервер: 
    - заходим на сервер в отдельном окне терминала;
    - перезагружаем сервер;
    - заходим на сервер;
    - проверяем наличие файлов в каталоге /srv/share/upload/;
    - проверяем экспорты exportfs -s;

~~~shell
root@nfss:/home/vagrant# cd /srv/share/upload/
root@nfss:/srv/share/upload# ll
total 8
drwxrwxrwx 2 nobody nogroup 4096 Aug  8 18:32 ./
drwxr-xr-x 3 nobody nogroup 4096 Aug  8 18:21 ../
-rw-r--r-- 1 root   root       0 Aug  8 18:32 check_file
root@nfss:/srv/share/upload# exportfs -s
/srv/share  192.168.50.11/32(sync,wdelay,hide,no_subtree_check,sec=sys,rw,secure,root_squash,no_all_squash)
root@nfss:/srv/share/upload# showmount -a 192.168.50.10
All mount points on 192.168.50.10:
192.168.50.11:/srv/share
~~~
- Проверяем клиент: 
    - возвращаемся на клиент;
    - перезагружаем клиент;
    - заходим на клиент;
    - проверяем работу RPC showmount -a 192.168.50.10;
    - заходим в каталог /mnt/upload;
    -проверяем статус монтирования mount | grep mnt;
    - проверяем наличие ранее созданных файлов;
    - создаём тестовый файл touch final_check;
~~~shell
root@nfsc:/home/vagrant# showmount -a 192.168.50.10
All mount points on 192.168.50.10:
192.168.50.11:/srv/share
root@nfsc:/home/vagrant# cd /mnt/upload/
root@nfsc:/mnt/upload# ll
total 8
drwxrwxrwx 2 nobody nogroup 4096 Aug  8 18:32 ./
drwxr-xr-x 3 nobody nogroup 4096 Aug  8 18:21 ../
-rw-r--r-- 1 root   root       0 Aug  8 18:32 check_file
root@nfsc:/mnt/upload# mount | grep mnt
systemd-1 on /mnt type autofs (rw,relatime,fd=62,pgrp=1,timeout=0,minproto=5,maxproto=5,direct,pipe_ino=15690)
192.168.50.10:/srv/share/ on /mnt type nfs (rw,relatime,vers=3,rsize=131072,wsize=131072,namlen=255,hard,proto=tcp,timeo=600,retrans=2,sec=sys,mountaddr=192.168.50.10,mountvers=3,mountport=33693,mountproto=udp,local_lock=none,addr=192.168.50.10)
nsfs on /run/snapd/ns/lxd.mnt type nsfs (rw)
root@nfsc:/mnt/upload# touch final_check
~~~

проверяем, что файл успешно создан.

~~~shell
root@nfss:/srv/share/upload# ll
total 8
drwxrwxrwx 2 nobody nogroup 4096 Aug  8 18:38 ./
drwxr-xr-x 3 nobody nogroup 4096 Aug  8 18:21 ../
-rw-r--r-- 1 root   root       0 Aug  8 18:32 check_file
-rw-r--r-- 1 nobody nogroup    0 Aug  8 18:38 final_check
~~~

После того, как вы опишете конфигурацию для автоматизированного развёртывания, уничтожьте тестовый стенд командой 

~~~shell
mylab@UM560-XT-faed496e:~/Documents/Administrator-Linux.-Professional/Lesson9$ vagrant destroy -f
==> nfsc: Destroying VM and associated drives...
==> nfss: Destroying VM and associated drives...
~~~

## Проверка работоспособности

~~~shell
mylab@UM560-XT-faed496e:~/Documents/Administrator-Linux.-Professional/Lesson9$ vagrant ssh nfsc 
Welcome to Ubuntu 22.04.4 LTS (GNU/Linux 5.15.0-117-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/pro

 System information as of Thu Aug  8 19:28:30 UTC 2024

  System load:  0.31              Processes:               102
  Usage of /:   3.6% of 38.70GB   Users logged in:         0
  Memory usage: 23%               IPv4 address for enp0s3: 10.0.2.15
  Swap usage:   0%


Expanded Security Maintenance for Applications is not enabled.

0 updates can be applied immediately.

Enable ESM Apps to receive additional future security updates.
See https://ubuntu.com/esm or run: sudo pro status

  
vagrant@nfsc:~$ cd /mnt/upload/
vagrant@nfsc:/mnt/upload$ ll
total 8
drwxrwxrwx 2 nobody nogroup 4096 Aug  8 19:28 ./
drwxr-xr-x 3 nobody nogroup 4096 Aug  8 19:28 ../
-rw-r--r-- 1 root   root       0 Aug  8 19:28 check_file
~~~


