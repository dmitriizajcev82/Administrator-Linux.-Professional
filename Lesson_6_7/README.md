# Домашнее задание

- На имеющемся образе centos/7 - v. 1804.2
- Уменьшить том под / до 8G.
- Выделить том под /home.
- Выделить том под /var - сделать в mirror.
- /home - сделать том для снапшотов.
- Прописать монтирование в fstab. Попробовать с разными опциями и разными файловыми системами (на выбор).
- Работа со снапшотами:
  - сгенерить файлы в /home/;
  - снять снапшот;
  - удалить часть файлов;
  - восстановится со снапшота.


уменьшить том под / до 8G

~~~shell
[root@localhost ~]# df -h
Filesystem                       Size  Used Avail Use% Mounted on
/dev/mapper/VolGroup00-LogVol00   38G  838M   37G   3% /
devtmpfs                         109M     0  109M   0% /dev
tmpfs                            118M     0  118M   0% /dev/shm
tmpfs                            118M  4.5M  114M   4% /run
tmpfs                            118M     0  118M   0% /sys/fs/cgroup
/dev/sda2                       1014M   63M  952M   7% /boot
tmpfs                             24M     0   24M   0% /run/user/1000
~~~

~~~shell
[root@localhost ~]# lsblk 
NAME                    MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda                       8:0    0   40G  0 disk 
├─sda1                    8:1    0    1M  0 part 
├─sda2                    8:2    0    1G  0 part /boot
└─sda3                    8:3    0   39G  0 part 
  ├─VolGroup00-LogVol00 253:0    0 37.5G  0 lvm  /
  └─VolGroup00-LogVol01 253:1    0  1.5G  0 lvm  [SWAP]
sdb                       8:16   0   10G  0 disk 
sdc                       8:32   0    2G  0 disk 
sdd                       8:48   0    1G  0 disk 
sde                       8:64   0    1G  0 disk 
~~~

Создаём:
- временный физический том для / раздела
- группу томов VG02
- временный том

~~~shell
pvcreate /dev/sdb
~~~

~~~shell
[root@localhost ~]# vgcreate VG02 /dev/sdb
  Volume group "VG02" successfully created
~~~

~~~shell
[root@localhost ~]# lvcreate -n xtmp -l+100%FREE /dev/VG02
  Logical volume "xtmp" created.
~~~

Создаём ФС xfs и монтируем:

~~~shell
[root@localhost ~]# mkfs.xfs /dev/VG02/xtmp && mount /dev/VG02/xtmp /mnt
meta-data=/dev/VG02/xtmp         isize=512    agcount=4, agsize=655104 blks
         =                       sectsz=512   attr=2, projid32bit=1
         =                       crc=1        finobt=0, sparse=0
data     =                       bsize=4096   blocks=2620416, imaxpct=25
         =                       sunit=0      swidth=0 blks
naming   =version 2              bsize=4096   ascii-ci=0 ftype=1
log      =internal log           bsize=4096   blocks=2560, version=2
         =                       sectsz=512   sunit=0 blks, lazy-count=1
realtime =none                   extsz=4096   blocks=0, rtextents=0
~~~

Переносим данные:

~~~shell
[root@localhost ~]# xfsdump -J - /dev/VolGroup00/LogVol00 | xfsrestore -J - /mnt
xfsrestore: using file dump (drive_simple) strategy
xfsrestore: version 3.1.7 (dump format 3.0)
xfsdump: using file dump (drive_simple) strategy
xfsdump: version 3.1.7 (dump format 3.0)
xfsdump: level 0 dump of localhost.localdomain:/
xfsdump: dump date: Tue Jan  3 12:37:23 2023
xfsdump: session id: 9c73702c-820a-4a8f-b402-bf04cd18d3a7
xfsdump: session label: ""
xfsrestore: searching media for dump
xfsdump: ino map phase 1: constructing initial dump list
xfsdump: ino map phase 2: skipping (no pruning necessary)
xfsdump: ino map phase 3: skipping (only one dump stream)
xfsdump: ino map construction complete
xfsdump: estimated dump size: 840029312 bytes
xfsdump: creating dump session media file 0 (media 0, file 0)
xfsdump: dumping ino map
xfsdump: dumping directories
xfsrestore: examining media file 0
xfsrestore: dump description: 
xfsrestore: hostname: localhost.localdomain
xfsrestore: mount point: /
xfsrestore: volume: /dev/mapper/VolGroup00-LogVol00
xfsrestore: session time: Tue Jan  3 12:37:23 2023
xfsrestore: level: 0
xfsrestore: session label: ""
xfsrestore: media label: ""
xfsrestore: file system id: b60e9498-0baa-4d9f-90aa-069048217fee
xfsrestore: session id: 9c73702c-820a-4a8f-b402-bf04cd18d3a7
xfsrestore: media id: 403bd2f6-b2d8-48af-b29f-e84101a92961
xfsrestore: searching media for directory dump
xfsrestore: reading directories
xfsdump: dumping non-directory files
xfsrestore: 2673 directories and 23425 entries processed
xfsrestore: directory post-processing
xfsrestore: restoring non-directory files
xfsdump: ending media file
xfsdump: media file size 817206736 bytes
xfsdump: dump size (non-dir files) : 804137608 bytes
xfsdump: dump complete: 17 seconds elapsed
xfsdump: Dump Status: SUCCESS
xfsrestore: restore complete: 17 seconds elapsed
xfsrestore: Restore Status: SUCCESS
~~~

Проверяем:

~~~shell
[root@localhost ~]# ls /mnt
bin  boot  dev  etc  home  lib  lib64  media  mnt  opt  proc  root  run  sbin  srv  sys  tmp  usr  var
~~~

Сымитируем текущий root -> сделаем в него chroot и обновим grub:

~~~shell
for i in /proc/ /sys/ /dev/ /run/ /boot/; do mount --bind $i /mnt/$i; done
[root@localhost ~]# chroot /mnt/
~~~

~~~shell
[root@localhost /]# grub2-mkconfig -o /boot/grub2/grub.cfg
Generating grub configuration file ...
Found linux image: /boot/vmlinuz-3.10.0-862.2.3.el7.x86_64
Found initrd image: /boot/initramfs-3.10.0-862.2.3.el7.x86_64.img
done
~~~

Обновим образ initrd:

~~~shell
[root@localhost /]# cd /boot ; for i in `ls initramfs-*img`; do dracut -v $i `echo $i|sed "s/initramfs-//g; s/.img//g"` --force; done
Executing: /sbin/dracut -v initramfs-3.10.0-862.2.3.el7.x86_64.img 3.10.0-862.2.3.el7.x86_64 --force
dracut module 'busybox' will not be installed, because command 'busybox' could not be found!
dracut module 'crypt' will not be installed, because command 'cryptsetup' could not be found!
dracut module 'dmraid' will not be installed, because command 'dmraid' could not be found!
dracut module 'dmsquash-live-ntfs' will not be installed, because command 'ntfs-3g' could not be found!
dracut module 'mdraid' will not be installed, because command 'mdadm' could not be found!
dracut module 'multipath' will not be installed, because command 'multipath' could not be found!
dracut module 'busybox' will not be installed, because command 'busybox' could not be found!
dracut module 'crypt' will not be installed, because command 'cryptsetup' could not be found!
dracut module 'dmraid' will not be installed, because command 'dmraid' could not be found!
dracut module 'dmsquash-live-ntfs' will not be installed, because command 'ntfs-3g' could not be found!
dracut module 'mdraid' will not be installed, because command 'mdadm' could not be found!
dracut module 'multipath' will not be installed, because command 'multipath' could not be found!
*** Including module: bash ***
*** Including module: nss-softokn ***
*** Including module: i18n ***
*** Including module: drm ***
*** Including module: plymouth ***
*** Including module: dm ***
Skipping udev rule: 64-device-mapper.rules
Skipping udev rule: 60-persistent-storage-dm.rules
Skipping udev rule: 55-dm.rules
*** Including module: kernel-modules ***
Omitting driver floppy
*** Including module: lvm ***
Skipping udev rule: 64-device-mapper.rules
Skipping udev rule: 56-lvm.rules
Skipping udev rule: 60-persistent-storage-lvm.rules
*** Including module: qemu ***
*** Including module: resume ***
*** Including module: rootfs-block ***
*** Including module: terminfo ***
*** Including module: udev-rules ***
Skipping udev rule: 40-redhat-cpu-hotplug.rules
Skipping udev rule: 91-permissions.rules
*** Including module: biosdevname ***
*** Including module: systemd ***
*** Including module: usrmount ***
*** Including module: base ***
*** Including module: fs-lib ***
*** Including module: shutdown ***
*** Including modules done ***
*** Installing kernel module dependencies and firmware ***
*** Installing kernel module dependencies and firmware done ***
*** Resolving executable dependencies ***
*** Resolving executable dependencies done***
*** Hardlinking files ***
*** Hardlinking files done ***
*** Stripping files ***
*** Stripping files done ***
*** Generating early-microcode cpio image contents ***
*** No early-microcode cpio image needed ***
*** Store current command line parameters ***
*** Creating image file ***
*** Creating image file done ***
*** Creating initramfs image file '/boot/initramfs-3.10.0-862.2.3.el7.x86_64.img' done ***
~~~

Изменяем адрес корня и проверяем:

~~~shell
sed -i 's/VolGroup00\/LogVol00/VG02\/xtmp/g' /boot/grub2/grub.cfg

[root@localhost boot]# grep VolGroup00 /boot/grub2/grub.cfg
	linux16 /vmlinuz-3.10.0-862.2.3.el7.x86_64 root=/dev/mapper/VG02-xtmp ro no_timer_check console=tty0 console=ttyS0,115200n8 net.ifnames=0 biosdevname=0 elevator=noop crashkernel=auto rd.lvm.lv=VG02/xtmp rd.lvm.lv=VolGroup00/LogVol01 rhgb quiet 
~~~

Перезагружаемся:

~~~shell
[root@localhost boot]# exit
exit
[root@localhost ~]# reboot
~~~

Просле ребута:

~~~shell
[vagrant@localhost ~]$ lsblk
NAME                    MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda                       8:0    0   40G  0 disk 
├─sda1                    8:1    0    1M  0 part 
├─sda2                    8:2    0    1G  0 part /boot
└─sda3                    8:3    0   39G  0 part 
  ├─VolGroup00-LogVol01 253:1    0  1.5G  0 lvm  [SWAP]
  └─VolGroup00-LogVol00 253:2    0 37.5G  0 lvm  
sdb                       8:16   0   10G  0 disk 
└─VG02-xtmp             253:0    0   10G  0 lvm  /
sdc                       8:32   0    2G  0 disk 
sdd                       8:48   0    1G  0 disk 
sde                       8:64   0    1G  0 disk 
~~~

Удаляем старый том:

~~~shell
[vagrant@localhost ~]$ lvremove /dev/VolGroup00/LogVol00
Do you really want to remove active logical volume VolGroup00/LogVol00? [y/n]: y
  Logical volume "LogVol00" successfully removed
~~~

Создаём новый том поменьше:

~~~shell
[root@localhost vagrant]# lvcreate -n VolGroup00/LogVol00 -L 8G /dev/VolGroup00
WARNING: xfs signature detected on /dev/VolGroup00/LogVol00 at offset 0. Wipe it? [y/n]: y
  Wiping xfs signature on /dev/VolGroup00/LogVol00.
  Logical volume "LogVol00" created.
~~~

На новом томе создаём ФС xfs:

~~~shell
[root@localhost vagrant]# mkfs.xfs /dev/VolGroup00/LogVol00
meta-data=/dev/VolGroup00/LogVol00 isize=512    agcount=4, agsize=524288 blks
         =                       sectsz=512   attr=2, projid32bit=1
         =                       crc=1        finobt=0, sparse=0
data     =                       bsize=4096   blocks=2097152, imaxpct=25
         =                       sunit=0      swidth=0 blks
naming   =version 2              bsize=4096   ascii-ci=0 ftype=1
log      =internal log           bsize=4096   blocks=2560, version=2
         =                       sectsz=512   sunit=0 blks, lazy-count=1
realtime =none                   extsz=4096   blocks=0, rtextents=0
~~~

Монтирую новый том и переношу данные:

~~~shell
[root@localhost vagrant]# mount /dev/VolGroup00/LogVol00 /mnt 
[root@localhost vagrant]# xfsdump -J - /dev/VG02/xtmp | xfsrestore -J - /mnt
xfsdump: using file dump (drive_simple) strategy
xfsdump: version 3.1.7 (dump format 3.0)
xfsdump: level 0 dump of localhost.localdomain:/
xfsdump: dump date: Tue Jan  3 15:28:31 2023
xfsdump: session id: 0f7ee57d-c18c-489f-8122-61253c32bb1d
xfsdump: session label: ""
xfsrestore: using file dump (drive_simple) strategy
xfsrestore: version 3.1.7 (dump format 3.0)
xfsrestore: searching media for dump
xfsdump: ino map phase 1: constructing initial dump list
xfsdump: ino map phase 2: skipping (no pruning necessary)
xfsdump: ino map phase 3: skipping (only one dump stream)
xfsdump: ino map construction complete
xfsdump: estimated dump size: 838556352 bytes
xfsdump: creating dump session media file 0 (media 0, file 0)
xfsdump: dumping ino map
xfsdump: dumping directories
xfsrestore: examining media file 0
xfsrestore: dump description: 
xfsrestore: hostname: localhost.localdomain
xfsrestore: mount point: /
xfsrestore: volume: /dev/mapper/VG02-xtmp
xfsrestore: session time: Tue Jan  3 15:28:31 2023
xfsrestore: level: 0
xfsrestore: session label: ""
xfsrestore: media label: ""
xfsrestore: file system id: 972bf9cc-774d-4932-94b8-269a957119b7
xfsrestore: session id: 0f7ee57d-c18c-489f-8122-61253c32bb1d
xfsrestore: media id: 58e806a7-bac8-4dea-8fcf-3936992f0795
xfsrestore: searching media for directory dump
xfsrestore: reading directories
xfsdump: dumping non-directory files
xfsrestore: 2677 directories and 23430 entries processed
xfsrestore: directory post-processing
xfsrestore: restoring non-directory files
xfsdump: ending media file
xfsdump: media file size 815869816 bytes
xfsdump: dump size (non-dir files) : 802797008 bytes
xfsdump: dump complete: 15 seconds elapsed
xfsdump: Dump Status: SUCCESS
xfsrestore: restore complete: 15 seconds elapsed
xfsrestore: Restore Status: SUCCESS
~~~

Готовим виртуальный рут для обратного переезда, делаю chroot, обновляем загрузчик:

~~~shell
[root@localhost vagrant]# for i in /proc/ /sys/ /dev/ /run/ /boot/; do mount --bind $i /mnt/$i; done

[root@localhost vagrant]# for i in /proc/ /sys/ /dev/ /run/ /boot/; do mount --bind $i /mnt/$i; done
[root@localhost vagrant]#  chroot /mnt/
[root@localhost /]# grub2-mkconfig -o /boot/grub2/grub.cfg
Generating grub configuration file ...
Found linux image: /boot/vmlinuz-3.10.0-862.2.3.el7.x86_64
Found initrd image: /boot/initramfs-3.10.0-862.2.3.el7.x86_64.img
done
~~~

Обновим образ initrd:

~~~shell
cd /boot ; for i in `ls initramfs-*img`; do dracut -v $i `echo $i|sed "s/initramfs-//g; s/.img//g"` --force; done

xecuting: /sbin/dracut -v initramfs-3.10.0-862.2.3.el7.x86_64.img 3.10.0-862.2.3.el7.x86_64 --force
dracut module 'busybox' will not be installed, because command 'busybox' could not be found!
dracut module 'crypt' will not be installed, because command 'cryptsetup' could not be found!
dracut module 'dmraid' will not be installed, because command 'dmraid' could not be found!
dracut module 'dmsquash-live-ntfs' will not be installed, because command 'ntfs-3g' could not be found!
dracut module 'mdraid' will not be installed, because command 'mdadm' could not be found!
dracut module 'multipath' will not be installed, because command 'multipath' could not be found!
dracut module 'busybox' will not be installed, because command 'busybox' could not be found!
dracut module 'crypt' will not be installed, because command 'cryptsetup' could not be found!
dracut module 'dmraid' will not be installed, because command 'dmraid' could not be found!
dracut module 'dmsquash-live-ntfs' will not be installed, because command 'ntfs-3g' could not be found!
dracut module 'mdraid' will not be installed, because command 'mdadm' could not be found!
dracut module 'multipath' will not be installed, because command 'multipath' could not be found!
*** Including module: bash ***
*** Including module: nss-softokn ***
*** Including module: i18n ***
*** Including module: drm ***
*** Including module: plymouth ***
*** Including module: dm ***
Skipping udev rule: 64-device-mapper.rules
Skipping udev rule: 60-persistent-storage-dm.rules
Skipping udev rule: 55-dm.rules
*** Including module: kernel-modules ***
Omitting driver floppy
*** Including module: lvm ***
Skipping udev rule: 64-device-mapper.rules
Skipping udev rule: 56-lvm.rules
Skipping udev rule: 60-persistent-storage-lvm.rules
*** Including module: qemu ***
*** Including module: resume ***
*** Including module: rootfs-block ***
*** Including module: terminfo ***
*** Including module: udev-rules ***
Skipping udev rule: 40-redhat-cpu-hotplug.rules
Skipping udev rule: 91-permissions.rules
*** Including module: biosdevname ***
*** Including module: systemd ***
*** Including module: usrmount ***
*** Including module: base ***
*** Including module: fs-lib ***
*** Including module: shutdown ***
*** Including modules done ***
*** Installing kernel module dependencies and firmware ***
*** Installing kernel module dependencies and firmware done ***
*** Resolving executable dependencies ***
*** Resolving executable dependencies done***
*** Hardlinking files ***
*** Hardlinking files done ***
*** Stripping files ***
*** Stripping files done ***
*** Generating early-microcode cpio image contents ***
*** No early-microcode cpio image needed ***
*** Store current command line parameters ***
*** Creating image file ***
*** Creating image file done ***
*** Creating initramfs image file '/boot/initramfs-3.10.0-862.2.3.el7.x86_64.img' done ***
~~~
выделить том под /var + в mirror. 

~~~shell
 [root@localhost boot]# pvcreate /dev/sdc /dev/sdd
  Physical volume "/dev/sdc" successfully created.
  Physical volume "/dev/sdd" successfully created.

[root@localhost boot]# vgcreate vg_var /dev/sdc /dev/sdd
  Volume group "vg_var" successfully created
~~~

Создаём сам том: ml - указывает количество зеркал.

~~~shell
[root@localhost boot]# lvcreate -L 950M -m1 -n lv_var vg_var
  Rounding up size to full physical extent 952.00 MiB
  Logical volume "lv_var" created.
~~~

На новом томе создаём ФС ext4:

~~~shell
[root@localhost boot]# mkfs.ext4 /dev/vg_var/lv_var
mke2fs 1.42.9 (28-Dec-2013)
Filesystem label=
OS type: Linux
Block size=4096 (log=2)
Fragment size=4096 (log=2)
Stride=0 blocks, Stripe width=0 blocks
60928 inodes, 243712 blocks
12185 blocks (5.00%) reserved for the super user
First data block=0
Maximum filesystem blocks=249561088
8 block groups
32768 blocks per group, 32768 fragments per group
7616 inodes per group
Superblock backups stored on blocks: 
	32768, 98304, 163840, 229376

Allocating group tables: done                            
Writing inode tables: done                            
Creating journal (4096 blocks): done
Writing superblocks and filesystem accounting information: done
~~~

Монтирую новый том и переношу данные:

~~~shell
[root@localhost boot]# mount /dev/vg_var/lv_var /mnt

[root@localhost boot]# cp -aR /var/* /mnt/
[root@localhost boot]# rsync -avHPSAX /var/ /mnt/
~~~

Проверяем:

~~~shell
[root@localhost boot]# ls -la /mnt/
total 84
drwxr-xr-x. 19 root root  4096 Jan  3 16:07 .
drwxr-xr-x. 17 root root   224 Jan  3 15:28 ..
drwxr-xr-x.  2 root root  4096 Apr 11  2018 adm
drwxr-xr-x.  5 root root  4096 May 12  2018 cache
drwxr-xr-x.  3 root root  4096 May 12  2018 db
drwxr-xr-x.  3 root root  4096 May 12  2018 empty
drwxr-xr-x.  2 root root  4096 Apr 11  2018 games
drwxr-xr-x.  2 root root  4096 Apr 11  2018 gopher
drwxr-xr-x.  3 root root  4096 May 12  2018 kerberos
drwxr-xr-x. 28 root root  4096 Jan  3 15:28 lib
drwxr-xr-x.  2 root root  4096 Apr 11  2018 local
lrwxrwxrwx.  1 root root    11 Jan  3 15:28 lock -> ../run/lock
drwxr-xr-x.  8 root root  4096 Jan  3 15:21 log
drwx------.  2 root root 16384 Jan  3 16:04 lost+found
lrwxrwxrwx.  1 root root    10 Jan  3 15:28 mail -> spool/mail
drwxr-xr-x.  2 root root  4096 Apr 11  2018 nis
drwxr-xr-x.  2 root root  4096 Apr 11  2018 opt
drwxr-xr-x.  2 root root  4096 Apr 11  2018 preserve
lrwxrwxrwx.  1 root root     6 Jan  3 15:28 run -> ../run
drwxr-xr-x.  8 root root  4096 May 12  2018 spool
drwxrwxrwt.  4 root root  4096 Jan  3 16:00 tmp
drwxr-xr-x.  2 root root  4096 Apr 11  2018 yp
~~~

Делаем резервную копию с прежнего места:

~~~shell
[root@localhost boot]# mkdir /tmp/oldvar && mv /var/* /tmp/oldvar
~~~

Размонтируем с временного и примонтирую в целевую точку:

~~~shell
[root@localhost boot]# umount /mnt && mount /dev/vg_var/lv_var /var
~~~

Обновляем fstab:

~~~shell
[root@localhost boot]# echo "blkid | grep var: | awk '{print $2}' /var ext4 defaults 0 0" >> /etc/fstab
~~~

Выходим из chroot и делаем ребут:

~~~shell
[root@localhost boot]# exit
exit
[root@localhost vagrant]# reboot
~~~

Удаляем временный раздел/группу томов/ физичекий том

~~~shell
[root@localhost vagrant]# lvremove /dev/VG02/xtmp
Do you really want to remove active logical volume VG02/xtmp? [y/n]: y
  Logical volume "xtmp" successfully removed

[root@localhost vagrant]# vgremove /dev/VG02
  Volume group "VG02" successfully removed


[root@localhost vagrant]# pvremove /dev/sdb
  Labels on physical volume "/dev/sdb" successfully wiped.
~~~

Выделить том под /home

~~~shell
[root@localhost vagrant]# lvcreate -n LV_Home -L 2G /dev/VolGroup00
  Logical volume "LV_Home" created.
~~~

Создаём ФС xfs:

~~~shell
[root@localhost vagrant]# mkfs.xfs /dev/VolGroup00/LV_Home
meta-data=/dev/VolGroup00/LV_Home isize=512    agcount=4, agsize=131072 blks
         =                       sectsz=512   attr=2, projid32bit=1
         =                       crc=1        finobt=0, sparse=0
data     =                       bsize=4096   blocks=524288, imaxpct=25
         =                       sunit=0      swidth=0 blks
naming   =version 2              bsize=4096   ascii-ci=0 ftype=1
log      =internal log           bsize=4096   blocks=2560, version=2
         =                       sectsz=512   sunit=0 blks, lazy-count=1
realtime =none                   extsz=4096   blocks=0, rtextents=0
~~~

Монтируем во временную точку для переноса данных:

~~~shell
[root@localhost vagrant]# mount /dev/VolGroup00/LV_Home /mnt/
~~~

Переносим данные, удаляем их с прежнего места, размонтируем объем от целевой точки и примонтирем новый объем, обновляем запись в fstab:

~~~shell
[root@localhost vagrant]# rsync -avHPSAX --quiet /home/ /mnt/
[root@localhost vagrant]#  rm -rf /home/*
[root@localhost vagrant]#  umount /mnt && mount /dev/VolGroup00/LV_Home /home/
[root@localhost vagrant]# echo "`blkid | grep Home | awk '{print $2}'` /home xfs defaults 0 0" >> /etc/fstab
~~~

home - сделать том для снэпшотов

Создаём файлы для теста работы снэпшота:

~~~shell
[root@localhost vagrant]# touch /home/file{1..20}

[root@localhost vagrant]# ls /home/
file1  file10  file11  file12  file13  file14  file15  file16  file17  file18  file19  file2  file20  file3  file4  file5  file6  file7  file8  file9  vagrant
~~~

Делаем снапшот:

~~~shell
[root@localhost vagrant]# lvcreate -L 100MB -s -n home_snap /dev/VolGroup00/LV_Home
  Rounding up size to full physical extent 128.00 MiB
  Logical volume "home_snap" created.
~~~

Удаляем часть тестовых файлов:

~~~shell
[root@localhost vagrant]# rm -f /home/file{2..19}
[root@localhost vagrant]# ls /home/
file1  file20  vagrant
~~~

Отмонтируем домашнюю директорию:

~~~shell
umount /home
~~~

Произвожу восстановление файлов и получаю ошибку:

~~~shell
[root@localhost vagrant]# lvconvert --merge /dev/VolGroup00/home_snap
  Command on LV VolGroup00/home_snap is invalid on LV with properties: lv_is_merging_cow .
~~~

Решение - Перезапустить мерж, указав аргументом наименование VG:

~~~shell
lvchange  --refresh VolGroup00
~~~

Примонтируем обратно:

~~~shell
[root@localhost vagrant]# mount /home 

[root@localhost vagrant]# ls /home/ file1 file10 file11 file12 file13 file14 file15 file16 file17 file18 file19 file2 file20 file3 file4 file5 file6 file7 file8 file9 vagrant
~~~