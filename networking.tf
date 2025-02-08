# Provisioning VPC
module "vpc" {
  source               = "/mnt/g/Code/Assignment/infra/max-weather-tf-modules/vpc"
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  vpc_name             = var.app_name
  tags = {
      app_name = var.app_name
  }
}

# Provisioning subnets
module "public_subnet_1a" {
  source                = "/mnt/g/Code/Assignment/infra/max-weather-tf-modules/subnet"
  vpc_id                = module.vpc.vpc_id
  cidr_block            = "10.0.1.0/24"
  availability_zone     = "ap-southeast-1a"
  map_public_ip_on_launch = true
  subnet_name           = "${var.app_name}-public-1a"
  tags = {
      app_name = var.app_name
      type     = "public"
  }
}

module "public_subnet_1b" {
  source                = "/mnt/g/Code/Assignment/infra/max-weather-tf-modules/subnet"
  vpc_id                = module.vpc.vpc_id
  cidr_block            = "10.0.2.0/24"
  availability_zone     = "ap-southeast-1b"
  map_public_ip_on_launch = true
  subnet_name           = "${var.app_name}-public-1b"
  tags = {
      app_name = var.app_name
      type     = "public"
  }
}

module "private_subnet_1a" {
  source                = "/mnt/g/Code/Assignment/infra/max-weather-tf-modules/subnet"
  vpc_id                = module.vpc.vpc_id
  cidr_block            = "10.0.3.0/24"
  availability_zone     = "ap-southeast-1a"
  map_public_ip_on_launch = false
  subnet_name           = "${var.app_name}-private-1a"
  tags = {
      app_name = var.app_name
      type     = "private"
  }
}

module "private_subnet_1b" {
  source                = "/mnt/g/Code/Assignment/infra/max-weather-tf-modules/subnet"
  vpc_id                = module.vpc.vpc_id
  cidr_block            = "10.0.4.0/24"
  availability_zone     = "ap-southeast-1b"
  map_public_ip_on_launch = false
  subnet_name           = "${var.app_name}-private-1b"
  tags = {
      app_name = var.app_name
      type     = "private"
  }
}


#security group for cluster
module "cluster_communication" {
  source                    = "/mnt/g/Code/Assignment/infra/max-weather-tf-modules/security_group"
  security_group_name       = "cluster_communication"
  security_group_description = "Security group for cluster communication"
  vpc_id                    = module.vpc.vpc_id

  # Allow communication between the nodes within the VPC
  ingress_rules = [
    {
      from_port   = 0
      to_port     = 65535
      protocol    = "tcp"
      cidr_blocks = ["10.0.0.0/16"] # Allow all internal communication in the VPC
    },
    {
      from_port   = 10250
      to_port     = 10250
      protocol    = "tcp"
      cidr_blocks = ["10.0.0.0/16"]
    },
    {
      from_port   = 30000
      to_port     = 32767
      protocol    = "tcp"
      cidr_blocks = ["10.0.0.0/16"]
    }
  ]

  # Allow outbound traffic to anywhere (default behavior)
  egress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]

  tags = {
      app_name = var.app_name
  }
}

# Provision internet gateway
module "internet_gateway" {
  source   = "/mnt/g/Code/Assignment/infra/max-weather-tf-modules/internet-gateway"
  vpc_id   = module.vpc.vpc_id
  igw_name = "${var.app_name}-igw"

  tags = {
      app_name = var.app_name
  }
}

# Provision nat gateway
module "nat_gateway" {
  source            = "/mnt/g/Code/Assignment/infra/max-weather-tf-modules/nat-gateway"
  subnet_id         = data.aws_subnets.public_subnets.ids[0]
  nat_gateway_name  = "${var.app_name}-natgw"

  tags = {
      app_name = var.app_name
  }
}

#Route table setup

module "public_rtb" {
  source            = "/mnt/g/Code/Assignment/infra/max-weather-tf-modules/route-table"
  route_table_name  = "public_rtb"
  vpc_id           = module.vpc.vpc_id
  routes = [
    {
      destination_cidr_block = "0.0.0.0/0"
      gateway_id = module.internet_gateway.internet_gateway_id
    }
  ]
  subnet_ids = data.aws_subnets.public_subnets.ids
  tags = {
      app_name = var.app_name
  }
}

module "private_rtb" {
  source            = "/mnt/g/Code/Assignment/infra/max-weather-tf-modules/route-table"
  route_table_name  = "private_rtb"
  vpc_id           = module.vpc.vpc_id
  routes = [
    {
      destination_cidr_block = "0.0.0.0/0"
      nat_gateway_id = module.nat_gateway.nat_gateway_id
    }
  ]
  subnet_ids = data.aws_subnets.eks_node.ids
  tags = {
      app_name = var.app_name
  }
}