#!/bin/bash
sudo su

ssh-keygen -f ~/.ssh/id_rsa -t rsa -N ''
cp borg-backup.sh /etc/
cp borg-backup.timer /etc/systemd/system
cp borg-backup.service /etc/systemd/system
chmod +x /etc/borg-backup.sh
apt install borgbackup -y
useradd -m borg










