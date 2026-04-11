output "vpc_id" {
  value       = aws_vpc.myvpc.id
  description = "The ID of the VPC"
}

output "public_subnet_ids" {
  value       = [for s in aws_subnet.public : s.id]
  description = "List of public subnet IDs"
}