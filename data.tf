provider "aws" {
  region = var.aws_region
}

# Data source to get the EKS cluster details
data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster_auth" {
  name = module.eks.cluster_id
}
