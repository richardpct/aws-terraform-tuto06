output "vpc_id" {
  value = aws_vpc.my_vpc.id
}

output "subnet_public_bastion_id" {
  value = aws_subnet.public_bastion[*].id
}

output "subnet_public_web_id" {
  value = aws_subnet.public_web[*].id
}

output "subnet_private_redis_id" {
  value = aws_subnet.private_redis[*].id
}

output "sg_bastion_id" {
  value = aws_security_group.bastion.id
}

output "sg_database_id" {
  value = aws_security_group.database.id
}

output "sg_web_id" {
  value = aws_security_group.web.id
}

output "aws_eip_bastion_id" {
  value = aws_eip.bastion.id
}

output "aws_eip_web_id" {
  value = aws_eip.web.id
}

output "iam_instance_profile_name" {
  value = aws_iam_instance_profile.profile.name
}

output "ssh_key" {
  value = aws_key_pair.deployer.key_name
}

output "bastion_public_ip" {
  value = aws_eip.bastion.public_ip
}

output "web_public_ip" {
  value = aws_eip.web.public_ip
}
