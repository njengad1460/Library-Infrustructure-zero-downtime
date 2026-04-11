variable "region" {
  description = "AWS region"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR"
  type        = string
}

variable "public_subnets" {
  description = "Map of public subnets"
  type = map(object({
    cidr = string
    az   = string
  }))
}

variable "ssh_location" {
  description = "SSH access CIDR"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
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
