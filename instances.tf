##################################################################################
# DATA
##################################################################################

data "aws_ssm_parameter" "ami" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

##################################################################################
# RESOURCES
##################################################################################

resource "aws_key_pair" "demo_auth" {
  key_name   = "demokey"
  public_key = file("~/.ssh/demokey.pub")
}

# INSTANCES #
resource "aws_instance" "nginx" {
  count                  = var.instance_count
  ami                    = data.aws_ssm_parameter.ami.value
  instance_type          = var.instance_type
  key_name               = aws_key_pair.demo_auth.id
  subnet_id              = module.vpc.public_subnets[count.index % length(module.vpc.public_subnets)]
  vpc_security_group_ids = [aws_security_group.nginx_sg.id]

  user_data = templatefile("${path.module}/startup_script.tpl", {


  })

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-nginx-${count.index}"
  })

}