variable "cluster_name" {
    default = "eks-dev"
    type = string
}

variable "cluster_version" {
    default = "1.30"
    type = string
}

variable "node_group_name" {
  default = "eks-dev-nodegroup"
  type = string
}

variable "key_name" {
  default = "DevOps"
  type = string
}