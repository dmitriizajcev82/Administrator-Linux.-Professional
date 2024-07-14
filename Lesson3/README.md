# ANSIBLE

Ansible — это инструмент infrastructure as a code для автоматизации задач по подготовке и конфигурированию инфраструктуры.

## Цель домашнего задания

Написать первые шаги с Ansible.
## Описание домашнего задания

Подготовить стенд на Vagrant как минимум с одним сервером. На этом сервере, используя Ansible необходимо развернуть nginx со следующими условиями:
- необходимо использовать модуль yum/apt
- конфигурационный файлы должны быть взяты из шаблона jinja2 с переменными
- после установки nginx должен быть в режиме enabled в systemd
- должен быть использован notify для старта nginx после установки
- сайт должен слушать на нестандартном порту - 8080, для этого использовать переменные в Ansible

## Установка Ansible
Версия Ansible =>2.4 требует для своей работы Python 2.6 или выше
!!! Убедитесь что у Вас установлена нужная версия:

[![Screenshot from 2024-07-14 20.48.38.jpg](https://iimg.su/s/14/th_gtoyBJPLhmMsYjbUAmZlRrCMAKiVWbb8IPaBvYVp.jpg)](https://iimg.su/i/3Tz6G)

- Поднимите управляемый хост командой
~~~shell
vagrant up
~~~
- Для подключения к хосту nginx нам необходимо будет передать множество параметров - это особенность Vagrant. Узнать эти параметры можно с помощью команды vagrant ssh-config. Вот основные необходимые нам:
~~~shell
vagrant ssh-config
~~~

[![Screenshot from 2024-07-14 18.59.24.jpg](https://iimg.su/s/14/th_cfPSbUzct6pX7AYZub9q7jGTSMbbgAGSfLFdLyVy.jpg)](https://iimg.su/i/lXzuS)

- Создайте каталог Ansible и положите в него этот Vagrantfile. Создадим свой первый inventory файл ./staging/hosts. И наконец убедимся, что Ansible может управлять нашим хостом. Сделать это можно с помощью команды:

[![Screenshot from 2024-07-14 19.03.50.jpg](https://iimg.su/s/14/th_2ZvHo4NhXAhbNASXzEe9OIC6mCtdRBlhtf46L2QE.jpg)](https://iimg.su/i/Pbs4u)

- Для этого в текущем каталоге создадим файл ansible.cfg со следующим содержанием:
~~~ansible
[defaults]
inventory = staging/hosts
remote_user = vagrant
host_key_checking = False
retry_files_enabled = False

~~~

- Еще раз убедимся, что управляемый хост доступе, только теперь без
явного указаниā inventory файла:

[![Screenshot from 2024-07-14 19.11.11.jpg](https://iimg.su/s/14/th_9PwHW0HHvKJE7HlbsA77ABVEONcpGHh5MqBW063O.jpg)](https://iimg.su/i/YQfTv)

- Проверим статус сервиса firewalld
  
[![Screenshot from 2024-07-14 19.13.27.jpg](https://iimg.su/s/14/th_5erQEbTZidbLRcVQGp2AKvSkrpBuPfqhb2SvDQpZ.jpg)](https://iimg.su/i/Acw9R)

- Напишем свой Playbook для установки nginx

~~~ansible
ansible-playbook nginx.yml
~~~

[![Screenshot from 2024-07-14 19.20.12.jpg](https://iimg.su/s/14/th_rwHGQOXhhkme8p3QlM7U2fT76ZXNBqEaQMYqOyyy.jpg)](https://iimg.su/i/g7CQB)

-  из консоли выполнить команду:
~~~shell
curl http://192.168.11.150:8080
~~~

[![Screenshot from 2024-07-14 19.22.20.jpg](https://iimg.su/s/14/th_Y4AiwXrEfZNN34tE2X2NkBKRy9folLd6owLiZoRO.jpg)](https://iimg.su/i/QbR8y)