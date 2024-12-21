# Цель домашнего задания
Научиться настраивать репликацию и создавать резервные копии в СУБД PostgreSQL
## Описание домашнего задания
1) Настроить hot_standby репликацию с использованием слотов
2) Настроить правильное резервное копирование

Postgres - это мультипроцессное приложение. Состоит из главного процесса (postgres), который отвечает за подключение клиентов, взаимодействие с кэшом и отвечает за остальные процессы (background processes).

[![2024-12-21_23-03-58.png](https://iimg.su/s/21/q5vXRNpBJ1BrOfaOlv1o2RobIRlSD6ZK3p4Qexag.png)](https://iimg.su/i/wMfGZ)

После создания Vagrantfile запустим наши ВМ командой . Будет создано три виртуальных машины.
~~~shell
vagrant up
~~~
Для удобства на все хосты можно установить текстовый редактор vim и утилиту telnet: 
~~~shell
apt install -y vim telnet
~~~
Команды должны выполняться от root-пользователя
Для перехода в root-пользователя вводим 
~~~shell
sudo -i
~~~
## Настройка hot_standby репликации с использованием слотов
Перед настройкой репликации необходимо установить postgres-server на хосты node1 и node2:
1) Устанавливаем postgresql-server 14: apt install postgresql postgresql-contrib
2) Запускаем postgresql-server: systemctl start postgresql
3) Добавляем postgresql-server в автозагрузку:  systemctl enable postgresql

Далее приступаем к настройке репликации: 
На хосте node1: 
1) Заходим в psql:
~~~shell
[vagrant@node1 ~]$ sudo -u postgres psql
could not change directory to "/home/vagrant": Permission denied
psql (14.5)
Type "help" for help.
~~~ 

2) В psql создаём пользователя replicator c правами репликации и паролем «Otus2022!»
CREATE USER replicator WITH REPLICATION Encrypted PASSWORD 'Otus2022!';

3) В файле /etc/postgresql/14/main/postgresql.conf указываем следующие параметры:
~~~shell
#Указываем ip-адреса, на которых postgres будет слушать трафик на порту 5432 (параметр port)
listen_addresses = 'localhost, 192.168.57.11'
#Указываем порт порт postgres
port = 5432 
#Устанавливаем максимально 100 одновременных подключений
max_connections = 100
log_directory = 'log' 
log_filename = 'postgresql-%a.log' 
log_rotation_age = 1d 
log_rotation_size = 0 
log_truncate_on_rotation = on 
max_wal_size = 1GB
min_wal_size = 80MB
log_line_prefix = '%m [%p] ' 
#Указываем часовой пояс для Москвы
log_timezone = 'UTC+3'
timezone = 'UTC+3'
datestyle = 'iso, mdy'
lc_messages = 'en_US.UTF-8'
lc_monetary = 'en_US.UTF-8' 
lc_numeric = 'en_US.UTF-8' 
lc_time = 'en_US.UTF-8' 
default_text_search_config = 'pg_catalog.english'
#можно или нет подключаться к postgresql для выполнения запросов в процессе восстановления; 
hot_standby = on
#Включаем репликацию
wal_level = replica
#Количество планируемых слейвов
max_wal_senders = 3
#Максимальное количество слотов репликации
max_replication_slots = 3
#будет ли сервер slave сообщать мастеру о запросах, которые он выполняет.
hot_standby_feedback = on
#Включаем использование зашифрованных паролей
password_encryption = scram-sha-256
~~~
4) Настраиваем параметры подключения в файле /etc/postgresql/14/main/pg_hba.conf: 
~~~shell
# TYPE  DATABASE        USER            ADDRESS                 METHOD
# "local" is for Unix domain socket connections only
local   all                  all                                                peer
# IPv4 local connections:
host    all                  all             127.0.0.1/32              scram-sha-256
# IPv6 local connections:
host    all                  all             ::1/128                       scram-sha-256
# Allow replication connections from localhost, by a user with the
# replication privilege.
local   replication      all                                                peer
host    replication     all             127.0.0.1/32               scram-sha-256
host    replication     all             ::1/128                        scram-sha-256
host    replication replication    192.168.57.11/32        scram-sha-256
host    replication replication    192.168.57.12/32        scram-sha-256
~~~

5) Перезапускаем postgresql-server: 
~~~shell
systemctl restart postgresql
~~~
На хосте node2: 
1) Останавливаем postgresql-server:
~~~shell
systemctl stop postgresql
~~~
2) С помощью утилиты pg_basebackup копируем данные с node1:
pg_basebackup -h 192.168.57.11 -U    /var/lib/postgresql/14/main/ -R -P
3) В файле  /etc/postgresql/14/main/postgresql.conf меняем параметр:
listen_addresses = 'localhost, 192.168.57.12' 
4) Запускаем службу postgresql-server: 
~~~shell
systemctl start postgresql
~~~

Проверка репликации: 
На хосте node1 в psql создадим базу otus_test и выведем список БД: 
~~~shell
postgres=# CREATE DATABASE otus_test;
CREATE DATABASE
postgres=# \l
                                  List of databases
   Name    |  Owner   | Encoding |   Collate   |    Ctype    |   Access privileges   
-----------+----------+----------+-------------+-------------+-----------------------
 otus_test | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | 
 postgres  | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | 
 template0 | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =c/postgres  
 template1 | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =c/postgres    
(4 rows)
~~~
Также можно проверить репликацию другим способом: 
 - На хосте node1 в psql вводим команду: select * from pg_stat_replication;
 - На хосте node2 в psql вводим команду: select * from pg_stat_wal_receiver;

## Настройка резервного копирования


Настраивать резервное копирование мы будем с помощью утилиты Barman. В документации Barman рекомендуется разворачивать Barman на отдельном сервере. В этом случае потребуется настроить доступы между серверами по SSH-ключам. В данном руководстве мы будем разворачивать Barman на отдельном хосте, если Вам удобнее, для теста можно будет развернуть Barman на хосте node1. 

На хостах node1 и node2 необходимо установить утилиту barman-cli, для этого: 
 - Устанавливаем barman-cli: 
~~~shell
apt install barman-cli
~~~
На хосте barman выполняем следующие настройки: 
 - Устанавливаем пакеты barman и postgresql-client: 
~~~shell
apt install barman-cli barman postgresql
~~~
 - Переходим в пользователя barman и генерируем ssh-ключ: 
~~~shell
su barman
cd 
~~~
На хосте node1: 
 - Переходим в пользователя postgres и генерируем ssh-ключ: 
~~~shell
su postgres
cd 
ssh-keygen -t rsa -b 4096
~~~
 - После генерации ключа, выводим содержимое файла ~/.ssh/id_rsa.pub: 
~~~shell
cat ~/.ssh/id_rsa.pub 
~~~
 - Копируем содержимое файла на сервер barman в файл /var/lib/barman/.ssh/authorized_keys

 - В psql создаём пользователя barman c правами суперпользователя: 
~~~shell
CREATE USER barman WITH REPLICATION Encrypted PASSWORD 'Otus2022!';
~~~
 - В файл /etc/postgresql/14/main/pg_hba.conf добавляем разрешения для пользователя barman: 
~~~shell
# TYPE  DATABASE        USER            ADDRESS                 METHOD
# "local" is for Unix domain socket connections only
local   all             all                                     peer
# IPv4 local connections:
host    all             all             127.0.0.1/32            scram-sha-256
# IPv6 local connections:
host    all             all             ::1/128                 scram-sha-256
# Allow replication connections from localhost, by a user with the
# replication privilege.
local   replication     all                                     peer
host    replication     all             127.0.0.1/32                 scram-sha-256
host    replication     all             ::1/128                            scram-sha-256
host    replication replication   192.168.57.11/32        scram-sha-256
host    replication replication   192.168.57.12/32        scram-sha-256
host    all                 barman       192.168.57.13/32        scram-sha-256
host    replication   barman       192.168.57.13/32      scram-sha-256
~~~
 - Перезапускаем службу postgresql-14: 
~~~shell
systemctl restart postgresql
~~~
 - В psql создадим тестовую базу otus: 
~~~shell
CREATE DATABASE otus;
~~~
 - В базе создаём таблицу test в базе otus: 
~~~shell
\c otus; 
CREATE TABLE test (id int, name varchar(30));
INSERT INTO test VALUES (1, alex); 
~~~
На хосте barman: 
 - После генерации ключа, выводим содержимое файла ~/.ssh/id_rsa.pub: 
cat ~/.ssh/id_rsa.pub 
Копируем содержимое файла на сервер postgres в файл /var/lib/postgresql/.ssh/authorized_keys
 - Находясь в пользователе barman создаём файл ~/.pgpass со следующим содержимым: 
 - После создания postgres-пользователя barman необходимо проверить, что права для пользователя настроены корректно: 

Проверяем возможность подключения к postgres-серверу: 
~~~shell
bash-4.4$ psql -h 192.168.57.11 -U barman -d postgres 
psql (14.5)
Type "help" for help.

postgres=# \q
bash-4.4$ 

bash-4.4$ psql -h 192.168.57.11 -U barman -c "IDENTIFY_SYSTEM" replication=1
    systemid       | timeline |  xlogpos  | dbname 
---------------------+----------+-----------+--------
 7151863316617733050 |        1 | 0/4000E78 | 
~~~
## Проверка восстановления из бекапов:

На хосте node1 в psql удаляем базы Otus: 
~~~shell
bash-4.4$ psql
psql (14.5)
Type "help" for help.

postgres=# \l
                                  List of databases
   Name    |  Owner   | Encoding |   Collate   |    Ctype    |   Access privileges   
-----------+----------+----------+-------------+-------------+-----------------------
 otus      | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | 
 otus_test | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | 
 postgres  | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | 
 template0 | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =c/postgres          +
           |          |          |             |             | postgres=CTc/postgres
 template1 | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =c/postgres          +
           |          |          |             |             | postgres=CTc/postgres
(5 rows)

postgres=# DROP DATABASE otus;
DROP DATABASE
postgres=# 
postgres=# DROP DATABASE otus_test; 
DROP DATABASE
postgres=# \l 
                                  List of databases
   Name    |  Owner   | Encoding |   Collate   |    Ctype    |   Access privileges   
-----------+----------+----------+-------------+-------------+-----------------------
 postgres  | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | 
 template0 | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =c/postgres          +
           |          |          |             |             | postgres=CTc/postgres
 template1 | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =c/postgres          +
           |          |          |             |             | postgres=CTc/postgres
(3 rows)

postgres=# 
~~~
Далее на хосте barman запустим восстановление: 
~~~shell
bash-4.4$ barman list-backup node1
node1 20221008T010731 - Sat Dec  21 22:07:50 2024 - Size: 41.8 MiB - WAL Size: 0 B
bash-4.4$ 
bash-4.4$ barman recover node1 20221008T010731 /var/lib/postgresql/14/main/ --remote-ssh-comman "ssh postgres@192.168.57.11"
The authenticity of host '192.168.57.11 (192.168.57.11)' can't be established.
ECDSA key fingerprint is SHA256:NDadubkUsCyw+X3o+WPVePaWJ+5Bl99wfYw5/JdrNYs.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Starting remote restore for server node1 using backup 20221008T010731
Destination directory: /var/lib/postgresql/14/main/
Remote command: ssh postgres@192.168.57.11
Copying the base backup.
Copying required WAL segments.
Generating archive status files
Identify dangerous settings in destination directory.

Recovery completed (start time: 2024-12-21 19:20:24.864427+00:00, elapsed time: 4 seconds)
Your PostgreSQL server has been successfully prepared for recovery!
bash-4.4$ 
~~~




