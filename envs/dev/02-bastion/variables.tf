variable "aws_profile" {
  description = "aws profile"
}

variable "region" {
  description = "region"
}

variable "bucket" {
  description = "bucket where OpenTofu states are stored"
}

variable "key_network" {
  description = "key network"
}

variable "key_bastion" {
  description = "key bastion"
}
