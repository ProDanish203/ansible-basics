resource "aws_key_pair" "ssh_key" {
  key_name   = var.key_name
  public_key = file(var.ssh_public_key_path)

  tags = {
    Name = "${var.app_name}-${var.environment}-key"
  }
}

resource "aws_instance" "app_instance" {
  ami           = var.ami
  instance_type = var.instance_type

  key_name = aws_key_pair.ssh_key.id

  # Add security group
  vpc_security_group_ids = [aws_security_group.app_sg.id]
  subnet_id              = aws_subnet.public_subnet.id

  root_block_device {
    volume_size = 10
  }

  user_data = <<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y python3 python3-pip
    pip3 install ansible
  EOF

  tags = {
    Name = "${var.app_name}-${var.environment}-instance"
  }
}
