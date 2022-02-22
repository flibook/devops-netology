# Домашнее задание к занятию "6.2. SQL"

## Задача 1
```
version: "3.3"
services:
  postgres:
    image: postgres:12
    environment:
      POSTGRES_DB: "pgdb"
      POSTGRES_USER: "postgres"
      POSTGRES_PASSWORD: "password"
      PGDATA: "/data/pgdata"
    volumes:
      - ./docker_postgres_init.sql:/docker-entrypoint-initdb.d/docker_postgres_init.sql
      - postgres:/data/postgres
      - backup-vol:/backups
    ports:
      - "5431:5432"
volumes:
  postgres: {}
  backup-vol: {}
```

## Задача 2

```
CREATE USER "test-admin-user" WITH PASSWORD 'test-admin-user';
CREATE database test_db;
CREATE TABLE orders  (id SERIAL CONSTRAINT id_pk PRIMARY KEY ,  наименование character varying(100) ,  цена INT);
CREATE TABLE clients (id SERIAL CONSTRAINT id_cl_pk PRIMARY KEY, фамилия character varying(100), "страна проживания" character varying(100), заказ int REFERENCES orders (id));
CREATE INDEX idx_country ON clients("страна проживания");
CREATE USER "test-simple-user" WITH PASSWORD 'test-simple-user';
GRANT ALL ON All Tables In Schema public TO "test-simple-user";

GRANT UPDATE, SELECT, insert, delete ON All Tables In Schema public TO "test-simple-user";

SELECT datname FROM pg_database WHERE datistemplate = false;
postgres
pgdb
test_db

SELECT table_catalog, table_schema, table_name, column_name, column_default, is_nullable, data_type FROM information_schema.columns WHERE table_name in ('clients', 'orders');
pgdb	public	orders	id	nextval('orders_id_seq'::regclass)	NO	integer
pgdb	public	orders	наименование		YES	character varying
pgdb	public	orders	цена		YES	integer
pgdb	public	clients	id	nextval('clients_id_seq'::regclass)	NO	integer
pgdb	public	clients	фамилия		YES	character varying
pgdb	public	clients	страна проживания		YES	character varying
pgdb	public	clients	заказ		YES	integer


SELECT table_name, grantee, privilege_type FROM information_schema.role_table_grants WHERE table_name in ('clients', 'orders');
orders	postgres	INSERT
orders	postgres	SELECT
orders	postgres	UPDATE
orders	postgres	DELETE
orders	postgres	TRUNCATE
orders	postgres	REFERENCES
orders	postgres	TRIGGER
orders	test-simple-user	INSERT
orders	test-simple-user	SELECT
orders	test-simple-user	UPDATE
orders	test-simple-user	DELETE
orders	test-simple-user	TRUNCATE
orders	test-simple-user	REFERENCES
orders	test-simple-user	TRIGGER
clients	postgres	INSERT
clients	postgres	SELECT
clients	postgres	UPDATE
clients	postgres	DELETE
clients	postgres	TRUNCATE
clients	postgres	REFERENCES
clients	postgres	TRIGGER
clients	test-simple-user	INSERT
clients	test-simple-user	SELECT
clients	test-simple-user	UPDATE
clients	test-simple-user	DELETE
clients	test-simple-user	TRUNCATE
clients	test-simple-user	REFERENCES
clients	test-simple-user	TRIGGER
```

## Задача 3

```
INSERT INTO orders ("наименование", "цена") VALUES ('Шоколад', 10), ('Принтер', 3000), ('Книга', 500), ('Монитор', 7000),  ('Гитара', 4000);

INSERT INTO clients ("фамилия", "страна проживания") VALUES ('Иванов Иван Иванович', 'USA'), ('Петров Петр Петрович', 'Canada'), 
('Иоганн Себастьян Бах', 'Japan'), ('Ронни Джеймс Дио', 'Russia'), ('Ritchie Blackmore', 'Russia');

SELECT COUNT(*) FROM orders;
| count |
| 13 |

## Значение 13 видимо из-за того, что сделал несколько раз INSERT

SELECT COUNT(*) FROM clients;
| count |
| 5 |

```

## Задача 4

```
update clients set заказ = 3 where фамилия = 'Иванов Иван Иванович';
update clients set заказ = 4 where фамилия = 'Петров Петр Петрович';
update clients set заказ = 5 where фамилия = 'Иоганн Себастьян Бах';


select clients.фамилия, orders.наименование from clients join orders on orders.id = clients.заказ;

Иванов Иван Иванович	Книга
Петров Петр Петрович	Монитор, 7000), (Гитара 
Иоганн Себастьян Бах	Шоколад

```

## Задача 5


```
explain select clients.фамилия, orders.наименование from clients join orders on orders.id = clients.заказ;

Hash Join  (cost=17.20..29.36 rows=170 width=436)
  Hash Cond: (clients."заказ" = orders.id)
  ->  Seq Scan on clients  (cost=0.00..11.70 rows=170 width=222)
  ->  Hash  (cost=13.20..13.20 rows=320 width=222)
        ->  Seq Scan on orders  (cost=0.00..13.20 rows=320 width=222)


Seq Scan - последовательное, чтение данных таблицы.
cost - значение, для оценки затратности операции. Значение 0.00 — затраты на получение первой строки. 11.70 — затраты на получение всех строк.
rows — приблизительное количество возвращаемых строк при выполнении операции Seq Scan. 
width — средний размер одной строки в байтах.
```

## Задача 6


```
pg_dump pgdb -U postgres -h localhost -p 5431 > pgdb_backup.dump

![](https://github.com/flibook/devops-netology/blob/main/img1.png)

psql -U posgres -W pgdb -p 5431 < pgdb_backup.dump 

![](https://github.com/flibook/devops-netology/blob/main/img2.png
```
---
