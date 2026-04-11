output "vpc_id" {
  value       = var.use_existing_vpc ? data.aws_vpc.selected[0].id : aws_vpc.myvpc[0].id
  description = "The ID of the VPC"
}

output "public_subnet_ids" {
  value       = var.use_existing_vpc ? data.aws_subnets.existing[0].ids : [for s in aws_subnet.public : s.id]
  description = "List of public subnet IDs"
}