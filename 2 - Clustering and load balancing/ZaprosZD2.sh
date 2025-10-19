#!/bin/bash  
  
# Задаем задержку в 0.2 секунды между запросами  
delay=0.2  
  
while true; do  
  # Отправляем запрос  
  curl -H 'Host:example.local' http://127.0.0.1:8088  
    
  # Ждем заданное время перед следующим запросом  
  sleep $delay 
  done