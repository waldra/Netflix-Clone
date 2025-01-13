# VPC
module "vpc" {
  source             = "./modules/vpc"
  vpc_name           = "EKS-VPC"
  vpc_cidr           = "10.0.0.0/16"
  private_subnets    = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets     = ["10.0.3.0/24", "10.0.4.0/24"]
  availability_zones = ["eu-west-1a", "eu-west-1b"]
  cluster_name = var.cluster_name
}

# EKS
module "eks" {
  source              = "./modules/eks"
  cluster_name        = var.cluster_name
  cluster_version     = var.cluster_version
  node_group_name     = var.node_group_name
  ssh_key_name        = var.key_name
  eks_sg_id           = module.vpc.eks_sg_id
  public_subnets_ids  = module.vpc.public_subnets_ids
  private_subnets_ids = module.vpc.private_subnets_ids
}

