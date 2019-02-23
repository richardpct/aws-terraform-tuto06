output "vpc_id" {
  value = "${module.base.vpc_id}"
}

output "subnet_public_id" {
  value = "${module.base.subnet_public_id}"
}

output "subnet_private_id" {
  value = "${module.base.subnet_private_id}"
}

output "sg_bastion_id" {
  value = "${module.base.sg_bastion_id}"
}

output "sg_database_id" {
  value = "${module.base.sg_database_id}"
}

output "sg_webserver_id" {
  value = "${module.base.sg_webserver_id}"
}

output "aws_eip_bastion_id" {
  value = "${module.base.aws_eip_bastion_id}"
}

output "aws_eip_web_id" {
  value = "${module.base.aws_eip_web_id}"
}

output "iam_instance_profile_name" {
  value = "${module.base.iam_instance_profile_name}"
}

output "ssh_key" {
  value = "${module.base.ssh_key}"
}
