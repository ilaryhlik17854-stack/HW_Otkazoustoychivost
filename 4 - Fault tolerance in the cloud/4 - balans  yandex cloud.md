# Домашнее задание к занятию «Отказоустойчивость в облаке - Рыхлик ИА»

 ---

## **Задание 1**

Возьмите за основу [решение к заданию 1 из занятия «Подъём инфраструктуры в Яндекс Облаке»](https://github.com/netology-code/sdvps-homeworks/blob/main/7-03.md#задание-1).

1. Теперь вместо одной виртуальной машины сделайте terraform playbook, который:

- создаст 2 идентичные виртуальные машины. Используйте аргумент [count](https://www.terraform.io/docs/language/meta-arguments/count.html) для создания таких ресурсов;
- создаст [таргет-группу](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/lb_target_group). Поместите в неё созданные на шаге 1 виртуальные машины;
- создаст [сетевой балансировщик нагрузки](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/lb_network_load_balancer), который слушает на порту 80, отправляет трафик на порт 80 виртуальных машин и http healthcheck на порт 80 виртуальных машин.

Рекомендуем изучить [документацию сетевого балансировщика нагрузки](https://cloud.yandex.ru/docs/network-load-balancer/quickstart) для того, чтобы было понятно, что вы сделали.

2. Установите на созданные виртуальные машины пакет Nginx любым удобным способом и запустите Nginx веб-сервер на порту 80.

3. Перейдите в веб-консоль Yandex Cloud и убедитесь, что: 

- созданный балансировщик находится в статусе Active,
- обе виртуальные машины в целевой группе находятся в состоянии healthy.

4. Сделайте запрос на 80 порт на внешний IP-адрес балансировщика и убедитесь, что вы получаете ответ в виде дефолтной страницы Nginx.

*В качестве результата пришлите:*

*1. Terraform Playbook.*

*2. Скриншот статуса балансировщика и целевой группы.*

*3. Скриншот страницы, которая открылась при запросе IP-адреса балансировщика.*

---
 
## **Решение 2**

terraform playbook 
[main.tf](https://github.com/ilaryhlik17854-stack/HW_Otkazoustoychivost/blob/main/3%20-%20BackUp/rsync_ryh.sh)

```tf
terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
}

provider "yandex" {
  cloud_id                 = var.cloud_id
  folder_id                = var.folder_id
  service_account_key_file = file("~/authorized_key.json")
  zone      = "ru-central1-b"
}

resource "yandex_compute_instance" "vm" {
  count           = 2
  name            = "vm${count.index}"
  platform_id     = "standard-v1"

  resources {
    cores         = 2
    core_fraction = 5
    memory        = 1
  }

  boot_disk {
    initialize_params {
      image_id = "fd8gqjo661d83tv5dnv4"
      size     = 10
    }
  }
  
  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat       = true
  }

  metadata = {
    user-data = "${file("~/cloud-init.yml")}"
  }

  scheduling_policy {
    preemptible = true
  }
}

resource "yandex_vpc_network" "network-1" {
  name = "network1"
}

resource "yandex_vpc_subnet" "subnet-1" {
  name           = "subnet1"
  zone           = "ru-central1-b"
  v4_cidr_blocks = ["10.10.10.0/24"]
  network_id     = "${yandex_vpc_network.network-1.id}"
}

resource "yandex_lb_target_group" "tg-1" {
  name        = "tg-1"

  target {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    address   = yandex_compute_instance.vm[0].network_interface.0.ip_address
  }
  target {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    address   = yandex_compute_instance.vm[1].network_interface.0.ip_address
  }
}

resource "yandex_lb_network_load_balancer" "lb-1" {
  name = "lb-1"
  deletion_protection = "false"
  listener {
    name = "listener-lb1"
    port = 80
    external_address_spec {
      ip_version = "ipv4"
    }
  }

  attached_target_group {
    target_group_id = yandex_lb_target_group.tg-1.id
    healthcheck {
      name = "http"
        http_options {
          port = 80
          path = "/"
      }
    }
  }
}

output "internal_ip_address_vm_0" {
  value = yandex_compute_instance.vm[0].network_interface.0.ip_address
}

output "external_ip_address_vm_0" {
  value = yandex_compute_instance.vm[0].network_interface.0.nat_ip_address
}

output "internal_ip_address_vm_1" {
  value = yandex_compute_instance.vm[1].network_interface.0.ip_address
}

output "external_ip_address_vm_1" {
  value = yandex_compute_instance.vm[1].network_interface.0.nat_ip_address
}
```

[variables.tf](https://github.com/ilaryhlik17854-stack/HW_Otkazoustoychivost/blob/main/3%20-%20BackUp/rsync_ryh.sh)

```tf
variable "cloud_id" {
  type    = string
  default = "bb1gsijaamfncl16sf7jc"
}
variable "folder_id" {
  type    = string
  default = "b1giahgei1g7tb7vv16i"
}

```

[cloud-init.yml](https://github.com/ilaryhlik17854-stack/HW_Otkazoustoychivost/blob/main/3%20-%20BackUp/rsync_ryh.sh)

```yml
#cloud-config
users:
  - name: user
    groups: sudo
    shell: /bin/bash
    sudo: ["ALL=(ALL) NOPASSWD:ALL"]
    ssh_authorized_keys:
      - ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJVRz6IJ86Jue8vNV/XF2oCXB0bnZYsHWCKqeHJsL2wW debian@debian12

disable_root: true
timezone: Europe/Moscow
repo_update: true
apt:
   preserve_sources_list: true
packages:
  - nginx

runcmd:
  - [ systemctl, nginx-reload ]
  - [ systemctl, enable, nginx.service ]
  - [ systemctl, start, --no-block, nginx.service ]

write_files:
  - path: /var/www/html/index.nginx-debian.html 
    content: |
      SERVER # NETOLOHY RUKHLIK
    
    owner: 'root:root'
    permissions: '0644'
```


Скриншот статуса балансировщика и целевой группы.

[!1-balans](https://github.com/ilaryhlik17854-stack/HW_Otkazoustoychivost/blob/main/3%20-%20BackUp/img/3_varlog.png?raw=true)

запрос к серверу VM0
![2-httpVM0.png](https://github.com/ilaryhlik17854-stack/HW_Otkazoustoychivost/blob/main/3%20-%20BackUp/img/3_varlog.png?raw=true)

запрос к серверу VM1
![3-httpVM1.png](https://github.com/ilaryhlik17854-stack/HW_Otkazoustoychivost/blob/main/3%20-%20BackUp/img/3_varlog.png?raw=true)

запрос к балансировщику
![4-httpBAL.png](https://github.com/ilaryhlik17854-stack/HW_Otkazoustoychivost/blob/main/3%20-%20BackUp/img/3_varlog.png?raw=true)

имитация нагрузки на балансировщик yandex.vloud
![5-script.png](https://github.com/ilaryhlik17854-stack/HW_Otkazoustoychivost/blob/main/3%20-%20BackUp/img/3_varlog.png?raw=true)

