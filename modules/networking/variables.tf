variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type = string
}

variable "public_subnets" {
  description = "Map of public subnets with CIDR and AZ"
  type = map(object({
    cidr = string
    az   = string
  }))
}


variable "project_name" {
  description = "Project name for tagging"
  type = string
}