# <h1>Vagrant</h1>

Vagrant — продукт компании HashiCorp, специализирующейся на инструментах для автоматизации разработки и эксплуатации. Он позволяет создавать и конфигурировать легковесные, повторяемые и переносимые окружения для разработки.

## Проверить версию Vagrant

```Shell
vagrant -v
```

## Инициализация vagrant в текущей директории:

```Shell
vagrant init
```

## Запуск Vagrant Box

```Shell
vagrant up

Bringing machine 'default' up with 'virtualbox' provider...
==> default: Importing base box 'ubuntu/focal64'...
==> default: Matching MAC address for NAT networking...
==> default: Checking if box 'ubuntu/focal64' version '20220427.0.0' is up to date...
==> default: Setting the name of the VM: Lesson1_default_1713903563994_8790
==> default: Clearing any previously set network interfaces...
==> default: Preparing network interfaces based on configuration...
    default: Adapter 1: nat
==> default: Forwarding ports...
    default: 80 (guest) => 8080 (host) (adapter 1)
    default: 22 (guest) => 2222 (host) (adapter 1)
==> default: Running 'pre-boot' VM customizations...
==> default: Booting VM...
==> default: Waiting for machine to boot. This may take a few minutes...
    default: SSH address: 127.0.0.1:2222
    default: SSH username: vagrant
    default: SSH auth method: private key
```

## Для подключения к запущенной виртуальной машине по протоколу ssh используется команда:

```Shell
vagrant ssh
```

## Для остановки виртуальной машины используется команда:

```Shell
vagrant halt
```
