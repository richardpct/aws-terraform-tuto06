variable "aws_profile" {
  type        = string
  description = "aws profile"
}

variable "region" {
  type        = string
  description = "region"
}

variable "key_network" {
  type        = string
  description = "key network"
}

variable "bucket" {
  type        = string
  description = "bucket"
}

variable "my_ip_address" {
  type        = string
  description = "cidr block allowed to connect via ssh"
}

variable "ssh_public_key" {
  description = "ssh public key"
}
