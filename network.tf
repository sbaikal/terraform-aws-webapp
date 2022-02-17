data "aws_availability_zones" "available" {}

# NETWORKING #
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  cidr           = var.vpc_cidr_block
  azs            = slice(data.aws_availability_zones.available.names, 0, (var.vpc_subnet_count))
  public_subnets = [for subnet in range(var.vpc_subnet_count) : cidrsubnet(var.vpc_cidr_block, 8, subnet)]

  enable_nat_gateway      = false
  enable_dns_hostnames    = var.enable_dns_hostnames
  map_public_ip_on_launch = var.map_public_ip_on_launch

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-vpc"
  })

}

# IP address form external resolver
data "extip" "check_external_ip" {
  resolver       = "https://checkip.amazonaws.com/"
  client_timeout = 500
}
# Nginx security group 
resource "aws_security_group" "nginx_sg" {
  name   = "${local.name_prefix}-nginx_sg"
  vpc_id = module.vpc.vpc_id


  # HTTP access from VPC
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SSH access 
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${data.extip.check_external_ip.ipaddress}/32"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.common_tags
}