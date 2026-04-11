# Library Management System Infrastructure

This project provides a robust, zero-downtime AWS infrastructure managed by Terraform for deploying a containerized Library Management System. It uses an Auto Scaling Group (ASG) behind an Application Load Balancer (ALB) and is fronted by an AWS CloudFront CDN for global performance optimization.

## 🚀 Architecture Overview

The infrastructure consists of several modular components:

- **CDN (CloudFront)**: Optimized for Africa (specifically **Kenya**) using `PriceClass_200`. It provides low-latency access via the Nairobi edge location and terminates SSL for secure global delivery.
- **Load Balancer**: Application Load Balancer (ALB) that distributes traffic across your application instances and performs health monitoring.
- **Compute (ASG)**: Auto Scaling Group with Launch Templates that automatically pull and run Docker containers directly from **AWS ECR**.
- **Security**: Granular security groups for the ALB and EC2 instances, and IAM Roles for secure, passwordless access to your container registry.
- **Networking**: High-availability VPC spanning multiple Availability Zones with public subnets.
- **Zero-Downtime**: Managed via ASG Instance Refresh, ensuring your app stays online with a "Rolling" update strategy during deployments.

## 📁 Directory Structure

```text
.
├── environment
│   ├── dev          # Development environment configuration
│   └── staging      # Staging environment configuration
└── modules
    ├── ASG-lt       # Auto Scaling Group & Launch Template logic
    ├── CDN          # CloudFront Distribution (Optimized for Kenya)
    ├── load_balancer # ALB, Target Groups, and Listeners
    ├── networking   # VPC, Subnets, and IGW
    └── security     # Security Groups and IAM Roles
```

## 🛠 Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) (v1.0+)
- [AWS CLI](https://aws.amazon.com/cli/) configured with appropriate credentials.
- An existing **AWS ECR Repository** containing your Docker image.

## ⚙️ How to Deploy

### 1. Configure Variables
Navigate to your desired environment (e.g., `environment/dev`) and update `terraform.tfvars`:

```hcl
region        = "us-east-1"
project_name  = "library-system"
instance_type = "t2.micro"
desired_capacity = 2
ecr_image_uri = "123456789012.dkr.ecr.us-east-1.amazonaws.com/library-app:latest"
```

### 2. Initialize, Plan and Apply
```bash
terraform init
terraform plan
terraform apply
```

## 🔄 Zero-Downtime Updates

To update the application without downtime:
1. Push a new image to your ECR repository.
2. Update the `ecr_image_uri` in your `terraform.tfvars` if the tag has changed.
3. Run `terraform apply`.
4. The ASG will initiate an **Instance Refresh**, replacing EC2 instances one by one. The ALB will automatically shift traffic to the new instances as they become healthy.

## 🇰🇪 Kenya Content Delivery

The project is configured to use CloudFront's **PriceClass_200**. This ensures that the application is cached and served from the **Nairobi, Kenya** edge location, providing significantly faster load times for users in East Africa while remaining cost-effective within the AWS Free Tier.

Access your application via the `cloudfront_url` output after deployment:
```bash
cloudfront_url = "https://d12345example.cloudfront.net"
```

## 🛡 Security

- **Restricted Access**: EC2 instances are protected by security groups that only allow traffic from the Application Load Balancer.
- **IAM Instance Profiles**: Instances use temporary IAM credentials to pull from ECR, following the principle of least privilege.
- **Global SSL**: CloudFront provides automatic HTTPS redirection using the default CloudFront certificate.

## 📜 License
This project is licensed under the MIT License.
