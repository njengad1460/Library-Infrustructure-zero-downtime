output "alb_dns_name" {
  value       = aws_lb.alb.dns_name
  description = "DNS name of the application load balancer"
}

output "target_group_arn" {
  value       = aws_lb_target_group.tg.arn
  description = "ARN of the target group"
}

output "backend_target_group_arn" {
  value       = aws_lb_target_group.backend_tg.arn
  description = "ARN of the backend target group"
}
