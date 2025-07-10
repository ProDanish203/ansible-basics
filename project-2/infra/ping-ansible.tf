resource "null_resource" "webservers" {
  provisioner "local-exec" {
    command = <<EOH
      sleep 10 && ANSIBLE_HOST_KEY_CHECKING=False ansible public_servers -i inventory-template.yaml -m ping
    EOH
  }
  depends_on = [local_file.ansible_inventory]
}
