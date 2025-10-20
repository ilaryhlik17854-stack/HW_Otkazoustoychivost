# **Домашнее задание к занятию 2 «Кластеризация и балансировка нагрузки»**

---


## **Задание 1**

* Запустите два simple python сервера на своей виртуальной машине на разных портах
* Установите и настройте HAProxy, воспользуйтесь материалами к лекции по ссылке
* Настройте балансировку Round-robin на 4 уровне.
* На проверку направьте конфигурационный файл haproxy, скриншоты, где видно перенаправление запросов на разные серверы при обращении к HAProxy.

---

## **Решение 1**

[haprogy.cfg](https://github.com/ilaryhlik17854-stack/HW_Otkazoustoychivost/blob/main/2%20-%20Clustering%20and%20load%20balancing/haproxyZD1.cfg)

```cfg
global
	log /dev/log	local0
	log /dev/log	local1 notice
	chroot /var/lib/haproxy
	stats socket /run/haproxy/admin.sock mode 660 level admin expose-fd listeners
	stats timeout 30s
	user haproxy
	group haproxy
	daemon

	# Default SSL material locations
	ca-base /etc/ssl/certs
	crt-base /etc/ssl/private

	# See: https://ssl-config.mozilla.org/#server=haproxy&server-version=2.0.3&config=intermediate
        ssl-default-bind-ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384
        ssl-default-bind-ciphersuites TLS_AES_128_GCM_SHA256:TLS_AES_256_GCM_SHA384:TLS_CHACHA20_POLY1305_SHA256
        ssl-default-bind-options ssl-min-ver TLSv1.2 no-tls-tickets

defaults
	log	global
	mode	http
	option	httplog
	option	dontlognull
        timeout connect 5000
        timeout client  50000
        timeout server  50000
	errorfile 400 /etc/haproxy/errors/400.http
	errorfile 403 /etc/haproxy/errors/403.http
	errorfile 408 /etc/haproxy/errors/408.http
	errorfile 500 /etc/haproxy/errors/500.http
	errorfile 502 /etc/haproxy/errors/502.http
	errorfile 503 /etc/haproxy/errors/503.http
	errorfile 504 /etc/haproxy/errors/504.http

listen stats  # веб-страница со статистикой
        bind                    :888
        mode                    http
        stats                   enable
        stats uri               /stats
        stats refresh           5s
        stats realm             Haproxy\ Statistics

frontend example  # секция фронтенд
        mode http
        bind :8088
        default_backend web_servers
	
backend web_servers    # секция бэкенд
        mode http
        balance roundrobin
        option httpchk
        http-check send meth GET uri /index.html
        server s1 127.0.0.1:8888 check
        server s2 127.0.0.1:9999 check


listen web_tcp

	bind :1325

	server s1 127.0.0.1:8888 check inter 3s
	server s2 127.0.0.1:9999 check inter 3s

```
для имитации нагрузки используем bash скрипт

[Zapros.sh](https://github.com/ilaryhlik17854-stack/HW_Otkazoustoychivost/blob/main/2%20-%20Clustering%20and%20load%20balancing/Zapros.sh)

```bash
#!/bin/bash  
  
# Задаем задержку в 0.2 секунды между запросами  
delay=0.2  
  
while true; do  
  # Отправляем запрос  
  curl -s http://localhost:1325  
    
  # Ждем заданное время перед следующим запросом  
  sleep $delay 
  done
```
![1_bash](https://github.com/ilaryhlik17854-stack/HW_Otkazoustoychivost/blob/main/2%20-%20Clustering%20and%20load%20balancing/img/1_bash.png?raw=true)

![2_stat](https://github.com/ilaryhlik17854-stack/HW_Otkazoustoychivost/blob/main/2%20-%20Clustering%20and%20load%20balancing/img/6_stat.png?raw=true)

---

## **Задание 2**

* Запустите три simple python сервера на своей виртуальной машине на разных портах
* Настройте балансировку Weighted Round Robin на 7 уровне, чтобы первый сервер имел вес 2, второй - 3, а третий - 4
* HAproxy должен балансировать только тот http-трафик, который адресован домену example.local
* На проверку направьте конфигурационный файл haproxy, скриншоты, где видно перенаправление запросов на разные серверы при обращении к HAProxy c использованием домена example.local и без него.

---

## **Решение 2**

[haprogy.cfg](https://github.com/ilaryhlik17854-stack/HW_Otkazoustoychivost/blob/main/2%20-%20Clustering%20and%20load%20balancing/haproxyZD2.cfg)

```cfg
global
	log /dev/log	local0
	log /dev/log	local1 notice
	chroot /var/lib/haproxy
	stats socket /run/haproxy/admin.sock mode 660 level admin expose-fd listeners
	stats timeout 30s
	user haproxy
	group haproxy
	daemon

	# Default SSL material locations
	ca-base /etc/ssl/certs
	crt-base /etc/ssl/private

	# See: https://ssl-config.mozilla.org/#server=haproxy&server-version=2.0.3&config=intermediate
        ssl-default-bind-ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384
        ssl-default-bind-ciphersuites TLS_AES_128_GCM_SHA256:TLS_AES_256_GCM_SHA384:TLS_CHACHA20_POLY1305_SHA256
        ssl-default-bind-options ssl-min-ver TLSv1.2 no-tls-tickets

defaults
	log	global
	mode	http
	option	httplog
	option	dontlognull
        timeout connect 5000
        timeout client  50000
        timeout server  50000
	errorfile 400 /etc/haproxy/errors/400.http
	errorfile 403 /etc/haproxy/errors/403.http
	errorfile 408 /etc/haproxy/errors/408.http
	errorfile 500 /etc/haproxy/errors/500.http
	errorfile 502 /etc/haproxy/errors/502.http
	errorfile 503 /etc/haproxy/errors/503.http
	errorfile 504 /etc/haproxy/errors/504.http

listen stats  # веб-страница со статистикой
        bind                    :888
        mode                    http
        stats                   enable
        stats uri               /stats
        stats refresh           5s
        stats realm             Haproxy\ Statistics

frontend example  # секция фронтенд
        mode http
        bind :8088
        acl ACL_HOST hdr(host) -i example.local
		use_backend web_servers if ACL_HOST
	
backend web_servers    # секция бэкенд
        mode http
        balance roundrobin
        option httpchk
        http-check send meth GET uri /index.html
        server s1 127.0.0.1:8888 weight 2 check
        server s2 127.0.0.1:9999 weight 3 check
		server s3 127.0.0.1:7777 weight 4 check
```
[ZaprosZD2.sh](https://github.com/ilaryhlik17854-stack/HW_Otkazoustoychivost/blob/main/2%20-%20Clustering%20and%20load%20balancing/ZaprosZD2.sh)

```bash
#!/bin/bash  
  
# Задаем задержку в 0.2 секунды между запросами  
delay=0.2  
  
while true; do  
  # Отправляем запрос  
  curl -H 'Host:example.local' http://127.0.0.1:8088  
    
  # Ждем заданное время перед следующим запросом  
  sleep $delay 
  done
```

![3_bash](https://github.com/ilaryhlik17854-stack/HW_Otkazoustoychivost/blob/main/2%20-%20Clustering%20and%20load%20balancing/img/3_bash.png?raw=true)

![4_bash](https://github.com/ilaryhlik17854-stack/HW_Otkazoustoychivost/blob/main/2%20-%20Clustering%20and%20load%20balancing/img/4_bash.png?raw=true)

![5_stat](https://github.com/ilaryhlik17854-stack/HW_Otkazoustoychivost/blob/main/2%20-%20Clustering%20and%20load%20balancing/img/5_stat.png?raw=true)