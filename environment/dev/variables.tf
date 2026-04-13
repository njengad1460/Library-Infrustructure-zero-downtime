variable "region" {
  description = "AWS region"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging)"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnets" {
  description = "Map of public subnets"
  type = map(object({
    cidr = string
    az   = string
  }))
  default = {}
}

variable "use_existing_vpc" {
  description = "Whether to use an existing VPC"
  type        = bool
  default     = false
}

variable "existing_vpc_id" {
  description = "Existing VPC ID"
  type        = string
  default     = null
}

variable "ssh_location" {
  description = "SSH access CIDR"
  type        = string
}

variable "min_size" {
  description = "Min size of ASG"
  type        = number
}

variable "max_size" {
  description = "Max size of ASG"
  type        = number
}

variable "desired_capacity" {
  description = "Desired capacity of ASG"
  type        = number
}

variable "enable_autoscaling" {
  description = "Whether to enable autoscaling"
  type        = bool
  default     = false
}

variable "backend_image_uri" {
  description = "URI of the Backend Docker image in ECR"
  type        = string
}

variable "frontend_image_uri" {
  description = "URI of the Frontend Docker image in ECR"
  type        = string
}

variable "secret_id" {
  description = "Secrets Manager secret ID for this environment"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

# variable "key_name" {
#   description = "Name of the SSH key pair"
#   type        = string
# }
