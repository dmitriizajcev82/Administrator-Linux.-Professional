# Дата начала и конца
    #TOP ip add
    awk /home/test/Documents/access-4560-644067.log  | uniq -c | sort -nr | head -n 10
    # Записываем в переменную значение полей 4 и 5, удалив квадратные скобки, отправив на последний pipe только первую строку.
    StartTime=$(awk '{print $4 $5}' /home/test/Documents/access-4560-644067.log  | sed 's/\[//; s/\]//' | sed -n 1p)o
    # Записываем в переменную значение полей 4 и 5, удалив квадратные скобки, отправив на последний pipe только последнюю строку, взятую из переменной checkLines.
    EndTime=$(awk '{print $4 $5}' /home/test/Documents/access-4560-644067.log | sed 's/\[//; s/\]//' | sed -n "$checkLines"p)
    # Записываем  количество строк в файле
    echo $checkLines > ./lines
    # Определение количества IP запросов с IP адресов
    #NR - Встроенная переменная AWK определяющая количество записей
    IP=$(awk "NR>$checkLines"  /home/test/Documents/access-4560-644067.log | awk '{print $1}' | sort | uniq -c | sort -rn | awk '{ if ( $1 >= 0 ) { print "Количество запросов:" $1, "IP:" $2 } }')
    # Y количества адресов
    addresses=$(awk '($9 ~ /200/)' /home/test/Documents/access-4560-644067.log |awk '{print $7}'|sort|uniq -c|sort -rn|awk '{ if ( $1 >= 10 ) { print "Количество запросов:" $1, "URL:" $2 } }')
    # Ошибки c момента последнего запуска
    errors=$(cat access-4560-644067.log | cut -d '"' -f3 | cut -d ' ' -f2 | sort | uniq -c | sort -rn)
    # Отправка почты
    echo -e "Данные за период:$StartTime-$EndTime\n$IP\n\n"Часто запрашиваемые адреса:"\n$addresses\n\n"Частые ошибки:"\n$errors" | mail -s "check msg" root@localhost
