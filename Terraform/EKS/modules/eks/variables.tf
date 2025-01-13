variable "cluster_name" {
  description = "Name of EKS cluster"
  type        = string
}

variable "eks_sg_id" {
  type = string
}
variable "cluster_version" {
  description = "version of EKS cluster"
  type        = string
}

variable "node_group_name" {
  type = string
}

variable "public_subnets_ids" {
  type = list(string)
}

variable "private_subnets_ids" {
  type = list(string)
}

variable "ssh_key_name" {
  type = string
}