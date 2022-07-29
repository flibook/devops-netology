# Домашнее задание к занятию "8.2 Работа с Playbook"

---
## Основная часть

##### 1. Приготовьте свой собственный inventory файл `prod.yml`.  

##### 2. Допишите playbook: нужно сделать ещё один play, который устанавливает и настраивает [vector](https://vector.dev).

##### 3. При создании tasks рекомендую использовать модули: `get_url`, `template`, `unarchive`, `file`.      

##### 4. Tasks должны: скачать нужной версии дистрибутив, выполнить распаковку в выбранную директорию, установить vector.

<details><summary></summary>

site.yml
```
---
- name: Install Clickhouse
  hosts: ec2-44-209-218-221.compute-1.amazonaws.com
  vars:
    clickhouse_version: 22.3.3.44
    clickhouse_packages:
      - clickhouse-client
      - clickhouse-server
      - clickhouse-common-static

  handlers:
    - name: Start clickhouse service
      become: true
      ansible.builtin.service:
        name: clickhouse-server
        state: restarted
  tasks:
    - block:
        - name: Get clickhouse distrib
          ansible.builtin.get_url:
            url: "https://packages.clickhouse.com/rpm/stable/{{ item }}-{{ clickhouse_version }}.noarch.rpm"
            dest: "./{{ item }}-{{ clickhouse_version }}.rpm"
          with_items: "{{ clickhouse_packages }}"
      rescue:
        - name: Get clickhouse common static
          ansible.builtin.get_url:
            url: "https://packages.clickhouse.com/rpm/stable/clickhouse-common-static-{{ clickhouse_version }}.x86_64.rpm"
            dest: "./clickhouse-common-static-{{ clickhouse_version }}.rpm"
    - name: Install clickhouse packages
      become: true
      ansible.builtin.dnf:
        disable_gpg_check: true
        name:
          - clickhouse-common-static-{{ clickhouse_version }}.rpm
          - clickhouse-client-{{ clickhouse_version }}.rpm
          - clickhouse-server-{{ clickhouse_version }}.rpm
      notify: Start clickhouse service
    - name: Create database
      ansible.builtin.command: "clickhouse-client -q 'create database logs;'"
      register: create_db
      failed_when: create_db.rc != 0 and create_db.rc !=82
      changed_when: create_db.rc == 0
```
vector.yml

```
---
- name: Install Vector
  hosts: ec2-44-208-98-137.compute-1.amazonaws.com
  vars:
    vector_version: 0.23.0
  tasks:
    #- name: Get vector distrib
    #  ansible.builtin.shell:
    #    curl --proto '=https' --tlsv1.2 -sSf https://sh.vector.dev | bash /dev/stdin -y
    - name: Get vector distrib
      ansible.builtin.get_url:
        url: "https://packages.timber.io/vector/0.23.0/vector-{{ vector_version }}-x86_64-unknown-linux-gnu.tar.gz"
        dest: "./{{ vector_version }}.tar.gz"
        mode: 0755
    - name: Create directory /opt/vector/
      become: true
      ansible.builtin.file:
        path: /opt/vector/
        state: directory
        owner: root
        group: root
        mode: 0755
    - name: Copy to folder
      become: true
      ansible.builtin.copy:
        src: "./{{ vector_version }}.tar.gz"
        dest: /opt/vector/{{ vector_version }}.tar.gz
        mode: 0755
        remote_src: yes
    - name: Unpack
      become: true
      ansible.builtin.unarchive:
        src: /opt/vector/{{ vector_version }}.tar.gz
        dest: /opt/vector/
        extra_opts: [--strip-components=2]
        mode: 0755
        remote_src: yes
      ignore_errors: "{{ ansible_check_mode }}"
    - name: Set environment vector
      become: true
      ansible.builtin.template:
        src: templates/vector.sh.j2
        dest: /etc/profile.d/vector.sh
        mode: 0755

```

</details>

    
##### 5. Запустите `ansible-lint site.yml` и исправьте ошибки, если они есть.

Лишние пробелы убрал заранее. Ошибок больше не было.   

<details><summary></summary>


</details>

##### 6. Попробуйте запустить playbook на этом окружении с флагом `--check`.
    
<details><summary></summary>

site.yml

```
PLAY [Install Clickhouse] *********************************************************************************************************************************

TASK [Gathering Facts] ************************************************************************************************************************************
ok: [ec2-44-209-218-221.compute-1.amazonaws.com]

TASK [Get clickhouse distrib] *****************************************************************************************************************************
ok: [ec2-44-209-218-221.compute-1.amazonaws.com] => (item=clickhouse-client)
ok: [ec2-44-209-218-221.compute-1.amazonaws.com] => (item=clickhouse-server)
failed: [ec2-44-209-218-221.compute-1.amazonaws.com] (item=clickhouse-common-static) => {"ansible_loop_var": "item", "changed": false, "dest": "./clickhouse-common-static-22.3.3.44.rpm", "elapsed": 0, "gid": 1000, "group": "ec2-user", "item": "clickhouse-common-static", "mode": "0664", "msg": "Request failed", "owner": "ec2-user", "response": "HTTP Error 404: Not Found", "secontext": "unconfined_u:object_r:user_home_t:s0", "size": 246310036, "state": "file", "status_code": 404, "uid": 1000, "url": "https://packages.clickhouse.com/rpm/stable/clickhouse-common-static-22.3.3.44.noarch.rpm"}

TASK [Get clickhouse common static] ***********************************************************************************************************************
ok: [ec2-44-209-218-221.compute-1.amazonaws.com]

TASK [Install clickhouse packages] ************************************************************************************************************************
ok: [ec2-44-209-218-221.compute-1.amazonaws.com]

TASK [Create database] ************************************************************************************************************************************
skipping: [ec2-44-209-218-221.compute-1.amazonaws.com]

PLAY RECAP ************************************************************************************************************************************************
ec2-44-209-218-221.compute-1.amazonaws.com : ok=3    changed=0    unreachable=0    failed=0    skipped=1    rescued=1    ignored=0
 
```
vector.yml

```
PLAY [Install Vector] *************************************************************************************************************************************

TASK [Gathering Facts] ************************************************************************************************************************************
ok: [ec2-44-208-98-137.compute-1.amazonaws.com]

TASK [Get vector distrib] *********************************************************************************************************************************
ok: [ec2-44-208-98-137.compute-1.amazonaws.com]

TASK [Create directory /opt/vector/] **********************************************************************************************************************
ok: [ec2-44-208-98-137.compute-1.amazonaws.com]

TASK [Copy to folder] *************************************************************************************************************************************
ok: [ec2-44-208-98-137.compute-1.amazonaws.com]

TASK [Unpack] *********************************************************************************************************************************************
skipping: [ec2-44-208-98-137.compute-1.amazonaws.com]

TASK [Set environment vector] *****************************************************************************************************************************
ok: [ec2-44-208-98-137.compute-1.amazonaws.com]

PLAY RECAP ************************************************************************************************************************************************
ec2-44-208-98-137.compute-1.amazonaws.com : ok=5    changed=0    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0

```

</details>

##### 7. Запустите playbook на `prod.yml` окружении с флагом `--diff`. Убедитесь, что изменения на системе произведены.
    
<details><summary></summary>

site.yml

```
PLAY [Install Clickhouse] *********************************************************************************************************************************

TASK [Gathering Facts] ************************************************************************************************************************************
ok: [ec2-44-209-218-221.compute-1.amazonaws.com]

TASK [Get clickhouse distrib] *****************************************************************************************************************************
ok: [ec2-44-209-218-221.compute-1.amazonaws.com] => (item=clickhouse-client)
ok: [ec2-44-209-218-221.compute-1.amazonaws.com] => (item=clickhouse-server)
failed: [ec2-44-209-218-221.compute-1.amazonaws.com] (item=clickhouse-common-static) => {"ansible_loop_var": "item", "changed": false, "dest": "./clickhouse-common-static-22.3.3.44.rpm", "elapsed": 0, "gid": 1000, "group": "ec2-user", "item": "clickhouse-common-static", "mode": "0664", "msg": "Request failed", "owner": "ec2-user", "response": "HTTP Error 404: Not Found", "secontext": "unconfined_u:object_r:user_home_t:s0", "size": 246310036, "state": "file", "status_code": 404, "uid": 1000, "url": "https://packages.clickhouse.com/rpm/stable/clickhouse-common-static-22.3.3.44.noarch.rpm"}

TASK [Get clickhouse common static] ***********************************************************************************************************************
ok: [ec2-44-209-218-221.compute-1.amazonaws.com]

TASK [Install clickhouse packages] ************************************************************************************************************************
ok: [ec2-44-209-218-221.compute-1.amazonaws.com]

TASK [Create database] ************************************************************************************************************************************
changed: [ec2-44-209-218-221.compute-1.amazonaws.com]

PLAY RECAP ************************************************************************************************************************************************
ec2-44-209-218-221.compute-1.amazonaws.com : ok=4    changed=1    unreachable=0    failed=0    skipped=0    rescued=1    ignored=0

```

vector.yml

```
PLAY [Install Vector] *************************************************************************************************************************************

TASK [Gathering Facts] ************************************************************************************************************************************
ok: [ec2-44-208-98-137.compute-1.amazonaws.com]

TASK [Get vector distrib] *********************************************************************************************************************************
ok: [ec2-44-208-98-137.compute-1.amazonaws.com]

TASK [Create directory /opt/vector/] **********************************************************************************************************************
ok: [ec2-44-208-98-137.compute-1.amazonaws.com]

TASK [Copy to folder] *************************************************************************************************************************************
ok: [ec2-44-208-98-137.compute-1.amazonaws.com]

TASK [Unpack] *********************************************************************************************************************************************
ok: [ec2-44-208-98-137.compute-1.amazonaws.com]

TASK [Set environment vector] *****************************************************************************************************************************
--- before: /etc/profile.d/vector.sh
+++ after: /root/.ansible/tmp/ansible-local-25735m6ok_nz3/tmpl75owzm3/vector.sh.j2
@@ -1,4 +1,4 @@
 #!/usr/bin/env bash

 export VECTOR_HOME=/opt/vector
-export PATH=$PATH:$VECTOR_HOME
\ No newline at end of file
+export PATH=$PATH:$VECTOR_HOME/bin
\ No newline at end of file

changed: [ec2-44-208-98-137.compute-1.amazonaws.com]

```

</details>

##### 8. Повторно запустите playbook с флагом `--diff` и убедитесь, что playbook идемпотентен.
    
<details><summary></summary>

site.yml

```
 PLAY [Install Clickhouse] *********************************************************************************************************************************

TASK [Gathering Facts] ************************************************************************************************************************************
ok: [ec2-44-209-218-221.compute-1.amazonaws.com]

TASK [Get clickhouse distrib] *****************************************************************************************************************************
ok: [ec2-44-209-218-221.compute-1.amazonaws.com] => (item=clickhouse-client)
ok: [ec2-44-209-218-221.compute-1.amazonaws.com] => (item=clickhouse-server)
failed: [ec2-44-209-218-221.compute-1.amazonaws.com] (item=clickhouse-common-static) => {"ansible_loop_var": "item", "changed": false, "dest": "./clickhouse-common-static-22.3.3.44.rpm", "elapsed": 0, "gid": 1000, "group": "ec2-user", "item": "clickhouse-common-static", "mode": "0664", "msg": "Request failed", "owner": "ec2-user", "response": "HTTP Error 404: Not Found", "secontext": "unconfined_u:object_r:user_home_t:s0", "size": 246310036, "state": "file", "status_code": 404, "uid": 1000, "url": "https://packages.clickhouse.com/rpm/stable/clickhouse-common-static-22.3.3.44.noarch.rpm"}

TASK [Get clickhouse common static] ***********************************************************************************************************************
ok: [ec2-44-209-218-221.compute-1.amazonaws.com]

TASK [Install clickhouse packages] ************************************************************************************************************************
ok: [ec2-44-209-218-221.compute-1.amazonaws.com]

TASK [Create database] ************************************************************************************************************************************
changed: [ec2-44-209-218-221.compute-1.amazonaws.com]

PLAY RECAP ************************************************************************************************************************************************
ec2-44-209-218-221.compute-1.amazonaws.com : ok=4    changed=1    unreachable=0    failed=0    skipped=0    rescued=1    ignored=0

```

vector.yml

```
PLAY [Install Vector] *************************************************************************************************************************************

TASK [Gathering Facts] ************************************************************************************************************************************
ok: [ec2-44-208-98-137.compute-1.amazonaws.com]

TASK [Get vector distrib] *********************************************************************************************************************************
ok: [ec2-44-208-98-137.compute-1.amazonaws.com]

TASK [Create directory /opt/vector/] **********************************************************************************************************************
ok: [ec2-44-208-98-137.compute-1.amazonaws.com]

TASK [Copy to folder] *************************************************************************************************************************************
ok: [ec2-44-208-98-137.compute-1.amazonaws.com]

TASK [Unpack] *********************************************************************************************************************************************
ok: [ec2-44-208-98-137.compute-1.amazonaws.com]

TASK [Set environment vector] *****************************************************************************************************************************
ok: [ec2-44-208-98-137.compute-1.amazonaws.com]

PLAY RECAP ************************************************************************************************************************************************
ec2-44-208-98-137.compute-1.amazonaws.com : ok=6    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

```
</details>

##### 9. Подготовьте README.md файл по своему playbook. В нём должно быть описано: что делает playbook, какие у него есть параметры и теги.

<details><summary></summary>
    
[Ссылка на README.md](https://github.com/flibook/devops-netology/tree/main/08-ansible-02/playbook#readme)

</details>

##### 10. Готовый playbook выложите в свой репозиторий, поставьте тег 08-ansible-02-playbook на фиксирующий коммит, в ответ предоставьте ссылку на него.
     
<details><summary></summary>

[Ссылка на репозиторий](https://github.com/flibook/devops-netology/tree/main/08-ansible-02/playbook)

</details>

