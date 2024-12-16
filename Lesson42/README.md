# Цели домашнего задания

Получить практические навыки в настройке инфраструктуры с помощью манифестов и конфигураций. Отточить навыки использования ansible/vagrant/docker.

## Варианты стенда:
 - nginx + php-fpm (laravel/wordpress) + python (flask/django) + js(react/angular);
 - nginx + java (tomcat/jetty/netty) + go + ruby;
 - можно свои комбинации.
## Реализации на выбор:
 - на хостовой системе через конфиги в /etc;
 - деплой через docker-compose.

Поднимаем машину на лабораторнрм стенде.
~~~shell
vagrant up
~~~

После всех успешных установок, запускается стартовая страница nginx.
[![1.png](https://iimg.su/s/16/T78Nn0BNOgyFlVHxpYhcjO2NmF31vwnXknp0tp2E.png)](https://iimg.su/i/8DI8p)

Сервисы запущены через docker.
