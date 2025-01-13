variable "vpc_name" {
  description = "The name of VPC"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block of the VPC"
  type        = string
}

variable "availability_zones" {
  description = "availability zones of the VPC"
  type        = list(string)
}

variable "private_subnets" {
  description = "VPC private subnetes"
  type        = list(string)
}

variable "public_subnets" {
  description = "VPC public subnetes"
  type        = list(string)
}

variable "eks_sg_name" {
  description = "Name of ASG security group"
  type        = string
  default     = "EKS-SG"
}

variable "cluster_name" {
  type = string
}