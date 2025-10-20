#!/bin/bash  
  
# Задаем задержку в 0.2 секунды между запросами  
delay=0.2  
  
while true; do  
  # Отправляем запрос  
  curl -s http://localhost:1325  
    
  # Ждем заданное время перед следующим запросом  
  sleep $delay 
  done