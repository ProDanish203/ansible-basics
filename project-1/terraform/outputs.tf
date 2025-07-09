output "instance_ip" {
  value = aws_instance.app_instance.public_ip
}

output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.app_instance.id
}

output "instance_dns" {
  description = "Public DNS name of the EC2 instance"
  value       = aws_instance.app_instance.public_dns
}

output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "subnet_id" {
  description = "ID of the public subnet"
  value       = aws_subnet.public_subnet.id
}

output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.app_sg.id
}

resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/inventory-template.yaml", {
    instance_ip = aws_instance.app_instance.public_ip
  })
  filename   = "${path.module}/../ansible/inventories/hosts.yaml"
  depends_on = [aws_instance.app_instance]
}