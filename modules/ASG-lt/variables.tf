variable "project_name" {
  description = "Project name"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the ASG"
  type        = list(string)
}

variable "ec2_sg_id" {
  description = "Security group ID for the EC2 instances"
  type        = string
}

variable "target_group_arn" {
  description = "ARN of the target group to associate with the ASG"
  type        = string
}

variable "min_size" {
  description = "Minimum number of instances in the ASG"
  type        = number
}

variable "max_size" {
  description = "Maximum number of instances in the ASG"
  type        = number
}

variable "desired_capacity" {
  description = "Desired number of instances in the ASG"
  type        = number
}

variable "enable_autoscaling" {
  description = "Whether to enable autoscaling policies"
  type        = bool
  default     = false
}

variable "iam_instance_profile_name" {
  description = "Name of the IAM instance profile for EC2"
  type        = string
}

variable "ecr_image_uri" {
  description = "URI of the Docker image in ECR"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "key_name" {
  description = "Name of the SSH key pair to use for EC2 instances"
  type        = string
  default     = null
}
