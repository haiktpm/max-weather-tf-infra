
#Create role & policy for nodegroup

module "iam_policy" {
  source              = "/mnt/g/Code/Assignment/infra/max-weather-tf-modules/iam_policy"
  policy_name         = "MaxWeatherPolicy"
  policy_description  = "A custom policy for MaxWeather app"
  policy_document     = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:CompleteLayerUpload",
        "ecr:GetDownloadUrlForLayer",
        "ecr:InitiateLayerUpload",
        "ecr:PutImage",
        "ecr:UploadLayerPart"
      ],
      "Resource": "*"
    }
  ]
}
EOF
  tags = {
      app_name = var.app_name
  }
}

module "iam_role" {
  source               = "/mnt/g/Code/Assignment/infra/max-weather-tf-modules/iam_role"
  role_name            = "maxweather-role"
  assume_role_policy   = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Action": "sts:AssumeRole",
    "Principal": {
      "Service": "ec2.amazonaws.com"
    }
  }]
}
EOF
  attached_policies    = [module.iam_policy.policy_arn, "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy", "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy", "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly", "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"]
  tags = {
      app_name = var.app_name
  }
}

module "iam_role_csi" {
  source               = "/mnt/g/Code/Assignment/infra/max-weather-tf-modules/iam_role"
  role_name            = "maxweather-csi-role"
  assume_role_policy   = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Federated": "arn:aws:iam::682033501590:oidc-provider/oidc.eks.ap-southeast-1.amazonaws.com/id/CA2FACC3606C41DF2E499E9ED26FC2F4"
            },
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Condition": {
                "StringEquals": {
                    "oidc.eks.ap-southeast-1.amazonaws.com/id/CA2FACC3606C41DF2E499E9ED26FC2F4:aud": "sts.amazonaws.com",
                    "oidc.eks.ap-southeast-1.amazonaws.com/id/CA2FACC3606C41DF2E499E9ED26FC2F4:sub": "system:serviceaccount:kube-system:ebs-csi-controller-sa"
                }
            }
        }
    ]
}
EOF
  attached_policies    = ["arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy", "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"]
  tags = {
      app_name = var.app_name
  }
}
