provider "aws" {
  region = var.region
}

locals {
  is_staging = var.environment == "staging"
  
  # Environment-specific logic
  instance_type = var.instance_type
  project_name  = "${var.environment}-${var.project_name}"
}

module "networking" {
  source           = "../../modules/networking"
  project_name     = local.project_name
  vpc_cidr         = var.vpc_cidr
  public_subnets   = var.public_subnets
  use_existing_vpc = var.use_existing_vpc
  existing_vpc_id  = var.existing_vpc_id
}

module "security" {
  source       = "../../modules/security"
  project_name = local.project_name
  vpc_id       = module.networking.vpc_id
  ssh_location = var.ssh_location
}

module "load_balancer" {
  source            = "../../modules/load_balancer"
  project_name      = local.project_name
  vpc_id            = module.networking.vpc_id
  public_subnet_ids = module.networking.public_subnet_ids
  alb_sg_id         = module.security.alb_sg_id
}

module "asg" {
  source             = "../../modules/ASG-lt"
  project_name       = local.project_name
  instance_type      = local.instance_type
  subnet_ids         = module.networking.public_subnet_ids
  ec2_sg_id          = module.security.ec2_sg_id
  target_group_arn   = module.load_balancer.target_group_arn
  min_size                  = var.min_size
  max_size                  = var.max_size
  desired_capacity          = var.desired_capacity
  enable_autoscaling        = var.enable_autoscaling
  iam_instance_profile_name = module.security.ec2_instance_profile_name
  backend_image_uri         = var.backend_image_uri
  frontend_image_uri        = var.frontend_image_uri
  region                    = var.region
  key_name                  = var.key_name
}

module "cdn" {
  source       = "../../modules/CDN"
  project_name = local.project_name
  alb_dns_name = module.load_balancer.alb_dns_name
}
