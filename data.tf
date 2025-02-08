#getting subnet for eks cluster
data "aws_subnets" "eks" {
  filter {
    name   = "tag:app_name"
    values = [var.app_name]
  }
}

data "aws_subnets" "eks_node" {
  filter {
    name   = "tag:type"
    values = ["private"]
  }
}

data "aws_subnets" "public_subnets" {
  filter {
    name   = "tag:type"
    values = ["public"]
  }
}