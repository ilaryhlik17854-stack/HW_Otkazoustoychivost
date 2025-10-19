# **Задание №1 - Доработака Рыхлик ИА**
Задание выполнено неправлино так как запрос был направлен не на пральный Backend

Направлял запрос на web_servers, а надо было напралять на web_tcp

в скрипте запрос надо делать на порт 1325 за место 8088

верынй запрос
curl -s http://localhost:1325  

```
listen web_tcp

	bind :1325
```

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

![6_stat](https://github.com/ilaryhlik17854-stack/HW_Otkazoustoychivost/blob/main/2%20-%20Clustering%20and%20load%20balancing/img/6_stat.png?raw=true)