# Цель домашнего задания
Отработать навыки установки и настройки DHCP, TFTP, PXE загрузчика и автоматической загрузки

## Описание домашнего задания
1. Настроить загрузку по сети дистрибутива Ubuntu 24
2. Установка должна проходить из HTTP-репозитория.
3. Настроить автоматическую установку c помощью файла user-data

~~~shell
mylab@UM560-XT-faed496e:~/Documents/vagrant_test$ vagrant up
Bringing machine 'pxeserver' up with 'virtualbox' provider...
Bringing machine 'pxeclient' up with 'virtualbox' provider...
~~~
[![mash.jpg](https://s.iimg.su/s/20/vAPXRubDAK48S4w5TOL4koARbPesGYqzsYtJlEBK.jpg)](https://iimg.su/i/7P1Qr)

Данный Vagrantfile развернёт хост pxeserver, настроит его через Ansible, и, далее развернёт хост pxeclient,
который попробует загрузиться через pxe. Из-за тайм-аута настройки команда Vagrant up закончится ошибкой

[![fault_client.jpg](https://s.iimg.su/s/20/QxTTYBsQFjLksTNpudVFM7Jj4fp4ALn1Ka2fwzGm.jpg)](https://iimg.su/i/fBWek)

Образ Ubuntu 24.04 

~~~shell
mylab@UM560-XT-faed496e:~/Documents/vagrant_test$ wget https://releases.ubuntu.com/24.04/ubuntu-24.04.1-live-server-amd64.iso
--2024-10-20 12:53:12--  https://releases.ubuntu.com/24.04/ubuntu-24.04.1-live-server-amd64.iso
Resolving releases.ubuntu.com (releases.ubuntu.com)... 185.125.190.40, 91.189.91.123, 185.125.190.37, ...
Connecting to releases.ubuntu.com (releases.ubuntu.com)|185.125.190.40|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 2773874688 (2.6G) [application/x-iso9660-image]
Saving to: ‘ubuntu-24.04.1-live-server-amd64.iso’

ubuntu-24.04.1-live-server-amd64.iso      100%[===================================================================================>]   2.58G  16.2MB/s    in 2m 22s  

2024-10-20 12:55:34 (18.6 MB/s) - ‘ubuntu-24.04.1-live-server-amd64.iso’ saved [2773874688/2773874688]
~~~
Для запуска Ansible сразу из Vagrant нужно добавить следующий код в описание ВМ pxeserver:
~~~shell
server.vm.provision "ansible" do |ansible|
    ansible.playbook = "ansible/provision.yml"
    ansible.inventory_path = "ansible/hosts"
    ansible.host_key_checking = "false"
    ansible.limit = "all"
end
~~~

[Методичка](https://docs.google.com/document/d/1f5I8vbWAk8ah9IFpAQWN3dcWDHMqXzGb/edit) для выполнения домашнего задания

[![install1.jpg](https://s.iimg.su/s/20/aHlgEFQmCnIPennmJelyhJz9JwR7JJDS9BaY3bEd.jpg)](https://iimg.su/i/emvuC)

[![name.jpg](https://s.iimg.su/s/20/I7FzXmtdWNXjykW4ezXSC5rOq6iU5x143mdthhti.jpg)](https://iimg.su/i/ovUHT)