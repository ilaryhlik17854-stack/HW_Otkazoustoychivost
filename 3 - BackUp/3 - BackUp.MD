# **Домашнее задание к занятию 3 «Резервное копирование» - Рыхлик Илья Александрович**

---

## **Задание 1**

* Составьте команду rsync, которая позволяет создавать зеркальную копию домашней директории пользователя в директорию /tmp/backup
* Необходимо исключить из синхронизации все директории, начинающиеся с точки (скрытые)
* Необходимо сделать так, чтобы rsync подсчитывал хэш-суммы для всех файлов, даже если их время модификации и размер идентичны в источнике и приемнике.
* На проверку направить скриншот с командой и результатом ее выполнения

---

## **Решение 1**

Команда
```
rsync -a --checksum --delete --progress --exclude '.*' /home/debian/ /tmp/backup
```

![1_rsync1](https://github.com/ilaryhlik17854-stack/HW_Otkazoustoychivost/blob/main/2%20-%20Clustering%20and%20load%20balancing/img/6_stat.png?raw=true)

![2_ls-la](https://github.com/ilaryhlik17854-stack/HW_Otkazoustoychivost/blob/main/2%20-%20Clustering%20and%20load%20balancing/img/6_stat.png?raw=true)

---

## **Задание 2**

* Написать скрипт и настроить задачу на регулярное резервное копирование домашней директории пользователя с помощью rsync и cron.
* Резервная копия должна быть полностью зеркальной
* Резервная копия должна создаваться раз в день, в системном логе должна появляться запись об успешном или неуспешном выполнении операции
* Резервная копия размещается локально, в директории /tmp/backup
На проверку направить файл crontab и скриншот с результатом работы утилиты.

---

## **Решение 2**

Создаем скрипт в домашенм каталоге [rsync_ryh.sh](https://github.com/ilaryhlik17854-stack/HW_Otkazoustoychivost/blob/main/2%20-%20Clustering%20and%20load%20balancing/Zapros.sh)

с помощью команды crontab -e создаем задачу для нашего пользователя

правльная задача по времени для запуска раз в сутки в 12-00 долна быть написана 
```
0 12 * * * /home/debian/rsync_ryh.sh
```
для ускорения процесса мы применили в файле [crontab](https://github.com/ilaryhlik17854-stack/HW_Otkazoustoychivost/blob/main/2%20-%20Clustering%20and%20load%20balancing/Zapros.sh) запуск каждые 3 минуты

![3_varlog](https://github.com/ilaryhlik17854-stack/HW_Otkazoustoychivost/blob/main/2%20-%20Clustering%20and%20load%20balancing/img/6_stat.png?raw=true)

