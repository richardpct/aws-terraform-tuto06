data "terraform_remote_state" "network" {
  backend = "s3"

  config = {
    profile = var.aws_profile
    bucket  = var.network_remote_state_bucket
    key     = var.network_remote_state_key
    region  = var.region
  }
}

data "terraform_remote_state" "database" {
  backend = "s3"

  config = {
    profile = var.aws_profile
    bucket  = var.database_remote_state_bucket
    key     = var.database_remote_state_key
    region  = var.region
  }
}

data "aws_availability_zones" "available" {}

data "aws_ami" "amazonlinux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["al2023-ami-*-kernel-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = [137112412989] # amazon owner id
}

resource "aws_launch_template" "web" {
  name          = "web-${var.env}"
  image_id      = data.aws_ami.amazonlinux.id
  user_data     = base64encode(templatefile("${path.module}/user-data.sh",
                                            { eip_web_id    = data.terraform_remote_state.network.outputs.aws_eip_web_id,
                                              environment   = var.env,
                                              database_host = data.terraform_remote_state.database.outputs.database_arn }))
  instance_type = var.instance_type
  key_name      = data.terraform_remote_state.network.outputs.ssh_key

  network_interfaces {
    security_groups             = [data.terraform_remote_state.network.outputs.sg_web_id]
    associate_public_ip_address = true
  }

  iam_instance_profile {
    name = data.terraform_remote_state.network.outputs.iam_instance_profile_name
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "web" {
  name                 = "asg_web-${var.env}"
  vpc_zone_identifier  = data.terraform_remote_state.network.outputs.subnet_public_web_id[*]
  min_size             = 1
  max_size             = 1

  launch_template {
    id = aws_launch_template.web.id
  }

  tag {
    key                 = "Name"
    value               = "web-${var.env}"
    propagate_at_launch = true
  }
}
