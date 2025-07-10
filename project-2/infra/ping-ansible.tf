resource "null_resource" "webservers" {
  provisioner "local-exec" {
    command = <<EOH
      sleep 10
      ansible -i inventory-template.yaml pvt -m ping
    EOH
  }
  depends_on = [local_file.ansible_inventory]
}
