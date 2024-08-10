#!/bin/bash

#Создаём файл /etc/default/watchlog:

cat >> /etc/default/watchlog << EOF
# Configuration file for my watchlog service
# Place it to /etc/default

# File and word in that file that we will be monit
WORD="ALERT"
LOG=/var/log/watchlog.log
EOF

#Создаём файл /var/log/watchlog.log:

cat >> /var/log/watchlog.log << EOF
ALERT
EOF

#Создадим скрипт:

cat >> /opt/watchlog.sh << EOF
#!/bin/bash

WORD=\$1
LOG=\$2
DATE=\`date\`

if grep \$WORD \$LOG &> /dev/null
then
logger "\$DATE: I found word, Master!"
else
exit 0
fi
EOF

chmod +x /opt/watchlog.sh

#Создадим юнит для сервиса:

cat >> /etc/systemd/system/watchlog.service << EOF
[Unit]
Description=My watchlog service

[Service]
Type=oneshot
EnvironmentFile=/etc/default/watchlog
ExecStart=/opt/watchlog.sh \$WORD \$LOG
EOF

#Создадим юнит для таймера:

cat >> /etc/systemd/system/watchlog.timer << EOF
[Unit]
Description=Run watchlog script every 30 second

[Timer]
# Run every 30 second
OnUnitActiveSec=30
Unit=watchlog.service
OnCalendar=*:*:0/30

[Install]
WantedBy=multi-user.target
EOF

#Запускаем сервис:
systemctl start watchlog.timer
