# Сборка ядра Linux

Процесс создания ядра Linux состоит из нескольких шагов. Процедура требует значительного времени для завершения, в зависимости от скорости системы.

1. обновить пакеты обновлений до последний версий и проверить версию ядра.

[![Screenshot-from-2024-05-07-21-24-26.jpg](https://i.postimg.cc/xqDTwZxp/Screenshot-from-2024-05-07-21-24-26.jpg)](https://postimg.cc/N2DcTdwR)

2. загрузить версию ядра с сайта https://kernel.org/

```shell
wget https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-5.4.275.tar.xz
```

3. распакуем архив

```shell
tar xvz linux-5.4.275.tar.xz
```

4. установим дополнительные пакеты

```shell
sudo apt-get install git fakeroot build-essential ncurses-dev xz-utils libssl-dev bc flex libelf-dev bison
```

git - отслеживает и записывает все изменения исходного кода во время разработки. Это также позволяет отменить изменения.

fakeroot - упаковочный инструмент, создающий фальшивую корневую среду.

build-essential - Устанавливает инструменты разработки, такие как C, C++, gcc и g++.
ncurses-dev - Библиотека программирования, предоставляющая API для текстовых терминалов.

xz-utils - обеспечивает быстрое сжатие и распаковку файлов.

libssl-dev - поддерживает SSL и TSL, которые шифруют данные и делают интернет-соединение безопасным.

bc (Basic Calculator) - математический язык сценариев, поддерживающий интерактивное выполнение операторов.

flex (Fast Lexical Analyzer Generator) - генерирует лексические анализаторы, преобразующие символы в токены.

libelf-dev - выдает общую библиотеку для управления файлами ELF (исполняемые файлы, дампы ядра и объектный код)

bison - генератор парсера GNU, который преобразует описание грамматики в программу на языке C.

5.  Скопируйте существующий файл конфигурации с помощью команды cp.

```shell
cp -v /boot/config-$(uname -r) .config
```

6. Внести измения с помощью команды

```shell
make menuconfig
```

7. Сборка ядра

```shell
make
```

[![Screenshot-from-2024-05-07-23-56-23.jpg](https://i.postimg.cc/B6kcLxn9/Screenshot-from-2024-05-07-23-56-23.jpg)](https://postimg.cc/Vr9b20tD)

8. Установим необходимые модули

```shell
sudo make modules_install
```

9. Устаноим ядро

```shell
sudo make install
```

[![Screenshot-from-2024-05-08-00-01-15.jpg](https://i.postimg.cc/s2Vvm1NB/Screenshot-from-2024-05-08-00-01-15.jpg)](https://postimg.cc/rDPVFycc)

10. Обновим загрузчик GRUB

```shell
sudo update-grub
```

[![Screenshot-from-2024-05-08-00-01-50.jpg](https://i.postimg.cc/K8t0Lp6G/Screenshot-from-2024-05-08-00-01-50.jpg)](https://postimg.cc/fVT7QCWp)

11. Перезагрузим OS и проверим версию ядра

```shell
sudo reboot
```

```shell
uname -r
```

[![Screenshot-from-2024-05-08-00-03-05.jpg](https://i.postimg.cc/5tCQjDTg/Screenshot-from-2024-05-08-00-03-05.jpg)](https://postimg.cc/nsnhPSH9)
