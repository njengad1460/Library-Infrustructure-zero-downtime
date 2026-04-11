variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnets" {
  description = "Map of public subnets with CIDR and AZ"
  type = map(object({
    cidr = string
    az   = string
  }))
  default     = {}
}

variable "project_name" {
  description = "Project name for tagging"
  type        = string
}

variable "use_existing_vpc" {
  description = "Whether to use an existing VPC instead of creating one"
  type        = bool
  default     = false
}

variable "existing_vpc_id" {
  description = "ID of an existing VPC to use"
  type        = string
  default     = null
}