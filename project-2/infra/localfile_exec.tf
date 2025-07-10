resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/inventory-template.yaml", {
    server_1 = aws_instance.app_instance[0].public_ip
    server_2 = aws_instance.app_instance[1].public_ip

    pvt_server_1 = aws_instance.app_instance[0].private_ip
    pvt_server_2 = aws_instance.app_instance[1].private_ip
  })
  filename   = "${path.module}/../ansible/inventory/hosts.yaml"
  depends_on = [aws_instance.app_instance]
}