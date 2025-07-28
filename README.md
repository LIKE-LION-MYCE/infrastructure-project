# Infrastructure Project

This project contains Infrastructure as Code (IaC) using Terraform and configuration management with Ansible.

## Infrastructure Overview

- **VPC**: Public subnet (EC2) + Private subnets (RDS) across 2 AZs
- **EC2**: Ubuntu 22.04 t3.micro with SSH access
- **RDS**: MySQL 8.0 db.t3.micro in private subnets (free tier)
- **EIP**: Static public IP for EC2
- **Security**: Proper security groups, EC2 → RDS access only

## Project Structure

```
├── terraform/
│   ├── environments/
│   │   ├── dev/              # Development environment
│   │   ├── staging/          # Staging environment (ready)
│   │   ├── prod/             # Production environment (ready)
│   │   └── test-modules/     # Testing environment
│   └── modules/
│       ├── vpc/              # VPC, subnets, IGW, route tables
│       ├── ec2/              # EC2 instance, security group
│       ├── eip/              # Elastic IP
│       └── rds/              # MySQL RDS, DB subnet group
└── ansible/
    ├── playbooks/            # Configuration playbooks
    ├── roles/                # Reusable roles
    └── inventory/            # Server inventory
```

## Getting Started

### Prerequisites
- AWS CLI configured with profile `likelion-terraform`
- Terraform >= 1.0
- SSH key pair `likelion-terraform-key` uploaded to AWS

### Deploy Infrastructure

```bash
# 1. Navigate to dev environment
cd terraform/environments/dev

# 2. Set database password
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars and set: db_password = "your-secure-password"

# 3. Deploy infrastructure
terraform init
terraform plan
terraform apply
```

### Connect to Resources

```bash
# SSH to EC2 instance
ssh -i ~/.ssh/aws/likelion-terraform-key ubuntu@<public_ip>

# Database connection (from EC2)
mysql -h <db_endpoint> -u admin -p myce_database
```

### Configuration Management

```bash
cd ansible
ansible-playbook -i inventory/hosts playbooks/site.yml
```

## Database Details

- **Engine**: MySQL 8.0
- **Instance**: db.t3.micro (free tier)
- **Database**: myce_database
- **Username**: admin
- **Backups**: Disabled (dev environment)
- **Network**: Private subnets only, accessible from EC2

## MongoDB Atlas

This project uses MongoDB Atlas (external SaaS) for document storage:
- **Account**: Existing free tier cluster
- **Collections**: Created by Spring Boot application
- **Access**: Configured outside of Terraform

## Security Notes

- RDS in private subnets only
- Security groups restrict MySQL access to EC2 only
- SSH access open to 0.0.0.0/0 (⚠️ restrict for production)
- Database password managed via terraform.tfvars (gitignored)