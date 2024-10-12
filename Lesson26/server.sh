#!/bin/bash
sudo su

apt install borgbackup -y

useradd -m borg
mkdir ~borg/.ssh
touch ~borg/.ssh/authorized_keys
chown -R borg:borg ~borg/.ssh
mkdir /var/backup
yes | mkfs -t ext4 /dev/sda
mount /dev/sda /var/backup/


chown borg:borg /var/backup











