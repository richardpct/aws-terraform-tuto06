locals {
  ssh_port       = 22
  http_port      = 80
  https_port     = 443
  redis_port     = 6379
  webserver_port = 8000
  anywhere       = ["0.0.0.0/0"]
}

variable "region" {
  description = "region"
}

variable "env" {
  description = "environment"
}

variable "vpc_cidr_block" {
  description = "vpc cidr block"
}

variable "subnet_public_bastion_a" {
  description = "public subnet bastion A"
}

variable "subnet_public_bastion_b" {
  description = "public subnet bastion B"
}

variable "subnet_public_web_a" {
  description = "public subnet web A"
}

variable "subnet_public_web_b" {
  description = "public subnet web B"
}

variable "subnet_private_redis_a" {
  description = "private subnet redis A"
}

variable "subnet_private_redis_b" {
  description = "private subnet redis B"
}

variable "cidr_allowed_ssh" {
  description = "cidr block allowed to connect via SSH"
}

variable "ssh_public_key" {
  description = "ssh public key"
}
