# Docker
## Цель домашнего задания
Разобраться с основами docker, с образом, эко системой docker в целом

### Установите Docker на хост машину
~~~Shell
mylab@UM560-XT-faed496e:~$ docker --version
Docker version 24.0.7, build 24.0.7-0ubuntu2~22.04.1
~~~
Проверим работу Docker
~~~shell
mylab@UM560-XT-faed496e:~$ systemctl status docker
● docker.service - Docker Application Container Engine
     Loaded: loaded (/lib/systemd/system/docker.service; enabled; vendor preset: enabled)
     Active: active (running) since Fri 2024-10-04 21:45:55 MSK; 21min ago
TriggeredBy: ● docker.socket
       Docs: https://docs.docker.com
   Main PID: 1895 (dockerd)
      Tasks: 18
     Memory: 98.2M
        CPU: 532ms
     CGroup: /system.slice/docker.service
             └─1895 /usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock
~~~
~~~shell
mylab@UM560-XT-faed496e:~$ docker run hello-world

Hello from Docker!
This message shows that your installation appears to be working correctly.

To generate this message, Docker took the following steps:
 1. The Docker client contacted the Docker daemon.
 2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
    (amd64)
 3. The Docker daemon created a new container from that image which runs the
    executable that produces the output you are currently reading.
 4. The Docker daemon streamed that output to the Docker client, which sent it
    to your terminal.
~~~
Создайте свой кастомный образ nginx на базе alpine. После запуска nginx должен отдавать кастомную страницу (достаточно изменить дефолтную страницу nginx)
~~~shell
FROM alpine:latest

RUN apk update && apk upgrade && apk add nginx && apk add bash



EXPOSE 80

COPY host/default.conf /etc/nginx/http.d/
COPY host/index.html /var/www/default/html/


CMD ["nginx", "-g", "daemon off;"]
~~~
Собираем образ.
~~~shell
mylab@UM560-XT-faed496e:~/Documents/DOCKER$ docker build -t mynginx .    
DEPRECATED: The legacy builder is deprecated and will be removed in a future release.
            Install the buildx component to build images with BuildKit:
            https://docs.docker.com/go/buildx/

Sending build context to Docker daemon  4.608kB
Step 1/6 : FROM alpine:latest
latest: Pulling from library/alpine
43c4264eed91: Pull complete 
Digest: sha256:beefdbd8a1da6d2915566fde36db9db0b524eb737fc57cd1367effd16dc0d06d
Status: Downloaded newer image for alpine:latest
 ---> 91ef0af61f39
Step 2/6 : RUN apk update && apk upgrade && apk add nginx && apk add bash
 ---> Running in b82cece3ba5a
fetch https://dl-cdn.alpinelinux.org/alpine/v3.20/main/x86_64/APKINDEX.tar.gz
fetch https://dl-cdn.alpinelinux.org/alpine/v3.20/community/x86_64/APKINDEX.tar.gz
v3.20.3-119-gbca3ad8e9ed [https://dl-cdn.alpinelinux.org/alpine/v3.20/main]
v3.20.3-119-gbca3ad8e9ed [https://dl-cdn.alpinelinux.org/alpine/v3.20/community]
OK: 24163 distinct packages available
Upgrading critical system libraries and apk-tools:
(1/1) Upgrading apk-tools (2.14.4-r0 -> 2.14.4-r1)
Executing busybox-1.36.1-r29.trigger
Continuing the upgrade transaction with new apk-tools:
OK: 8 MiB in 14 packages
(1/2) Installing pcre (8.45-r3)
(2/2) Installing nginx (1.26.2-r0)
Executing nginx-1.26.2-r0.pre-install
Executing nginx-1.26.2-r0.post-install
Executing busybox-1.36.1-r29.trigger
OK: 9 MiB in 16 packages
(1/4) Installing ncurses-terminfo-base (6.4_p20240420-r1)
(2/4) Installing libncursesw (6.4_p20240420-r1)
(3/4) Installing readline (8.2.10-r0)
(4/4) Installing bash (5.2.26-r0)
Executing bash-5.2.26-r0.post-install
Executing busybox-1.36.1-r29.trigger
OK: 11 MiB in 20 packages
Removing intermediate container b82cece3ba5a
 ---> 4c80c3740624
Step 3/6 : EXPOSE 80
 ---> Running in cbe224c7df61
Removing intermediate container cbe224c7df61
 ---> 8bf903e26675
Step 4/6 : COPY host/default.conf /etc/nginx/http.d/
 ---> 6a7e020e3578
Step 5/6 : COPY host/index.html /var/www/default/html/
 ---> a9b9b60fae0e
Step 6/6 : CMD ["nginx", "-g", "daemon off;"]
 ---> Running in 896c4f582d58
Removing intermediate container 896c4f582d58
 ---> 31799085cac6
Successfully built 31799085cac6
Successfully tagged mynginx:latest
~~~
Проверяем свой образ.
~~~shell
mylab@UM560-XT-faed496e:~/Documents/DOCKER$ sudo docker images
REPOSITORY                    TAG       IMAGE ID       CREATED              SIZE
mynginx                       latest    31799085cac6   About a minute ago   13.8MB
mydocker                      latest    1f2b2d7ae93b   2 days ago           233MB
alpine                        latest    91ef0af61f39   3 weeks ago          7.8MB
ubuntu                        latest    b1e9cef3f297   5 weeks ago          78.1MB
hello-world                   latest    d2c94e258dcb   17 months ago        13.3kB
~~~
Запускаем Docker.
~~~shell
mylab@UM560-XT-faed496e:~/Documents/DOCKER$ docker run -d --name alpcontainer -p 8081:80 mynginx
fca4262dea6500dadd6348370ba5288fe5bf9dcc71eebcf6ede1692f3ce18199
~~~
~~~shell
mylab@UM560-XT-faed496e:~/Documents/DOCKER$ docker ps
CONTAINER ID   IMAGE     COMMAND                  CREATED          STATUS          PORTS                  NAMES
fca4262dea65   mynginx   "nginx -g 'daemon of…"   42 seconds ago   Up 41 seconds   0.0.0.0:8081->80/tcp   alpcontainer
~~~
Проверяем работает ли сайт.
~~~shell
mylab@UM560-XT-faed496e:~/Documents/DOCKER$ curl localhost:8081
<!DOCTYPE html>

<html>

<head>

  <title>DOCKER</title>

  <style>

    body {

      font-family: Arial, sans-serif;

      text-align: center;

      margin-top: 50px;

    }

    h1 {

      color: blue;

    }

    p {

      color: green;

    }

  </style>

</head>

<body>

  <h1>DOCKER</h1>

  <p>Welcome to my web page!</p>

</body>

</html>
~~~
[![docker.jpg](https://s.iimg.su/s/04/YUWU4xeqHbvBHiWjyIkrMAZzwLv7D3FAwULzL0fZ.jpg)](https://iimg.su/i/2Qsxy)

### Определите разницу между контейнером и образом
Что такое контейнер? Проще говоря, контейнеры - это изолированные процессы для каждого из компонентов вашего приложения. Каждый компонент - интерфейсное приложение React, движок API Python и база данных - работает в своей собственной изолированной среде, полностью изолированной от всего остального на вашем компьютере.

Образ Docker (Docker Image) - это неизменяемый файл, содержащий исходный код, библиотеки, зависимости, инструменты и другие файлы, необходимые для запуска приложения.

Из-за того, что образы предназначены только для чтения их иногда называют снимками (snapshot). Они представляют приложение и его виртуальную среду в определенный момент времени. Такая согласованность является одной из отличительных особенностей Docker. Он позволяет разработчикам тестировать и экспериментировать программное обеспечение в стабильных, однородных условиях.

### Ответьте на вопрос: Можно ли в контейнере собрать ядро?
Docker использует ядро основной операционной системы, внутри контейнера нет пользовательского или дополнительного ядра. Все контейнеры, которые запускаются на компьютере, используют это "основное" ядро.



