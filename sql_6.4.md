Задача 1

-вывода списка БД
\l

-подключения к БД
\c dbname

-вывода списка таблиц
\dt

-вывода описания содержимого таблиц
\dS+ table_name

-выхода из psql
\q

Задача 2

create database test_database;

psql -U postgres -d test_database -p 5432 -W < test_dump.sql

postgres=# \c test_database
Password: 
SSL connection (protocol: TLSv1.3, cipher: TLS_AES_256_GCM_SHA384, bits: 256, compression: off)
You are now connected to database "test_database" as user "postgres".
test_database=# \dt
         List of relations
 Schema |  Name  | Type  |  Owner   
--------+--------+-------+----------
 public | orders | table | postgres
(1 row)


test_database=# analyze verbose orders;
INFO:  analyzing "public.orders"
INFO:  "orders": scanned 1 of 1 pages, containing 8 live rows and 0 dead rows; 8 rows in sample, 8 estimated total rows
ANALYZE

test_database=# select avg_width from pg_stats where tablename='orders';
 avg_width 
-----------
         4
        16
         4


Задача 3

2 варианта партицирования: декларативное партицирование и партицирование через наследование(является более гибким решением).

create table orderss (id serial, title varchar(80), price int) partition by range (price);

create table orders_1 partition of orderss for values from ('0') to ('499');
create table orders_2 partition of orderss for values from ('499') to (maxvalue);

test_database=# \d+ orderss
                                                        Partitioned table "public.orderss"
 Column |         Type          | Collation | Nullable |               Default               | Storage  | Compression | Stats target | Description 
--------+-----------------------+-----------+----------+-------------------------------------+----------+-------------+--------------+-------------
 id     | integer               |           | not null | nextval('orderss_id_seq'::regclass) | plain    |             |              | 
 title  | character varying(80) |           |          |                                     | extended |             |              | 
 price  | integer               |           |          |                                     | plain    |             |              | 
Partition key: RANGE (price)
Partitions: orders_1 FOR VALUES FROM (0) TO (499),
            orders_2 FOR VALUES FROM (499) TO (MAXVALUE)

"Ручного" разбиения таблицы можно было бы избежать на этапе проектирования, изначально заложив партиции. Если, в них, конечно, была необходимость. Или плохо поставлена была задача или неквалифицированность специалистов.  


Задача 4

root@NightWish:~/64# pg_dump -U postgres -W -p 5432 test_database > backup_db.sql
Password: 
root@NightWish:~/64# 

alter table public.orderss add constraint unique_orderss_title unique (title,id,price);
alter table public.orders_1 add constraint unique_orders_2_title unique (title,id,price);
alter table public.orders_2 add constraint unique_orders_2_title unique (title,id,price);

