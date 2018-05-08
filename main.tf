provider "aws" {
  version = "~> 1.17"
  region  = "${var.region}"
}

module "vpc" {
  source = "./tf-vpc"

  name = "nginx"
  cidr = "10.0.0.0/20"

  azs                  = "${var.azs}"
  public_subnets       = "${var.public_subnets}"
  public_subnets_names = "${var.public_subnets_names}"

  tags = {
    Service = "nginx"
  }
}

module "nginx-asg" {
  source         = "./tf-asg-nginx/"

  region         = "${var.region}"
  vpc_id         = "${module.vpc.vpc_id}"
  public_subnets = "${module.vpc.public_subnets}"
  key_name       = "${var.key_name}"
  nginx_count    = "${var.nginx_count}"
  instance_type  = "${var.instance_type}"
  s3_bucket_name = "${var.s3_bucket_name}"
}