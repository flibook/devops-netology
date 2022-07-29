# 08-ansible-02-playbook

### Что делает playbook

Плейбук site.yml устанавливает ClickHouse определенной версии, а vector.yml устанавливает Vector, также определенной версии.

### Какие у него есть параметры 

- Хост задается  в файле инвентаризации `prod.yml`, но можно и в самом плэйбуке.
- Версии Clickhouse можно указать в `group_vars\clickhouse`, а версия Vector - из vector.yml

