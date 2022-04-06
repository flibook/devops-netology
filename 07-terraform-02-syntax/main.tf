provider "aws" {
    region = "us-east-1"
}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

resource "aws_instance" "prometheus" {
    ami = "ami-04505e74c0741db8d"
    instance_type = "t2.large"
    subnet_id = "subnet-e9422eb4"
user_data = <<-EOF
            #! /bin/bash
            sudo apt update
            sudo apt install -y mc htop
EOF

ebs_block_device {
    device_name = "/dev/xvdb"
    volume_type = "gp3"
    volume_size = 100
}

root_block_device {
    volume_size = 30
    volume_type = "gp3"
    encrypted   = true
}
}
