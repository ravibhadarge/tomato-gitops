
resource "aws_instance" "bastion" {
  ami                         = data.aws_ssm_parameter.al2023.value
  instance_type               = "c7i-flex.large"
  key_name                    = var.key_name
  subnet_id                   = module.vpc.public_subnets[0]
  associate_public_ip_address = true
  user_data                   = file("${path.module}/install-devops-tools.sh")
  vpc_security_group_ids      = [aws_security_group.bastion.id]


  tags = {
    Name = "tomato-bastion"
  }
}
