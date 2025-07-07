resource "aws_key_pair" "ssh_key" {
  key_name   = "tf-key"
  public_key = file("~/.ssh/tfkey.pub")

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

  tags = {
    Name = "${var.app_name}-${var.environment}-instance"
  }
}
