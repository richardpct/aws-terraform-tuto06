## Purpose
This tutorial takes up the previous one
[aws-with-terraform-tutorial-05](https://richardpct.github.io/post/2021/03/27/aws-with-terraform-tutorial-05/)
by leveraging the high availability feature provided by AWS.
Imagine that your bastion or your webserver are crashing for any reasons, they
will be automatically recreated using autoscaling group, hence your service
will experience a short downtime.<br />
For keeping the same EIP (Elastic IP) when a new instance will replace the old
one, this instance requires to perform an aws command that associates the EIP
with itself.<br />
In addition, I no longer use a Redis server using an EC2, instead I will use 
the Elastic Cache service provided by AWS for simplifying the architecture.

The following figure depicts the infrastructure you will build:

<img src="https://raw.githubusercontent.com/richardpct/images/master/aws-tuto-06/image01.png">

The source code can be found [here](https://github.com/richardpct/aws-terraform-tuto06).

## Configuring the network

#### envs/dev/01-network/main.tf

The following code shows how the subnets are defined:

```
module "network" {
  source                  = "../../../modules/network"
  aws_profile             = var.aws_profile
  region                  = var.region
  env                     = "dev"
  vpc_cidr_block          = "10.0.0.0/16"
  subnet_public_bastion = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24"]
  subnet_public_web     = ["10.0.3.0/24", "10.0.4.0/24", "10.0.5.0/24"]
  subnet_private_redis  = ["10.0.6.0/24", "10.0.7.0/24", "10.0.8.0/24"]
  cidr_allowed_ssh        = var.my_ip_address
  ssh_public_key          = var.ssh_public_key
}
```

As you can see later, each service requires to have 3 subnets, each one are
located in a Availability Zone.

#### modules/network/main.tf

I define 3 public subnets in which the bastion can be hosted, and each subnet
is located in distinct availability zone:

```
resource "aws_subnet" "public_bastion" {
  count             = length(var.subnet_public_bastion)
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = var.subnet_public_bastion[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "subnet_public_bastion-${var.env}"
  }
}
```

I used count for a concise syntax instead of repeating the aws_subnet block
3 times.</br />
The public web subnets and the private redis subnets are defined by the same way.

## Creating an IAM role

#### modules/base/iam.tf

When the state of a server is changing to off for any reason, a new public IP
is associated to the server which will replace it. When using a bastion or a
web server, it is handy to keep the same public IP, to accomplish it, the EC2
requires the right to associate the existing EIP by declaring the following IAM
role:

```
resource "aws_iam_role" "role" {
  name = "my_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "policy" {
  name = "my_policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:AssociateAddress"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "attach" {
  role       = aws_iam_role.role.name
  policy_arn = aws_iam_policy.policy.arn
}

resource "aws_iam_instance_profile" "profile" {
  name = "my_profile"
  role = aws_iam_role.role.name
}
```

## Creating the bastion

#### modules/bastion/main.tf

The following code intends to create a bastion by using autoscaling group to
ensure to have one server up and running, if it fails or is deleted for any
reason, a new one is recreated:

```
resource "aws_launch_template" "bastion" {
  name          = "bastion-${var.env}"
  image_id      = data.aws_ami.amazonlinux.id
  user_data     = base64encode(templatefile("${path.module}/user-data.sh",
                                            { eip_bastion_id = data.terraform_remote_state.network.outputs.aws_eip_bastion_id,
                                              region         = var.region }))
  instance_type = var.instance_type
  key_name      = data.terraform_remote_state.network.outputs.ssh_key

  network_interfaces {
    security_groups             = [data.terraform_remote_state.network.outputs.sg_bastion_id]
    associate_public_ip_address = true
  }

  iam_instance_profile {
    name = data.terraform_remote_state.network.outputs.iam_instance_profile_name
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "bastion" {
  name                 = "asg_bastion-${var.env}"
  vpc_zone_identifier  = data.terraform_remote_state.network.outputs.subnet_public_bastion_id[*]
  min_size             = 1
  max_size             = 1

  launch_template {
    id = aws_launch_template.bastion.id
  }

  tag {
    key                 = "Name"
    value               = "bastion-${var.env}"
    propagate_at_launch = true
  }
}
```

As you can see, in the last resource I use 3 subnets in distinct AZ, if a AZ is
experiencing some issues, the server is recreated in an other AZ.

#### modules/bastion/user-data.sh

The last line intends to associate an existing EIP in order to keep the same
public IP whenever the instance is recreated:

```
#!/usr/bin/env bash

exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
sudo yum -y update
sudo yum -y upgrade
TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
INSTANCE_ID="$(curl -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/instance-id)"
aws --region ${region} ec2 associate-address --instance-id $INSTANCE_ID --allocation-id ${eip_bastion_id}
```

## Creating the web server

The build of the web server is similar to the bastion server.

## Creating the Redis server

Let's create a Redis server for storing the requests count using the Elastic
Cache service provided by AWS:

```
resource "aws_elasticache_subnet_group" "redis" {
  name       = "subnet-redis-${var.env}"
  subnet_ids = data.terraform_remote_state.network.outputs.subnet_private_redis_id[*]
}

resource "aws_elasticache_cluster" "redis" {
  cluster_id           = "cluster-redis"
  engine               = "redis"
  node_type            = var.instance_type
  num_cache_nodes      = 1
  parameter_group_name = "default.redis6.x"
  engine_version       = "6.x"
  port                 = 6379
  subnet_group_name    = aws_elasticache_subnet_group.redis.name
  security_group_ids   = [data.terraform_remote_state.network.outputs.sg_database_id]
}
```

## Deploying the infrastructure

Create a file in ~/terraform/aws-terraform-tuto06/terraform_vars_dev_secrets
containing the following:

```
export TF_VAR_aws_profile="dev"
export TF_VAR_region="eu-west-3"
export TF_VAR_bucket="XXXX-tofu-state"
export TF_VAR_key_network="tuto-06/dev/network/terraform.tfstate"
export TF_VAR_key_bastion="tuto-06/dev/bastion/terraform.tfstate"
export TF_VAR_key_database="tuto-06/dev/database/terraform.tfstate"
export TF_VAR_key_web="tuto-06/dev/web/terraform.tfstate"
export TF_VAR_ssh_public_key="ssh-ed25519 XXXX"
MY_IP=$(curl -s ifconfig.co/)
export TF_VAR_my_ip_address="$MY_IP/32"
```

Building:

    $ cd envs/dev/01-network
    $ make apply
    $ cd ../02-bastion
    $ make apply
    $ cd ../03-database
    $ make apply
    $ cd ../04-webserver
    $ make apply

## Testing your infrastructure

When your infrastructure is built, get the EIP of your web server by performing
the following command:

    $ aws --profile dev ec2 describe-addresses --filters "Name=tag:Name,Values=eip_web-dev" \
      --query 'Addresses[*].PublicIp' \
      --output text

Perform the following command until the output matches the EIP of your web
server:

    $ aws --profile dev ec2 describe-instances --filters "Name=tag-value,Values=web-dev" \
      --query 'Reservations[*].Instances[*].NetworkInterfaces[*].PrivateIpAddresses[*].Association.PublicIp' \
      --output text

Then issue the following command several times for increasing the counter by using
the EIP:

    $ curl http://ip_public_webserver:8000/cgi-bin/hello.py

It should return the count of requests you have performed.

## Testing the High Availability

Get the instance ID of your web server:

    $ aws --profile dev ec2 describe-instances --filters "Name=tag-value,Values=web-dev" "Name=instance-state-name,Values=running" \
      --query "Reservations[*].Instances[*].InstanceId" \
      --output text

Terminate your instance using its ID:

    $ aws --profile dev ec2 terminate-instances --instance-ids id-instance_web_server

Then wait until the following command returns the ID instance of your new web
server, which means the instance is up:

    $ aws --profile dev ec2 describe-instances --filters "Name=tag-value,Values=web-dev" "Name=instance-state-name,Values=running" \
      --query "Reservations[*].Instances[*].InstanceId" \
      --output text

Check again the website by using the same web EIP (which never change):

    $ curl http://ip_public_webserver:8000/cgi-bin/hello.py

## Destroying your infrastructure

After finishing your test, destroy your infrastructure:

    $ cd envs/dev/04-web
    $ make destroy
    $ cd ../03-database
    $ make destroy
    $ cd ../02-bastion
    $ make destroy
    $ cd ../01-network
    $ make destroy

## Summary

In this tutorial you have learned how to use the auto scaling group in order
to ensure one server is up and running, but the downside of this way is
whenever your server is recreated, your service is experiencing a short
downtime.<br />
To adress this issue, in the next tutorial I will show you how to improve the
method using a load balancer and multiple clones of webservers.
