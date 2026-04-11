provider "aws" {
  region = var.region
}

module "networking" {
  source         = "../../modules/networking"
  project_name   = var.project_name
  vpc_cidr       = var.vpc_cidr
  public_subnets = var.public_subnets
}

module "security" {
  source       = "../../modules/security"
  project_name = var.project_name
  vpc_id       = module.networking.vpc_id
  ssh_location = var.ssh_location
}

module "load_balancer" {
  source            = "../../modules/load_balancer"
  project_name      = var.project_name
  vpc_id            = module.networking.vpc_id
  public_subnet_ids = module.networking.public_subnet_ids
  alb_sg_id         = module.security.alb_sg_id
}

module "asg" {
  source           = "../../modules/ASG-lt"
  project_name     = var.project_name
  instance_type    = var.instance_type
  subnet_ids       = module.networking.public_subnet_ids
  ec2_sg_id        = module.security.ec2_sg_id
  target_group_arn = module.load_balancer.target_group_arn
  min_size         = var.min_size
  max_size         = var.max_size
  desired_capacity = var.desired_capacity
}
