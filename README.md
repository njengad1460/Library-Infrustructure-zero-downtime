# Library Management System — AWS Infrastructure

Zero-downtime AWS infrastructure for a containerized MERN-stack Library Management System, managed with Terraform. A CloudFront CDN fronts an Application Load Balancer (ALB), which distributes traffic across an Auto Scaling Group (ASG) of EC2 instances running Docker Compose.

---

## Architecture Overview

```
Users (Global / Kenya)
        │
        ▼
  CloudFront CDN          ← PriceClass_200 (Nairobi edge), HTTPS redirect
        │
        ▼
Application Load Balancer ← Public, multi-AZ (af-south-1a / af-south-1b)
        │
   ┌────┴────┐
   ▼         ▼
Frontend TG  Backend TG   ← Port 80 (React) / Port 5000 (/api/*)
   │         │
   └────┬────┘
        ▼
  Auto Scaling Group       ← Launch Template, Rolling Instance Refresh
  EC2 (Ubuntu 22.04)       ← Docker Compose: frontend + backend containers
        │
        ├── AWS ECR        ← Container images pulled at boot
        └── Secrets Manager← MONGO_URI, JWT_SECRET injected via user-data
```

---

## Directory Structure

```
.
├── environment/
│   ├── dev/               # Development environment (af-south-1)
│   │   ├── backend.tf     # S3 remote state: dev/LMS/terraform.tfstate
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   ├── terraform.tfvars
│   │   └── variables.tf
│   └── staging/           # Staging environment (af-south-1)
│       ├── backend.tf     # S3 remote state: staging/LMS/terraform.tfstate
│       ├── main.tf
│       ├── outputs.tf
│       ├── terraform.tfvars
│       └── variables.tf
└── modules/
    ├── ASG-lt/            # Launch Template + Auto Scaling Group + CloudWatch scaling
    ├── CDN/               # CloudFront distribution (PriceClass_200)
    ├── load_balancer/     # ALB, frontend TG (port 80), backend TG (port 5000), listeners
    ├── networking/        # VPC, public subnets, IGW, route tables (or existing VPC lookup)
    └── security/          # ALB & EC2 security groups, IAM role, instance profile, Secrets Manager policy
```

---

## Modules

### `networking`
Creates a VPC with public subnets across multiple AZs, an Internet Gateway, and a public route table. Supports reusing an existing VPC via `use_existing_vpc` and `existing_vpc_id`.

### `security`
- ALB security group: allows inbound HTTP (80) from anywhere.
- EC2 security group: allows inbound on port 80 and 5000 from the ALB only, plus SSH from `ssh_location`.
- IAM role + instance profile: grants EC2 instances `AmazonEC2ContainerRegistryReadOnly` and `secretsmanager:GetSecretValue` for the configured secret.

### `load_balancer`
- Internet-facing ALB across all public subnets.
- Frontend target group on port 80 — health check on `/`.
- Backend target group on port 5000 — health check on `/api/auth/login` (accepts 200, 404, 405).
- Listener rule: `/api/*` paths forward to the backend target group; all other traffic goes to the frontend.

### `ASG-lt`
- Launch Template using the latest Ubuntu 22.04 AMI.
- User-data script: installs Docker, AWS CLI, fetches `MONGO_URI` and `JWT_SECRET` from Secrets Manager, authenticates to ECR, writes a `.env` file, and starts both containers with `docker compose up -d`.
- ASG with Rolling Instance Refresh (`min_healthy_percentage = 50`, `instance_warmup = 420s`).
- Optional CPU-based scale-out policy (CloudWatch alarm at 80% CPU) controlled by `enable_autoscaling`.

### `CDN`
CloudFront distribution pointing to the ALB origin over HTTP. Uses `Managed-CachingDisabled` and `Managed-AllViewerExceptHostHeader` policies so all requests (including API calls) pass through uncached. `PriceClass_200` ensures the Nairobi, Kenya edge location is active. All viewer connections are redirected to HTTPS.

---

## Remote State

Both environments use the same S3 bucket with DynamoDB locking:

| Environment | State Key |
|-------------|-----------|
| dev | `dev/LMS/terraform.tfstate` |
| staging | `staging/LMS/terraform.tfstate` |

- S3 bucket: `davy-terraform-state-storage` (region: `us-east-1`)
- DynamoDB table: `terraform-state-locking`
- Encryption: enabled

---

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) v1.0+
- AWS CLI configured with credentials that have permissions to manage EC2, ECS/ECR, ALB, CloudFront, IAM, VPC, Secrets Manager, S3, and DynamoDB.
- Two ECR repositories containing your Docker images (frontend + backend).
- A Secrets Manager secret containing `MONGO_URI` and `JWT_SECRET` as JSON keys.
- The S3 bucket and DynamoDB table for remote state must exist before the first `terraform init`.

---

## Variables

| Variable | Description | Default |
|---|---|---|
| `region` | AWS region | — |
| `project_name` | Base project name | — |
| `environment` | Environment label (`dev` / `staging`) | — |
| `vpc_cidr` | VPC CIDR block | `10.0.0.0/16` |
| `public_subnets` | Map of `{ cidr, az }` objects | `{}` |
| `use_existing_vpc` | Reuse an existing VPC | `false` |
| `existing_vpc_id` | ID of the existing VPC | `null` |
| `ssh_location` | CIDR allowed to SSH to EC2 | — |
| `instance_type` | EC2 instance type | — |
| `min_size` | ASG minimum instance count | — |
| `max_size` | ASG maximum instance count | — |
| `desired_capacity` | ASG desired instance count | — |
| `enable_autoscaling` | Enable CPU-based scale-out policy | `false` |
| `backend_image_uri` | ECR URI for the backend image | — |
| `frontend_image_uri` | ECR URI for the frontend image | — |
| `secret_id` | Secrets Manager secret ID | — |

---

## Deploy

```bash
# From the desired environment directory, e.g.:
cd environment/dev

terraform init
terraform plan
terraform apply
```

### Outputs

| Output | Description |
|---|---|
| `alb_dns_name` | ALB DNS name (direct access) |
| `vpc_id` | ID of the provisioned VPC |
| `cloudfront_url` | Public HTTPS URL via CloudFront |

Access the application at the `cloudfront_url` output:
```
cloudfront_url = "https://d12345example.cloudfront.net"
```

---

## Zero-Downtime Updates

1. Push a new image to ECR.
2. Update `backend_image_uri` or `frontend_image_uri` in `terraform.tfvars` if the tag changed.
3. Run `terraform apply`.
4. The ASG triggers a **Rolling Instance Refresh** — new instances are launched and health-checked by the ALB before old ones are terminated. At least 50% of capacity stays healthy throughout.

---

## Security Notes

- EC2 instances are not directly reachable from the internet on application ports — only the ALB security group is whitelisted.
- Secrets (database URI, JWT secret) are never baked into the AMI or passed as plain-text environment variables in Terraform. They are fetched at boot from Secrets Manager using temporary IAM credentials.
- IAM permissions follow least privilege: ECR read-only + a scoped `GetSecretValue` on the specific secret path.
- CloudFront enforces HTTPS for all viewers using the default CloudFront certificate.

---
