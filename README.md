# devops-netology
the first modify
the second modify
the third modify
new line cinema


Будут проигнорированы:

1. каталоги, которые находятся внутри папки ./terraform, а также все файлы в нем
2. все файлы с расширением .tfstate, а также файлы, в названии которых, указано "any".tfstate."any"
3. crash.log
4. файлы с расширением .tfvars
5. файлы override.tf, override.tf.json, а также файлы по маске "any"_override.tf и "any"_override.tf.json
6. консольные конфигурационные файлы .terraformrc и terraform.rc