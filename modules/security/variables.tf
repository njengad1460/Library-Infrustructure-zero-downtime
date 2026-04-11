variable "vpc_id" {
  description = "VPC ID where security groups will be created"
  type        = string
}

variable "project_name" {
  description = "Project name for naming resources"
  type        = string
}

variable "ssh_location" {
  description = "IP address or CIDR block allowed to SSH into instances"
  type        = string
  default     = "0.0.0.0/0"
}
