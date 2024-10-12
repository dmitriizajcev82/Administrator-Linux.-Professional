#!/bin/bash
sudo su

apt install borgbackup -y

useradd -m borg
mkdir ~borg/.ssh
touch ~borg/.ssh/authorized_keys
chown -R borg:borg ~borg/.ssh
mkdir /var/backup
mkfs -t ext4 /dev/sdb
mount /dev/sdb /var/backup/


chown borg:borg /var/backup











