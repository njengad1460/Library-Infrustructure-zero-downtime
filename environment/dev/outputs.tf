output "alb_dns_name" {
  value       = module.load_balancer.alb_dns_name
  description = "The DNS name of the Load Balancer to access the library management system"
}

output "vpc_id" {
  value = module.networking.vpc_id
}

output "cloudfront_url" {
  value       = "https://${module.cdn.cloudfront_domain_name}"
  description = "The URL of the CDN providing content delivery optimized for Kenya"
}
