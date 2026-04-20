output "vpc_id" {
  value = module.network.vpc_id
}

output "subnet_public_bastion_a_id" {
  value = module.network.subnet_public_bastion_a_id
}

output "subnet_public_bastion_b_id" {
  value = module.network.subnet_public_bastion_b_id
}

output "subnet_public_web_a_id" {
  value = module.network.subnet_public_web_a_id
}

output "subnet_public_web_b_id" {
  value = module.network.subnet_public_web_b_id
}

output "subnet_private_redis_a_id" {
  value = module.network.subnet_private_redis_a_id
}

output "subnet_private_redis_b_id" {
  value = module.network.subnet_private_redis_b_id
}

output "sg_bastion_id" {
  value = module.network.sg_bastion_id
}

output "sg_database_id" {
  value = module.network.sg_database_id
}

output "sg_webserver_id" {
  value = module.network.sg_webserver_id
}

output "aws_eip_bastion_id" {
  value = module.network.aws_eip_bastion_id
}

output "aws_eip_web_id" {
  value = module.network.aws_eip_web_id
}

output "iam_instance_profile_name" {
  value = module.network.iam_instance_profile_name
}

output "ssh_key" {
  value = module.network.ssh_key
}
