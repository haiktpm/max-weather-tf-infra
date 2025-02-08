# Provisioning eks
module "eks" {
  source       = "/mnt/g/Code/Assignment/infra/max-weather-tf-modules/eks"
  cluster_name = var.app_name
  subnet_ids            = data.aws_subnets.eks.ids
  security_group_ids    = [module.cluster_communication.security_group_id]
  enable_public_access = true
  enable_private_access = true
  public_access_cidrs  = ["0.0.0.0/0"] 
  nodegroup_subnet_ids  = data.aws_subnets.eks_node.ids
  node_role_arn         = module.iam_role.role_arn
  instance_types        = ["t3.medium"]
  desired_capacity      = 2
  max_capacity          = 4
  min_capacity          = 2
  eks_addons = [
    { name = "vpc-cni" },
    { name = "coredns", service_account_role_arn = module.iam_role.role_arn },
    { name = "kube-proxy", service_account_role_arn = module.iam_role.role_arn },
    { name = "aws-ebs-csi-driver", service_account_role_arn = module.iam_role_csi.role_arn }
  ]
  tags = {
      app_name = var.app_name
  }
}
