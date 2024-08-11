# Домашнее задание

1) Создать свой RPM пакет (можно взять свое приложение, либо собрать, например,
Apache с определенными опциями).

2) Создать свой репозиторий и разместить там ранее собранный RPM.

## Создать свой RPM пакет

Для данного задания нам понадобятся следующие установленные пакеты:

~~~shell
[root@rpm vagrant]# yum install -y wget rpmdevtools rpm-build createrepo \
 yum-utils cmake gcc git nano
Last metadata expiration check: 0:01:22 ago on Sun Aug 11 16:38:00 2024.
Dependencies resolved.
===========================================================================================================================
 Package                           Architecture         Version                              Repository               Size
===========================================================================================================================
Installing:
 cmake                             x86_64               3.26.5-2.el9                         appstream               8.7 M
 createrepo_c                      x86_64               0.20.1-2.el9                         appstream                73 k
 gcc                               x86_64               11.4.1-3.el9.alma.1                  appstream                32 M
 git                               x86_64               2.43.5-1.el9_4                       appstream                50 k
 nano                              x86_64               5.6.1-5.el9                          baseos                  690 k
 rpm-build                         x86_64               4.16.1.3-29.el9                      appstream                58 k
 rpmdevtools                       noarch               9.5-1.el9                            appstream                75 k
 wget                              x86_64               1.21.1-7.el9                         appstream               772 k
 yum-utils                         noarch               4.3.0-13.el9                         baseos                   35 k
Installing dependencies:
 annobin                           x86_64               12.31-2.el9                          appstream               1.0 M
 cmake-data                        noarch               3.26.5-2.el9                         appstream               1.7 M
 cmake-filesystem                  x86_64               3.26.5-2.el9                         appstream                11 k
 cmake-rpm-macros                  noarch               3.26.5-2.el9                         appstream                10 k
 createrepo_c-libs                 x86_64               0.20.1-2.el9                         appstream                99 k
 debugedit                         x86_64               5.0-5.el9                            appstream                75 k
 ed                                x86_64               1.14.2-12.el9                        baseos                   74 k
 elfutils                          x86_64               0.190-2.el9                          baseos                  541 k
 emacs-filesystem                  noarch               1:27.2-9.el9                         appstream               7.8 k
 gcc-plugin-annobin                x86_64               11.4.1-3.el9.alma.1                  appstream                43 k
 gdb-minimal                       x86_64               10.2-13.el9                          appstream               3.5 M
 git-core                          x86_64               2.43.5-1.el9_4                       appstream               4.4 M
 git-core-doc                      noarch               2.43.5-1.el9_4                       appstream               2.7 M
 glibc-devel                       x86_64               2.34-100.el9_4.2                     appstream                36 k
 info                              x86_64               6.7-15.el9                           baseos                  224 k
 kernel-headers                    x86_64               5.14.0-427.28.1.el9_4                appstream               6.5 M
 libuv                             x86_64               1:1.42.0-2.el9_4                     appstream               146 k
 libxcrypt-devel                   x86_64               4.4.18-3.el9                         appstream                28 k
 make                              x86_64               1:4.3-8.el9                          baseos                  530 k
 patch                             x86_64               2.7.6-16.el9                         appstream               127 k
 perl-Error                        noarch               1:0.17029-7.el9                      appstream                41 k
 perl-Git                          noarch               2.43.5-1.el9_4                       appstream                37 k
 python3-argcomplete               noarch               1.12.0-5.el9                         appstream                61 k
 python3-chardet                   noarch               4.0.0-5.el9                          baseos                  209 k
 python3-idna                      noarch               2.10-7.el9_4.1                       baseos                   96 k
 python3-pysocks                   noarch               1.7.1-12.el9                         baseos                   34 k
 python3-requests                  noarch               2.25.1-8.el9                         baseos                  113 k
 python3-urllib3                   noarch               1.26.5-5.el9                         baseos                  187 k
 vim-filesystem                    noarch               2:8.2.2637-20.el9_1                  baseos                   14 k
 zstd                              x86_64               1.5.1-2.el9                          baseos                  546 k
~~~

● Для примера возьмем пакет Nginx и соберем его с дополнительным модулем ngx_broli
● Загрузим SRPM пакет Nginx для дальнейшей работы над ним:

~~~shell
[root@rpm vagrant]# yumdownloader --source nginx
enabling appstream-source repository
enabling baseos-source repository
enabling extras-source repository
AlmaLinux 9 - AppStream - Source                                                           239 kB/s | 826 kB     00:03    
AlmaLinux 9 - BaseOS - Source                                                               91 kB/s | 291 kB     00:03    
AlmaLinux 9 - Extras - Source                                                              3.8 kB/s | 7.7 kB     00:02    
nginx-1.20.1-14.el9_2.1.alma.1.src.rpm                                                     1.0 MB/
~~~

● При установке такого пакета в домашней директории создается дерево каталогов для сборки, далее поставим все зависимости для сборки пакета Nginx:

~~~shell
nginx-1.20.1-14.el9_2.1.alma.1.src.rpm                                                     1.0 MB/s | 1.1 MB     00:01    
[root@rpm vagrant]# rpm -Uvh nginx*.src.rpm
warning: nginx-1.14.1-1.el7_4.ngx.src.rpm: Header V4 RSA/SHA1 Signature, key ID 7bd9bf62: NOKEY
Updating / installing...
~~~

~~~shell
[root@rpm vagrant]#  yum-builddep nginx
enabling appstream-source repository
enabling baseos-source repository
enabling extras-source repository
Last metadata expiration check: 0:00:22 ago on Sun Aug 11 16:56:02 2024.
Package make-1:4.3-8.el9.x86_64 is already installed.
Package gcc-11.4.1-3.el9.alma.1.x86_64 is already installed.
Package zlib-devel-1.2.11-40.el9.x86_64 is already installed.
Package openssl-devel-1:3.0.7-27.el9.x86_64 is already installed.
Package systemd-252-32.el9_4.6.x86_64 is already installed.
Package gnupg2-2.3.3-4.el9.x86_64 is already installed.
Dependencies resolved.
~~~

Также нужно скачать исходный код модуля ngx_brotli — он
потребуется при сборке:

~~~shell
[root@rpm vagrant]# cd /root/
~~~

~~~shell
[root@rpm ~]# git clone --recurse-submodules -j8 \
https://github.com/google/ngx_brotli
Cloning into 'ngx_brotli'...
remote: Enumerating objects: 237, done.
remote: Counting objects: 100% (37/37), done.
remote: Compressing objects: 100% (16/16), done.
remote: Total 237 (delta 24), reused 21 (delta 21), pack-reused 200
Receiving objects: 100% (237/237), 79.51 KiB | 733.00 KiB/s, done.
Resolving deltas: 100% (114/114), done.
Submodule 'deps/brotli' (https://github.com/google/brotli.git) registered for path 'deps/brotli'
Cloning into '/root/ngx_brotli/deps/brotli'...
remote: Enumerating objects: 7588, done.        
remote: Counting objects: 100% (1508/1508), done.        
remote: Compressing objects: 100% (336/336), done.        
remote: Total 7588 (delta 1276), reused 1173 (delta 1172), pack-reused 6080        
Receiving objects: 100% (7588/7588), 36.48 MiB | 15.64 MiB/s, done.
Resolving deltas: 100% (4991/4991), done.
Submodule path 'deps/brotli': checked out 'ed738e842d2fbdf2d6459e39267a633c4a9b2f5d'
~~~

~~~shell
[root@rpm brotli]# mkdir out && cd out
~~~

~~~shell
[root@rpm out]# cmake -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=OFF -DCMAKE_C_FLAGS="-Ofast -m64 -march=native -mtune=native -flto -funroll-loops -ffunction-sections -fdata-sections -Wl,--gc-sections" -DCMAKE_CXX_FLAGS="-Ofast -m64 -march=native -mtune=native -flto -funroll-loops -ffunction-sections -fdata-sections -Wl,--gc-sections" -DCMAKE_INSTALL_PREFIX=./installed ..
-- The C compiler identification is GNU 11.4.1
-- Detecting C compiler ABI info
-- Detecting C compiler ABI info - done
-- Check for working C compiler: /bin/cc - skipped
-- Detecting C compile features
-- Detecting C compile features - done
-- Build type is 'Release'
-- Performing Test BROTLI_EMSCRIPTEN
-- Performing Test BROTLI_EMSCRIPTEN - Failed
-- Compiler is not EMSCRIPTEN
-- Looking for log2
-- Looking for log2 - not found
-- Looking for log2
-- Looking for log2 - found
-- Configuring done (0.5s)
-- Generating done (0.0s)
CMake Warning:
  Manually-specified variables were not used by the project:

    CMAKE_CXX_FLAGS
~~~

~~~shell
[root@rpm out]#  cmake --build . --config Release -j 2 --target brotlienc
[  3%] Building C object CMakeFiles/brotlicommon.dir/c/common/constants.c.o
[  6%] Building C object CMakeFiles/brotlicommon.dir/c/common/context.c.o
[ 13%] Building C object CMakeFiles/brotlicommon.dir/c/common/dictionary.c.o
[ 13%] Building C object CMakeFiles/brotlicommon.dir/c/common/platform.c.o
[ 17%] Building C object CMakeFiles/brotlicommon.dir/c/common/shared_dictionary.c.o
[ 20%] Building C object CMakeFiles/brotlicommon.dir/c/common/transform.c.o
[ 24%] Linking C static library libbrotlicommon.a
[ 24%] Built target brotlicommon
[ 27%] Building C object CMakeFiles/brotlienc.dir/c/enc/backward_references.c.o
[ 31%] Building C object CMakeFiles/brotlienc.dir/c/enc/backward_references_hq.c.o
[ 34%] Building C object CMakeFiles/brotlienc.dir/c/enc/bit_cost.c.o
[ 37%] Building C object CMakeFiles/brotlienc.dir/c/enc/block_splitter.c.o
[ 41%] Building C object CMakeFiles/brotlienc.dir/c/enc/brotli_bit_stream.c.o
[ 44%] Building C object CMakeFiles/brotlienc.dir/c/enc/cluster.c.o
[ 48%] Building C object CMakeFiles/brotlienc.dir/c/enc/command.c.o
[ 51%] Building C object CMakeFiles/brotlienc.dir/c/enc/compound_dictionary.c.o
[ 55%] Building C object CMakeFiles/brotlienc.dir/c/enc/compress_fragment.c.o
[ 58%] Building C object CMakeFiles/brotlienc.dir/c/enc/compress_fragment_two_pass.c.o
[ 62%] Building C object CMakeFiles/brotlienc.dir/c/enc/dictionary_hash.c.o
[ 65%] Building C object CMakeFiles/brotlienc.dir/c/enc/encode.c.o
[ 68%] Building C object CMakeFiles/brotlienc.dir/c/enc/encoder_dict.c.o
[ 72%] Building C object CMakeFiles/brotlienc.dir/c/enc/entropy_encode.c.o
[ 75%] Building C object CMakeFiles/brotlienc.dir/c/enc/fast_log.c.o
[ 79%] Building C object CMakeFiles/brotlienc.dir/c/enc/literal_cost.c.o
[ 82%] Building C object CMakeFiles/brotlienc.dir/c/enc/histogram.c.o
[ 86%] Building C object CMakeFiles/brotlienc.dir/c/enc/memory.c.o
[ 89%] Building C object CMakeFiles/brotlienc.dir/c/enc/metablock.c.o
[ 93%] Building C object CMakeFiles/brotlienc.dir/c/enc/static_dict.c.o
[ 96%] Building C object CMakeFiles/brotlienc.dir/c/enc/utf8_util.c.o
[100%] Linking C static library libbrotlienc.a
[100%] Built target brotlienc
~~~

~~~shell
[root@rpm out]#  cd ../../../..
~~~

Теперь можно приступить к сборке RPM пакета:

~~~shell
[root@rpm ~]# cd ~/rpmbuild/SPECS/
[root@rpm SPECS]# rpmbuild -ba nginx.spec -D 'debug_package %{nil}'
setting SOURCE_DATE_EPOCH=1697414400
Executing(%prep): /bin/sh -e /var/tmp/rpm-tmp.8fEJeC
+ umask 022
+ cd /root/rpmbuild/BUILD
+ cat /root/rpmbuild/SOURCES/maxim.key /root/rpmbuild/SOURCES/mdounin.key /root/rpmbuild/SOURCES/sb.key
+ /usr/lib/rpm/redhat/gpgverify --keyring=/root/rpmbuild/BUILD/nginx.gpg --signature=/root/rpmbuild/SOURCES/nginx-1.20.1.tar.gz.asc --data=/root/rpmbuild/SOURCES/nginx-1.20.1.tar.gz
gpgv: Signature made Tue May 25 12:42:56 2021 UTC
gpgv:                using RSA key 520A9993A1C052F8
gpgv: Good signature from "Maxim Dounin <mdounin@mdounin.ru>"
-------------------------------------------------------------------
Executing(%clean): /bin/sh -e /var/tmp/rpm-tmp.7VxEHx
+ umask 022
+ cd /root/rpmbuild/BUILD
+ cd nginx-1.20.1
+ /usr/bin/rm -rf /root/rpmbuild/BUILDROOT/nginx-1.20.1-14.el9.1.alma.1.x86_64
+ RPM_EC=0
++ jobs -p
+ exit 0
~~~

Копируем пакеты в общий каталог:

~~~shell
[root@rpm SPECS]# cp ~/rpmbuild/RPMS/noarch/* ~/rpmbuild/RPMS/x86_64/
[root@rpm SPECS]# cd ~/rpmbuild/RPMS/x86_64
[root@rpm x86_64]# yum localinstall *.rpm
Last metadata expiration check: 0:06:10 ago on Sun Aug 11 16:54:55 2024.
Dependencies resolved.
===========================================================================================================================
 Package                               Architecture     Version                               Repository              Size
===========================================================================================================================
Installing:
 nginx                                 x86_64           1:1.20.1-14.el9.1.alma.1              @commandline            35 k
 nginx-all-modules                     noarch           1:1.20.1-14.el9.1.alma.1              @commandline           7.3 k
 nginx-core                            x86_64           1:1.20.1-14.el9.1.alma.1              @commandline           575 k
 nginx-filesystem                      noarch           1:1.20.1-14.el9.1.alma.1              @commandline           8.4 k
 nginx-mod-devel                       x86_64           1:1.20.1-14.el9.1.alma.1              @commandline           741 k
 nginx-mod-http-image-filter           x86_64           1:1.20.1-14.el9.1.alma.1              @commandline            19 k
 nginx-mod-http-perl                   x86_64           1:1.20.1-14.el9.1.alma.1              @commandline            30 k
 nginx-mod-http-xslt-filter            x86_64           1:1.20.1-14.el9.1.alma.1              @commandline            18 k
 nginx-mod-mail                        x86_64           1:1.20.1-14.el9.1.alma.1              @commandline            53 k
 nginx-mod-stream                      x86_64           1:1.20.1-14.el9.1.alma.1              @commandline            79 k
Installing dependencies:
 almalinux-logos-httpd                 noarch           90.5.1-1.1.el9                        appst
~~~

Теперь можно установить наш пакет и убедиться, что nginx работает:

~~~shell
[root@rpm x86_64]# systemctl start nginx
[root@rpm x86_64]# systemctl status nginx
● nginx.service - The nginx HTTP and reverse proxy server
     Loaded: loaded (/usr/lib/systemd/system/nginx.service; disabled; preset: disabled)
     Active: active (running) since Sun 2024-08-11 17:01:17 UTC; 7s ago
    Process: 34788 ExecStartPre=/usr/bin/rm -f /run/nginx.pid (code=exited, status=0/SUCCESS)
    Process: 34789 ExecStartPre=/usr/sbin/nginx -t (code=exited, status=0/SUCCESS)
    Process: 34790 ExecStart=/usr/sbin/nginx (code=exited, status=0/SUCCESS)
   Main PID: 34791 (nginx)
      Tasks: 2 (limit: 11999)
     Memory: 3.6M
        CPU: 40ms
     CGroup: /system.slice/nginx.service
             ├─34791 "nginx: master process /usr/sbin/nginx"
             └─34792 "nginx: worker process"
~~~

## Создать свой репозиторий и разместить там ранее собранный RPM

Теперь приступим к созданию своего репозитория. Директория для статики у Nginx по умолчанию /usr/share/nginx/html. Создадим там каталог repo:

~~~shell
[root@rpm x86_64]# mkdir /usr/share/nginx/html/repo
~~~

Копируем туда наши собранные RPM-пакеты:

~~~shell
[root@rpm x86_64]# cp ~/rpmbuild/RPMS/x86_64/*.rpm /usr/share/nginx/html/repo/
~~~

Инициализируем репозиторий командой:

~~~shell
[root@rpm x86_64]# createrepo /usr/share/nginx/html/repo/
Directory walk started
Directory walk done - 10 packages
Temporary output repo path: /usr/share/nginx/html/repo/.repodata/
Preparing sqlite DBs
Pool started (with 5 workers)
Pool finished
~~~

Для прозрачности настроим в NGINX доступ к листингу каталога. В файле /etc/nginx/nginx.conf в блоке server добавим следующие директивы:

~~~shell
 server {
	listen       80;
        listen       [::]:80;
        server_name  _;
        root         /usr/share/nginx/html;
        index index.html index.htm;
        autoindex on;
~~~

Проверяем синтаксис и перезапускаем NGINX:

~~~shell
[root@rpm x86_64]# nginx -t
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
[root@rpm x86_64]# nginx -s reload
~~~

Теперь ради интереса можно посмотреть в браузере или с помощью curl:

~~~shell
[root@rpm x86_64]#  curl -a http://localhost/repo/
<html>
<head><title>Index of /repo/</title></head>
<body>
<h1>Index of /repo/</h1><hr><pre><a href="../">../</a>
<a href="repodata/">repodata/</a>                                          11-Aug-2024 17:03                   -
<a href="nginx-1.20.1-14.el9.1.alma.1.x86_64.rpm">nginx-1.20.1-14.el9.1.alma.1.x86_64.rpm</a>            11-Aug-2024 17:02               36347
<a href="nginx-all-modules-1.20.1-14.el9.1.alma.1.noarch.rpm">nginx-all-modules-1.20.1-14.el9.1.alma.1.noarch..&gt;</a> 11-Aug-2024 17:02                7485
<a href="nginx-core-1.20.1-14.el9.1.alma.1.x86_64.rpm">nginx-core-1.20.1-14.el9.1.alma.1.x86_64.rpm</a>       11-Aug-2024 17:02              589281
<a href="nginx-filesystem-1.20.1-14.el9.1.alma.1.noarch.rpm">nginx-filesystem-1.20.1-14.el9.1.alma.1.noarch.rpm</a> 11-Aug-2024 17:02                8556
<a href="nginx-mod-devel-1.20.1-14.el9.1.alma.1.x86_64.rpm">nginx-mod-devel-1.20.1-14.el9.1.alma.1.x86_64.rpm</a>  11-Aug-2024 17:02              759026
<a href="nginx-mod-http-image-filter-1.20.1-14.el9.1.alma.1.x86_64.rpm">nginx-mod-http-image-filter-1.20.1-14.el9.1.alm..&gt;</a> 11-Aug-2024 17:02               19498
<a href="nginx-mod-http-perl-1.20.1-14.el9.1.alma.1.x86_64.rpm">nginx-mod-http-perl-1.20.1-14.el9.1.alma.1.x86_..&gt;</a> 11-Aug-2024 17:02               30996
<a href="nginx-mod-http-xslt-filter-1.20.1-14.el9.1.alma.1.x86_64.rpm">nginx-mod-http-xslt-filter-1.20.1-14.el9.1.alma..&gt;</a> 11-Aug-2024 17:02               18281
<a href="nginx-mod-mail-1.20.1-14.el9.1.alma.1.x86_64.rpm">nginx-mod-mail-1.20.1-14.el9.1.alma.1.x86_64.rpm</a>   11-Aug-2024 17:02               53927
<a href="nginx-mod-stream-1.20.1-14.el9.1.alma.1.x86_64.rpm">nginx-mod-stream-1.20.1-14.el9.1.alma.1.x86_64.rpm</a> 11-Aug-2024 17:02               80543
</pre><hr></body>
</html>
~~~

- Все готово для того, чтобы протестировать репозиторий.
- Добавим его в /etc/yum.repos.d:

~~~shell
[root@rpm x86_64]# cat >> /etc/yum.repos.d/otus.repo << EOF
[otus]
name=otus-linux
baseurl=http://localhost/repo
gpgcheck=0
enabled=1
EOF
~~~

Убедимся, что репозиторий подключился и посмотрим, что в нем есть:

~~~shell
[root@rpm x86_64]# yum repolist enabled | grep otus
otus                             otus-linux
~~~

Добавим пакет в наш репозиторий:

~~~shell
[root@rpm x86_64]# cd /usr/share/nginx/html/repo/
[root@rpm repo]# wget https://repo.percona.com/yum/percona-release-latest.noarch.rpm
--2024-08-11 17:06:19--  https://repo.percona.com/yum/percona-release-latest.noarch.rpm
Resolving repo.percona.com (repo.percona.com)... 49.12.125.205, 2a01:4f8:242:5792::2
Connecting to repo.percona.com (repo.percona.com)|49.12.125.205|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 27900 (27K) [application/x-redhat-package-manager]
Saving to: ‘percona-release-latest.noarch.rpm’

percona-release-latest.noarch. 100%[===================================================>]  27.25K  --.-KB/s    in 0s      

2024-08-11 17:06:19 (159 MB/s) - ‘percona-release-latest.noarch.rpm’ saved [27900/27900]
~~~

Обновим список пакетов в репозитории:

~~~shell
[root@rpm repo]# createrepo /usr/share/nginx/html/repo/
Directory walk started
Directory walk done - 11 packages
Temporary output repo path: /usr/share/nginx/html/repo/.repodata/
Preparing sqlite DBs
Pool started (with 5 workers)
Pool finished
[root@rpm repo]# yum makecache
AlmaLinux 9 - AppStream                                                                    6.6 kB/s | 4.2 kB     00:00    
AlmaLinux 9 - BaseOS                                                                       7.5 kB/s | 3.8 kB     00:00    
AlmaLinux 9 - Extras                                                                       6.5 kB/s | 3.3 kB     00:00    
otus-linux                                                                                 1.4 MB/s | 7.2 kB     00:00    
Metadata cache created.
[root@rpm repo]# yum list | grep otus
percona-release.noarch                               1.0-29                              otus    
~~~

Так как Nginx у нас уже стоит, установим репозиторий percona-release:

~~~shell
[root@rpm repo]# yum install -y percona-release.noarch
Last metadata expiration check: 0:00:25 ago on Sun Aug 11 17:06:40 2024.
Dependencies resolved.
===========================================================================================================================
 Package                             Architecture               Version                     Repository                Size
===========================================================================================================================
Installing:
 percona-release                     noarch                     1.0-29                      otus                      27 k

Transaction Summary
===========================================================================================================================
Install  1 Package

Total download size: 27 k
Installed size: 48 k
Downloading Packages:
percona-release-latest.noarch.rpm                                                          9.1 MB/s |  27 kB     00:00    
---------------------------------------------------------------------------------------------------------------------------
Total                                                                                      2.7 MB/s
~~~

Все прошло успешно. В случае, если  потребуется обновить репозиторий (а это делается при каждом добавлении файлов) снова, то выполните команду

~~~shell
[root@rpm repo]# createrepo /usr/share/nginx/html/repo/
Directory walk started
Directory walk done - 11 packages
Temporary output repo path: /usr/share/nginx/html/repo/.repodata/
Preparing sqlite DBs
Pool started (with 5 workers)
Pool finished
~~~



