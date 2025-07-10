resource "null_resource" "webservers" {
  provisioner "local-exec" {
    command = <<EOH
      sleep 10
      ansible public_servers -i inventory-template.yaml -m ping
    EOH
  }
  depends_on = [local_file.ansible_inventory]
}
