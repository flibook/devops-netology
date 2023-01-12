output "instance_ip_addr" {
    value       = aws_instance.prometheus.private_ip 
    description = "The private IP address of the main server instance."
}

output "instance_region" {
    value       = data.aws_region.current.name
    description = "AWS Region"
}

output "instance_subnet" {
    value       = aws_subnet.my_subnet.id
    description = "AWS subnet id"
}

output "account_id" {
    value = data.aws_caller_identity.current.account_id
    description = "AWS account id"
}

output "user_id" {
    value = data.aws_caller_identity.current.user_id
    description = "AWS user id"
}