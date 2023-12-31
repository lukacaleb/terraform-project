provider "aws" {
  region = "us-east-1"  # Change to your desired region
}

module "vpc" {
  source          = "./modules/vpc"
}

module "ec2" {
  source          = "./modules/ec2"
}

module "alb" {
  source          = "./modules/alb"
  vpc_id          = module.vpc.vpc_id
  target_group_arns = module.ec2.target_group_arns
}