## Vagrantfile, который сразу собирает систему с подключенным рейдом

### посмотрим, какие блочные устройства у нас есть и исходя из их кол-ва, размера и поставленной задачи

~~~shell
vagrant@disksubsystem:~$ lsblk
NAME                   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda                      8:0    0   64G  0 disk 
├─sda1                   8:1    0  731M  0 part /boot
├─sda2                   8:2    0    1K  0 part 
└─sda5                   8:5    0 63.3G  0 part 
  ├─vagrant--vg-root   252:0    0 62.3G  0 lvm  /
  └─vagrant--vg-swap_1 252:1    0  980M  0 lvm  [SWAP]
sdb                      8:16   0    1G  0 disk 
sdc                      8:32   0    1G  0 disk 
sdd                      8:48   0    1G  0 disk 
sde                      8:64   0    1G  0 disk 
sdf                      8:80   0    1G  0 disk
~~~

~~~shell
vagrant@disksubsystem:~$ sudo lshw -short | grep disk
/0/3/0.0.0      /dev/sda   disk       68GB VBOX HARDDISK
/0/4/0.0.0      /dev/sdb   disk       1073MB VBOX HARDDISK
/0/5/0.0.0      /dev/sdc   disk       1073MB VBOX HARDDISK
/0/6/0.0.0      /dev/sdd   disk       1073MB VBOX HARDDISK
/0/7/0.0.0      /dev/sde   disk       1073MB VBOX HARDDISK
/0/8/0.0.0      /dev/sdf   disk       1073MB VBOX HARDDISK
~~~

### Запусти Vagrantfile командой 
~~~shell
vagrant up
~~~
### Посмотрим результат

~~~shell
vagrant@disksubsystem:~$ lsblk 
NAME                   MAJ:MIN RM   SIZE RO TYPE   MOUNTPOINT
sda                      8:0    0    64G  0 disk   
├─sda1                   8:1    0   731M  0 part   /boot
├─sda2                   8:2    0     1K  0 part   
└─sda5                   8:5    0  63.3G  0 part   
  ├─vagrant--vg-root   252:0    0  62.3G  0 lvm    /
  └─vagrant--vg-swap_1 252:1    0   980M  0 lvm    [SWAP]
sdb                      8:16   0     1G  0 disk   
└─md0                    9:0    0   2.5G  0 raid10 
  ├─md0p1              259:5    0   510M  0 md     /raid/part1
  ├─md0p2              259:6    0   510M  0 md     /raid/part2
  ├─md0p3              259:7    0 512.5M  0 md     /raid/part3
  ├─md0p4              259:8    0   510M  0 md     /raid/part4
  └─md0p5              259:9    0   510M  0 md     /raid/part5
sdc                      8:32   0     1G  0 disk   
└─md0                    9:0    0   2.5G  0 raid10 
  ├─md0p1              259:5    0   510M  0 md     /raid/part1
  ├─md0p2              259:6    0   510M  0 md     /raid/part2
  ├─md0p3              259:7    0 512.5M  0 md     /raid/part3
  ├─md0p4              259:8    0   510M  0 md     /raid/part4
  └─md0p5              259:9    0   510M  0 md     /raid/part5
sdd                      8:48   0     1G  0 disk   
└─md0                    9:0    0   2.5G  0 raid10 
  ├─md0p1              259:5    0   510M  0 md     /raid/part1
  ├─md0p2              259:6    0   510M  0 md     /raid/part2
  ├─md0p3              259:7    0 512.5M  0 md     /raid/part3
  ├─md0p4              259:8    0   510M  0 md     /raid/part4
  └─md0p5              259:9    0   510M  0 md     /raid/part5
sde                      8:64   0     1G  0 disk   
└─md0                    9:0    0   2.5G  0 raid10 
  ├─md0p1              259:5    0   510M  0 md     /raid/part1
  ├─md0p2              259:6    0   510M  0 md     /raid/part2
  ├─md0p3              259:7    0 512.5M  0 md     /raid/part3
  ├─md0p4              259:8    0   510M  0 md     /raid/part4
  └─md0p5              259:9    0   510M  0 md     /raid/part5
sdf                      8:80   0     1G  0 disk   
└─md0                    9:0    0   2.5G  0 raid10 
  ├─md0p1              259:5    0   510M  0 md     /raid/part1
  ├─md0p2              259:6    0   510M  0 md     /raid/part2
  ├─md0p3              259:7    0 512.5M  0 md     /raid/part3
  ├─md0p4              259:8    0   510M  0 md     /raid/part4
  └─md0p5              259:9    0   510M  0 md     /raid/part5
~~~

### Проверим, что RAID собрался нормально:

~~~shell
vagrant@disksubsystem:~$ cat /proc/mdstat
Personalities : [linear] [multipath] [raid0] [raid1] [raid6] [raid5] [raid4] [raid10] 
md0 : active raid10 sdf[4] sde[3] sdd[2] sdc[1] sdb[0]
      2618880 blocks super 1.2 512K chunks 2 near-copies [5/5] [UUUUU]
      
unused devices: <none>
~~~
