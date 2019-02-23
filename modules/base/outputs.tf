output "vpc_id" {
  value = "${aws_vpc.my_vpc.id}"
}

output "subnet_public_id" {
  value = "${aws_subnet.public.id}"
}

output "subnet_private_id" {
  value = "${aws_subnet.private.id}"
}

output "sg_bastion_id" {
  value = "${aws_security_group.bastion.id}"
}

output "sg_database_id" {
  value = "${aws_security_group.database.id}"
}

output "sg_webserver_id" {
  value = "${aws_security_group.webserver.id}"
}

output "aws_eip_bastion_id" {
  value = "${aws_eip.bastion.id}"
}

output "aws_eip_web_id" {
  value = "${aws_eip.web.id}"
}

output "iam_instance_profile_name" {
  value = "${aws_iam_instance_profile.profile.name}"
}

output "ssh_key" {
  value = "${aws_key_pair.deployer.key_name}"
}