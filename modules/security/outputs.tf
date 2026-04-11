output "alb_sg_id" {
  value       = aws_security_group.alb_sg.id
  description = "ID of the ALB security group"
}

output "ec2_sg_id" {
  value       = aws_security_group.ec2_sg.id
  description = "ID of the EC2 security group"
}
output "ec2_instance_profile_name" {
  value       = aws_iam_instance_profile.ec2_profile.name
  description = "Name of the EC2 IAM instance profile"
}
