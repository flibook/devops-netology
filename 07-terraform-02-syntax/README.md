## Домашнее задание к занятию "7.2. Облачные провайдеры и синтаксис Terraform."
Зачастую разбираться в новых инструментах гораздо интересней понимая то, как они работают изнутри. Поэтому в рамках первого необязательного задания предлагается завести свою учетную запись в AWS (Amazon Web Services) или Yandex.Cloud. Идеально будет познакомится с обоими облаками, потому что они отличаются.

#### Задача 1 (вариант с AWS). Регистрация в aws и знакомство с основами (необязательно, но крайне желательно).
Остальные задания можно будет выполнять и без этого аккаунта, но с ним можно будет увидеть полный цикл процессов.

AWS предоставляет достаточно много бесплатных ресурсов в первых год после регистрации, подробно описано здесь.

    Создайте аккаут aws.
    Установите c aws-cli https://aws.amazon.com/cli/.
    Выполните первичную настройку aws-sli https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html.
    Создайте IAM политику для терраформа c правами
    AmazonEC2FullAccess
    AmazonS3FullAccess
    AmazonDynamoDBFullAccess
    AmazonRDSFullAccess
    CloudWatchFullAccess
    IAMFullAccess
    Добавьте переменные окружения
    export AWS_ACCESS_KEY_ID=(your access key id)
    export AWS_SECRET_ACCESS_KEY=(your secret access key)

Создайте, остановите и удалите ec2 инстанс (любой с пометкой free tier) через веб интерфейс.
В виде результата задания приложите вывод команды aws configure list.

    aws> configure list
          Name                    Value             Type    Location
          ----                    -----             ----    --------
       profile                <not set>             None    None
    access_key     ****************G25U              env
    secret_key     ****************xTfq              env
        region                <not set>             None    None

#### Задача 1 (Вариант с Yandex.Cloud). Регистрация в aws и знакомство с основами (необязательно, но крайне желательно).

Подробная инструкция на русском языке содержится здесь.
Обратите внимание на период бесплатного использования после регистрации аккаунта.
Используйте раздел "Подготовьте облако к работе" для регистрации аккаунта. Далее раздел "Настройте провайдер" для подготовки базового терраформ конфига.
Воспользуйтесь инструкцией на сайте терраформа, что бы не указывать авторизационный токен в коде, а терраформ провайдер брал его из переменных окружений.

#### Задача 2. Созданием aws ec2 или yandex_compute_instance через терраформ.

В каталоге terraform вашего основного репозитория, который был создан в начале курсе, создайте файл main.tf и versions.tf.

Зарегистрируйте провайдер для aws. В файл main.tf добавьте блок provider, а в versions.tf блок terraform с вложенным блоком required_providers. Укажите любой выбранный вами регион внутри блока provider.
либо для yandex.cloud. Подробную инструкцию можно найти здесь.
Внимание! В гит репозиторий нельзя пушить ваши личные ключи доступа к аккаунту. Поэтому в предыдущем задании мы указывали их в виде переменных окружения.
В файле main.tf воспользуйтесь блоком data "aws_ami для поиска ami образа последнего Ubuntu.
В файле main.tf создайте рессурс либо ec2 instance. Постарайтесь указать как можно больше параметров для его определения. Минимальный набор параметров указан в первом блоке Example Usage, но желательно, указать большее количество параметров.
либо yandex_compute_image.

Также в случае использования aws:
Добавьте data-блоки aws_caller_identity и aws_region.
В файл outputs.tf поместить блоки output с данными об используемых в данный момент:
AWS account ID,
AWS user ID,
AWS регион, который используется в данный момент,
Приватный IP ec2 инстансы,
Идентификатор подсети в которой создан инстанс.

Если вы выполнили первый пункт, то добейтесь того, что бы команда terraform plan выполнялась без ошибок.

Вывод terraform show

```
root@ip-10-0-205-110:/opt/tf# terraform show

# aws_instance.prometheus:
resource "aws_instance" "prometheus" {
    ami                                  = "ami-04505e74c0741db8d"
    arn                                  = "arn:aws:ec2:us-east-1:477815361742:instance/i-0f08012309ad7bdff"
    associate_public_ip_address          = false
    availability_zone                    = "us-east-1c"
    cpu_core_count                       = 2
    cpu_threads_per_core                 = 1
    disable_api_termination              = false
    ebs_optimized                        = false
    get_password_data                    = false
    hibernation                          = false
    id                                   = "i-0f08012309ad7bdff"
    instance_initiated_shutdown_behavior = "stop"
    instance_state                       = "running"
    instance_type                        = "t2.large"
    ipv6_address_count                   = 0
    ipv6_addresses                       = []
    monitoring                           = false
    primary_network_interface_id         = "eni-04c0a522b050f010f"
    private_dns                          = "ip-10-0-197-62.ec2.internal"
    private_ip                           = "10.0.197.62"
    secondary_private_ips                = []
    security_groups                      = []
    source_dest_check                    = true
    subnet_id                            = "subnet-e9422eb4"
    tags_all                             = {}
    tenancy                              = "default"
    user_data                            = "c799c41d57e11a5d400d1f16c2cb11f407b3b21f"
    user_data_replace_on_change          = false
    vpc_security_group_ids               = [
        "sg-38edf65f",
    ]

    capacity_reservation_specification {
        capacity_reservation_preference = "open"
    }

    credit_specification {
        cpu_credits = "standard"
    }

    ebs_block_device {
        delete_on_termination = true
        device_name           = "/dev/xvdb"
        encrypted             = false
        iops                  = 3000
        tags                  = {}
        throughput            = 125
        volume_id             = "vol-031d7582b5fbcd6b4"
        volume_size           = 100
        volume_type           = "gp3"
    }

    enclave_options {
        enabled = false
    }

    metadata_options {
        http_endpoint               = "enabled"
        http_put_response_hop_limit = 1
        http_tokens                 = "optional"
        instance_metadata_tags      = "disabled"
    }

    root_block_device {
        delete_on_termination = true
        device_name           = "/dev/sda1"
        encrypted             = true
        iops                  = 3000
        kms_key_id            = "arn:aws:kms:us-east-1:477815361742:key/d8ce9a6b-d5d7-42f3-82cd-0eca5c552e4a"
        throughput            = 125
        volume_id             = "vol-04943a21b9fdeb5a6"
        volume_size           = 30
        volume_type           = "gp3"
    }
}
```


Ответ на вопрос: при помощи какого инструмента (из разобранных на прошлом занятии) можно создать свой образ ami?
    
    CloudFormation    

Ссылку на репозиторий с исходной конфигурацией терраформа.

    https://github.com/flibook/devops-netology/tree/main/terraform