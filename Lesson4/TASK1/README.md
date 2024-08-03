# Задание:

• добавить в Vagrantfile еще дисков

• собрать R0/R5/R10 на выбор

• прописать собранный рейд в конф, чтобы рейд собирался при загрузке

• сломать/починить raid 

• создать GPT раздел и 5 партиций и смонтировать их на диск.

### Добавить в Vagrantfile еще дисков
[![Screenshot from 2024-08-03 19.17.21.jpg](https://s.iimg.su/s/03/q7LfO1udFX4th4CpcNkxfNCA7Ea4pAC2Qv2Pu1eY.jpg)](https://iimg.su/i/oqbAW)

### какие блочные устройства у нас есть и исходя из их кол-ва, размера и поставленной задачи, определимся.

~~~shell
vagrant@disksubsystem:~$ sudo lshw -short | grep disk
/0/3/0.0.0      /dev/sda   disk       68GB VBOX HARDDISK
/0/4/0.0.0      /dev/sdb   disk       1073MB VBOX HARDDISK
/0/5/0.0.0      /dev/sdc   disk       1073MB VBOX HARDDISK
/0/6/0.0.0      /dev/sdd   disk       1073MB VBOX HARDDISK
/0/7/0.0.0      /dev/sde   disk       1073MB VBOX HARDDISK
/0/8/0.0.0      /dev/sdf   disk       1073MB VBOX HARDDISK
~~~

~~~shell
vagrant@disksubsystem:~$ sudo fdisk -l
Disk /dev/sda: 64 GiB, 68719476736 bytes, 134217728 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0xcacfea87

Device     Boot   Start       End   Sectors  Size Id Type
/dev/sda1  *       2048   1499135   1497088  731M 83 Linux
/dev/sda2       1501182 134215679 132714498 63.3G  5 Extended
/dev/sda5       1501184 134215679 132714496 63.3G 8e Linux LVM


Disk /dev/sdb: 1 GiB, 1073741824 bytes, 2097152 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes


Disk /dev/sdc: 1 GiB, 1073741824 bytes, 2097152 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes


Disk /dev/sdd: 1 GiB, 1073741824 bytes, 2097152 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes


Disk /dev/sde: 1 GiB, 1073741824 bytes, 2097152 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes


Disk /dev/sdf: 1 GiB, 1073741824 bytes, 2097152 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes


Disk /dev/mapper/vagrant--vg-root: 62.3 GiB, 66920120320 bytes, 130703360 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes


Disk /dev/mapper/vagrant--vg-swap_1: 980 MiB, 1027604480 bytes, 2007040 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
~~~

### Занулим на всякий случай суперблоки

~~~shell
sudo mdadm --zero-superblock --force /dev/sd{b,c,d,e,f}
~~~

### можно создавать рейд следующей командой:

~~~shell
root@disksubsystem:/home/vagrant# mdadm --create --verbose /dev/md0 -l 6 -n 5 /dev/sd{b,c,d,e,f}
mdadm: layout defaults to left-symmetric
mdadm: layout defaults to left-symmetric
mdadm: chunk size defaults to 512K
mdadm: size set to 1047552K
mdadm: Defaulting to version 1.2 metadata
mdadm: array /dev/md0 started.
~~~

- Мы выбрали RAID 6. Опция -l какого уровня RAID создавать
- Опция - n указывает на кол-во устройств в RAID

### Проверим, что RAID собрался нормально:

~~~shell
root@disksubsystem:/home/vagrant# cat /proc/mdstat
Personalities : [linear] [multipath] [raid0] [raid1] [raid6] [raid5] [raid4] [raid10] 
md0 : active raid6 sdf[4] sde[3] sdd[2] sdc[1] sdb[0]
      3142656 blocks super 1.2 level 6, 512k chunk, algorithm 2 [5/5] [UUUUU]
~~~

### Создание конфигурационного файла mdadm.conf
Для того, чтобы быть уверенным, что ОС запомнила, какой RAID массив требуется создать и какие компоненты в него входят, создадим файл mdadm.conf

~~~shell
root@disksubsystem:/home/vagrant# mdadm --detail --scan --verbose
ARRAY /dev/md0 level=raid6 num-devices=5 metadata=1.2 name=disksubsystem:0 UUID=323655ed:cc02167d:16ac4c85:6332799b
   devices=/dev/sdb,/dev/sdc,/dev/sdd,/dev/sde,/dev/sdf
~~~

### А затем в две команды создадим файл mdadm.conf

~~~shell
root@disksubsystem:/home/vagrant# echo "DEVICE partitions" > /etc/mdadm/mdadm.conf

root@disksubsystem:/home/vagrant# mdadm --detail --scan --verbose | awk '/ARRAY/ {print}' >> /etc/mdadm/mdadm.conf
~~~

## Сломать/починить RAID

### Сделать это можно, например, искусственно “зафейлив” одно из блочных устройств командной:

~~~shell
root@disksubsystem:/home/vagrant# mdadm /dev/md0 --fail /dev/sde
mdadm: set /dev/sde faulty in /dev/md0
~~~

### Посмотрим, как это отразилось на RAID:

~~~shell
root@disksubsystem:/home/vagrant# cat /proc/mdstat
Personalities : [linear] [multipath] [raid0] [raid1] [raid6] [raid5] [raid4] [raid10] 
md0 : active raid6 sdf[4] sde[3](F) sdd[2] sdc[1] sdb[0]
      3142656 blocks super 1.2 level 6, 512k chunk, algorithm 2 [5/4] [UUU_U]
      
unused devices: <none>
root@disksubsystem:/home/vagrant# mdadm -D /dev/md0
/dev/md0:
        Version : 1.2
  Creation Time : Sat Aug  3 16:22:24 2024
     Raid Level : raid6
     Array Size : 3142656 (3.00 GiB 3.22 GB)
  Used Dev Size : 1047552 (1023.17 MiB 1072.69 MB)
   Raid Devices : 5
  Total Devices : 5
    Persistence : Superblock is persistent

    Update Time : Sat Aug  3 16:25:59 2024
          State : clean, degraded 
 Active Devices : 4
Working Devices : 4
 Failed Devices : 1
  Spare Devices : 0

         Layout : left-symmetric
     Chunk Size : 512K

           Name : disksubsystem:0  (local to host disksubsystem)
           UUID : 323655ed:cc02167d:16ac4c85:6332799b
         Events : 19

    Number   Major   Minor   RaidDevice State
       0       8       16        0      active sync   /dev/sdb
       1       8       32        1      active sync   /dev/sdc
       2       8       48        2      active sync   /dev/sdd
       6       0        0        6      removed
       4       8       80        4      active sync   /dev/sdf

       3       8       64        -      faulty   /dev/sde
~~~

### Удалим “сломанный” диск из массива:

~~~shell
root@disksubsystem:/home/vagrant# mdadm /dev/md0 --remove /dev/sde
mdadm: hot removed /dev/sde from /dev/md0
~~~

### Представим, что мы вставили новый диск в сервер и теперь нам нужно добавить его в RAID. Делается это так:

~~~shell
root@disksubsystem:/home/vagrant# mdadm /dev/md0 --add /dev/sde
mdadm: added /dev/sde
~~~

### Диск должен пройти стадию rebuilding. Например, если это был RAID 1 (зеркало), то данные должны скопироваться на новый диск.Процесс rebuild-а можно увидеть в выводе следующих команд:

~~~shell
root@disksubsystem:/home/vagrant# cat /proc/mdstat
Personalities : [linear] [multipath] [raid0] [raid1] [raid6] [raid5] [raid4] [raid10] 
md0 : active raid6 sde[5] sdf[4] sdd[2] sdc[1] sdb[0]
      3142656 blocks super 1.2 level 6, 512k chunk, algorithm 2 [5/5] [UUUUU]
~~~

### Создаем раздел GPT на RAID

~~~shell
root@disksubsystem:/home/vagrant#  parted -s /dev/md0 mklabel gpt
~~~

### Создаем партиции

~~~shell
root@disksubsystem:/home/vagrant# parted /dev/md0 mkpart primary ext4 0% 20%
root@disksubsystem:/home/vagrant#  parted /dev/md0 mkpart primary ext4 20% 40%
root@disksubsystem:/home/vagrant# parted /dev/md0 mkpart primary ext4 40% 60%
root@disksubsystem:/home/vagrant# parted /dev/md0 mkpart primary ext4 60% 80%
root@disksubsystem:/home/vagrant#  parted /dev/md0 mkpart primary ext4 80% 100%
~~~

### Далее можно создать на этих партициях ФС

~~~shell
root@disksubsystem:/home/vagrant# mkdir -p /raid/part{1,2,3,4,5}
~~~

### И смонтировать их по каталогам

~~~shell
root@disksubsystem:/home/vagrant# mkdir -p /raid/part{1,2,3,4,5}
root@disksubsystem:/home/vagrant# for i in $(seq 1 5); do mount /dev/md0p$i /raid/part$i; done
~~~

### Результат работы.

~~~shell
root@disksubsystem:/home/vagrant# lsblk 
NAME                   MAJ:MIN RM   SIZE RO TYPE  MOUNTPOINT
sda                      8:0    0    64G  0 disk  
├─sda1                   8:1    0   731M  0 part  /boot
├─sda2                   8:2    0     1K  0 part  
└─sda5                   8:5    0  63.3G  0 part  
  ├─vagrant--vg-root   252:0    0  62.3G  0 lvm   /
  └─vagrant--vg-swap_1 252:1    0   980M  0 lvm   [SWAP]
sdb                      8:16   0     1G  0 disk  
└─md0                    9:0    0     3G  0 raid6 
  ├─md0p1              259:1    0   612M  0 md    /raid/part1
  ├─md0p2              259:4    0 613.5M  0 md    /raid/part2
  ├─md0p3              259:5    0   615M  0 md    /raid/part3
  ├─md0p4              259:8    0 613.5M  0 md    /raid/part4
  └─md0p5              259:9    0   612M  0 md    /raid/part5
sdc                      8:32   0     1G  0 disk  
└─md0                    9:0    0     3G  0 raid6 
  ├─md0p1              259:1    0   612M  0 md    /raid/part1
  ├─md0p2              259:4    0 613.5M  0 md    /raid/part2
  ├─md0p3              259:5    0   615M  0 md    /raid/part3
  ├─md0p4              259:8    0 613.5M  0 md    /raid/part4
  └─md0p5              259:9    0   612M  0 md    /raid/part5
sdd                      8:48   0     1G  0 disk  
└─md0                    9:0    0     3G  0 raid6 
  ├─md0p1              259:1    0   612M  0 md    /raid/part1
  ├─md0p2              259:4    0 613.5M  0 md    /raid/part2
  ├─md0p3              259:5    0   615M  0 md    /raid/part3
  ├─md0p4              259:8    0 613.5M  0 md    /raid/part4
  └─md0p5              259:9    0   612M  0 md    /raid/part5
sde                      8:64   0     1G  0 disk  
└─md0                    9:0    0     3G  0 raid6 
  ├─md0p1              259:1    0   612M  0 md    /raid/part1
  ├─md0p2              259:4    0 613.5M  0 md    /raid/part2
  ├─md0p3              259:5    0   615M  0 md    /raid/part3
  ├─md0p4              259:8    0 613.5M  0 md    /raid/part4
  └─md0p5              259:9    0   612M  0 md    /raid/part5
sdf                      8:80   0     1G  0 disk  
└─md0                    9:0    0     3G  0 raid6 
  ├─md0p1              259:1    0   612M  0 md    /raid/part1
  ├─md0p2              259:4    0 613.5M  0 md    /raid/part2
  ├─md0p3              259:5    0   615M  0 md    /raid/part3
  ├─md0p4              259:8    0 613.5M  0 md    /raid/part4
  └─md0p5              259:9    0   612M  0 md    /raid/part5

~~~




