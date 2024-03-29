# Домашнее задание к занятию «Компоненты Kubernetes»

### Цель задания

Рассчитать требования к кластеру под проект

## Задание 1: Описать требования к кластеру
Известно, что проекту нужны база данных, система кеширования, а само приложение состоит из бекенда и фронтенда. Опишите, какие ресурсы нужны, если известно:

* база данных должна быть отказоустойчивой. Потребляет около 4 ГБ ОЗУ в работе, 1 ядро, 3 копии;
* кэш должен быть отказоустойчивый. Потребляет: 4 ГБ ОЗУ, 1 ядро, 3 копии;
* фронтенд обрабатывает внешние запросы быстро, отдавая статику: не более 50 МБ ОЗУ на каждый экземпляр, 0.2 ядра, 5 копий ;
* бекенд потребляет 600 МБ ОЗУ и по 1 ядру на копию. 10 копий.

Решение

Минимальные ресурсы необходимые для разворачивания нод кластера
	             CPU 	RAM 	HDD
Control Node 	2 ядра 	2 ГБ 	50 ГБ
Worker Node 	1 ядра 	1 ГБ 	100 ГБ

```
            | Процессор      |  ОЗУ, Гб       | Реплики        | CPU всего, ядро  | ОЗУ всего, Гб |
| --------- |:--------------:|:--------------:|:--------------:|:----------------:|:-------------:|
| БД        | 1              | 4              | 3              | 3                | 12            |
| кэш       | 1              | 4              | 3              | 3                | 12            | 
| фронтенд  | 0,2            | 0,05           | 5              | 1                | 0,25          | 
| бекенд    | 1              | 0,6            | 10             | 10               | 6             |
```


Чтобы обеспечить выполнение 4 пункта(выход из строя как минимум одной ноды) в условия задачи будем брать 3 Worker Node + 3 Control Node, в минимальной конфигурации 2 CPU, 2 RAM.
Добавим 40%. При этом выход из строя одной ноды не приведет к существенным проблемам в работе приложения.

Расчет

    Для проекта потребуется:
        17 процессоров
        30,25 оперативной памяти

    Расчёт с учётом миграций и выхода ноды из строя (примерно)
        CPU: 17 + 40% = 24 
        RAM: 30,25 + 40% = 43 

    Расчёт одной ноды (известно что потребуется три ноды):
        CPU: 24 / 3 = 8 + 1 (на работу самой ноды) = 9
        RAM: 43 / 3 = 15 + 1 (на работу самой ноды) = 16

Итог:

    Нужно 3 рабочие ноды(Worker Node), характеристики одной ноды 9 CPU, 16 RAM
    Нужно 3 управляющие ноды(Control Node), характеристики одной ноды 2 CPU, 2 RAM