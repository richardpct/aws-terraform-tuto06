terraform {
  backend "s3" {}
}

module "database" {
  source = "../../../modules/database"

  region                   = "eu-west-3"
  env                      = "dev"
  base_remote_state_bucket = var.bucket
  base_remote_state_key    = var.dev_base_key
  instance_type            = "t2.micro"
  image_id                 = "ami-0d6aecf0f0425f42a"  #Ubuntu 20.04 LTS
  database_pass            = var.dev_database_pass
}
