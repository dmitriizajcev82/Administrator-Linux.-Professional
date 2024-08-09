# Задание
- Включить отображение меню Grub.
- Попасть в систему без пароля несколькими способами.
- Установить систему с LVM, после чего переименовать VG.

По умолчанию меню загрузчика Grub скрыто и нет задержки при загрузке. Для отображения меню нужно отредактировать конфигурационный файл.


[![nano_etc.jpg](https://s.iimg.su/s/09/8GI2Jr6q6IQczKw0liecjdm7kEzukl4pJ8tFB6NG.jpg)](https://iimg.su/i/6ctiy)

Комментируем строку, скрывающую меню и ставим задержку для выбора пункта меню в 10 секунд.

[![settime10.jpg](https://s.iimg.su/s/09/i7dmudoUH7OcaXzNMDjtfXGV5tJ56d8eMRbBjuaS.jpg)](https://iimg.su/i/vSKrm)

Обновляем конфигурацию загрузчика и перезагружаемся для проверки.

[![updategrub.jpg](https://s.iimg.su/s/09/9qS1le1HZ202qiTBkHsTJPHlPwG9UWuZTkIIYrsD.jpg)](https://iimg.su/i/wlaYY)

При загрузке в окне виртуальной машины мы должны увидеть меню загрузчика.

[![startubuntu.jpg](https://s.iimg.su/s/09/rxDalg9PeU4SPLBs9juzqUTHILBkWpifpCGIbgp7.jpg)](https://iimg.su/i/hqC73)

## Попасть в систему без пароля несколькими способами

## Способ 1. init=/bin/bash
В конце строки, начинающейся с linux, добавляем init=/bin/bash и нажимаем сtrl-x для загрузки в систему
В целом на этом все, Вы попали в систему. Но есть один нюанс. Рутовая файловая
система при этом монтируется в режиме Read-Only. Если вы хотите перемонтировать ее в режим Read-Write, можно воспользоваться командой:

[![bin_bash.jpg](https://s.iimg.su/s/09/4uoVk5I03m66Y9OdadoAC7MIPblzP3vxp5zG8tki.jpg)](https://iimg.su/i/Jd7Lx)

[![mountgreproot.jpg](https://s.iimg.su/s/09/vSHO8QiBKb1ziwGfuzKipXqf9lF1qAH1spF9OlVk.jpg)](https://iimg.su/i/dJdsj)

## Способ 2. Recovery mode

В этом меню сначала включаем поддержку сети (network) для того, чтобы файловая система перемонтировалась в режим read/write (либо это можно сделать вручную).
Далее выбираем пункт root и попадаем в консоль с пользователем root. Если вы ранее устанавливали пароль для пользователя root (по умолчанию его нет), то необходимо его ввести. 
В этой консоли можно производить любые манипуляции с системой.

[![windowrecoverymode.jpg](https://s.iimg.su/s/09/Fz4Ren5vEmh5whCZgmmLxghWvGCNX5mtfNYD0ylK.jpg)](https://iimg.su/i/IuwSj)

[![rootrecovery.jpg](https://s.iimg.su/s/09/hiVQb4rbsVJ9DDeBl4y98Frm9pEjctNtVI7yDxRt.jpg)](https://iimg.su/i/rsByi)

 ## Установить систему с LVM, после чего переименовать VG

 [![lvmvgs.jpg](https://s.iimg.su/s/09/2qinN0dY2PcDYdmqTdUsErNdHjDXK4RtrRvkahG8.jpg)](https://iimg.su/i/gx3Fp)

 Далее правим /boot/grub/grub.cfg. Везде заменяем старое название VG на новое (в файле дефис меняется на два дефиса ubuntu--vg ubuntu--otus).
После чего можем перезагружаться и, если все сделано правильно, успешно грузимся с новым именем Volume Group и проверяем:



 [![lvmubuntuotus.jpg](https://s.iimg.su/s/09/O1RHh05BdHIzREdXBXDQ2Q1GiStzHJDVTcNhorTO.jpg)](https://iimg.su/i/yvHtt)
