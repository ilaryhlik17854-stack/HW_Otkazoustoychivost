# **Домашнее задание к занятию 1 «Disaster recovery и Keepalived»**
Рыхлик Илья Александрович

---

## **Задание 1**

* Дана схема для Cisco Packet Tracer, рассматриваемая в лекции.
![Схема задания](https://github.com/username/reponame/blob/branch/path/image.png)
* На данной схеме уже настроено отслеживание интерфейсов маршрутизаторов Gi0/1 (для нулевой группы)
* Необходимо аналогично настроить отслеживание состояния интерфейсов Gi0/0 (для первой группы).
* Для проверки корректности настройки, разорвите один из кабелей между одним из маршрутизаторов и Switch0 и запустите ping между PC0 и Server0.
* На проверку отправьте получившуюся схему в формате pkt и скриншот, где виден процесс настройки маршрутизатора.

---

## **Решение 1**

[Ссылка на файл с готовым заданием]()

show running-config router1 for ininterface GigabitEthernet0/0-1

```
!
interface GigabitEthernet0/0
 ip address 192.168.0.2 255.255.255.0
 duplex auto
 speed auto
 shutdown
 standby version 2
 standby 0 ip 192.168.0.1
 standby priority 105
 standby preempt
 standby 0 track GigabitEthernet0/1
!
interface GigabitEthernet0/1
 ip address 192.168.1.2 255.255.255.0
 duplex auto
 speed auto
 shutdown
 standby version 2
 standby 1 ip 192.168.1.1
 standby 1 priority 50
 standby 1 preempt
 standby 1 track GigabitEthernet0/0
!
```
show running-config router2 for ininterface GigabitEthernet0/0-1

```
!
interface GigabitEthernet0/0
 ip address 192.168.0.3 255.255.255.0
 duplex auto
 speed auto
 shutdown
 standby version 2
 standby 0 ip 192.168.0.1
 standby preempt
 standby 0 track GigabitEthernet0/1
!
interface GigabitEthernet0/1
 ip address 192.168.1.3 255.255.255.0
 duplex auto
 speed auto
 shutdown
 standby version 2
 standby 1 ip 192.168.1.1
 standby 1 priority 45
 standby 1 preempt
 standby 1 track GigabitEthernet0/0
!
```
 
![Разорвана связь SW0_R2)](https://github.com/username/reponame/blob/branch/path/image.png)

![Разорвана связь SW0_R1](https://github.com/username/reponame/blob/branch/path/image.png)

---

## **Задание 2**
* Запустите две виртуальные машины Linux, установите и настройте сервис Keepalived как в лекции, используя пример конфигурационного файла.
* Настройте любой веб-сервер (например, nginx или simple python server) на двух виртуальных машинах
* Напишите Bash-скрипт, который будет проверять доступность порта данного веб-сервера и существование файла index.html в root-директории данного веб-сервера.
* Настройте Keepalived так, чтобы он запускал данный скрипт каждые 3 секунды и переносил виртуальный IP на другой сервер, если bash-скрипт завершался с кодом, отличным от нуля (то есть порт веб-сервера был недоступен или отсутствовал index.html). Используйте для этого секцию vrrp_script
* На проверку отправьте получившейся bash-скрипт и конфигурационный файл keepalived, а также скриншот с демонстрацией переезда плавающего ip на другой сервер в случае недоступности порта или файла index.html

---

## **Решение 2**

Для выполнения используем две виртуальные машины в VMBox 
Master - (hostname:debian12) ip address 192.168.100.154
Backup - (hostname:debian11) ip address 192.168.100.53
Virtual ip - 192.168.100.45

На Master - (hostname:debian12) ip address 192.168.100.154 создадим скрипт для проверки доступности хоста и стартовой страницы nginx

[script_keepalived.sh]()

```bash
#!/bin/bash
my_index=`test -f /var/www/html/index.nginx-debian.html && echo $?`
my_port=`bash -c "</dev/tcp/localhost/80" && echo $?`

if [ $my_index -eq 0 ] && [ $my_port -eq 0 ]; then
        exit 0
else
        exit 1
fi
```

задаем конфигурационный файл keepalived на master debian12
[keepalived_debian12.conf]()

```conf
vrrp_script bash_keepal {
    script "/usr/local/bin/script_keepalived.sh"
    interval 3
    fail 1
    rise 2
}

vrrp_instance VI_1 {
    state MASTER
    interface enp0s3
    virtual_router_id 15
    priority 255
    advert_int 1
    virtual_ipaddress {
        192.168.100.45/24
    }
    track_script {
        bash_keepal
    }
}
```

задаем конфигурационный файл keepalived на backup debian11
[keepalived_debian11.conf]()
```conf
vrrp_instance VI_1 {
    state BACKUP
    interface enp0s3
    virtual_router_id 15
    priority 100
    advert_int 1
    virtual_ipaddress {
        192.168.100.45/24
    }
}

```
проверяем работу keeplive

зайдем на страницу virtual ip http://192.168.100.45

![SERV1](https://github.com/username/reponame/blob/branch/path/image.png)

на DEBIAN 12 отключим службу nginx

![SERV2](https://github.com/username/reponame/blob/branch/path/image.png)

