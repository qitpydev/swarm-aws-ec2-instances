module "swarm_vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.app_name
  cidr = var.vpc_cidr

  azs             = data.aws_availability_zones.available.names
  private_subnets = cidrsubnets(cidrsubnets(var.vpc_cidr, 4, 4)[0], 2, 2, 1)
  public_subnets  = cidrsubnets(cidrsubnets(var.vpc_cidr, 4, 4)[1], 2, 2, 1)

  enable_nat_gateway = false
  enable_vpn_gateway = true

  tags = var.tags
}