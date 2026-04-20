module "bastion" {
  source                   = "../../../modules/bastion"
  aws_profile              = var.aws_profile
  region                   = var.region
  env                      = "dev"
  base_remote_state_bucket = var.bucket
  base_remote_state_key    = var.key_base
  instance_type            = "t2.micro"
}
