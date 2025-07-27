# Infrastructure Project

This project contains Infrastructure as Code (IaC) using Terraform and configuration management with Ansible.

## Structure

```
├── terraform/
│   ├── environments/
│   │   ├── dev/
│   │   ├── staging/
│   │   ├── prod/
│   │   └── test/        # spin up testing clusters + load agents
│   ├── modules/
│   │   ├── vpc/
│   │   ├── eks/
│   │   └── loadgen/     # optional module for k6 or EC2 load agents
│   └── main.tf
└── ansible/
    ├── playbooks/
    ├── roles/
    └── inventory/
```

## Getting Started

### Terraform

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

### Ansible

```bash
cd ansible
ansible-playbook -i inventory/hosts playbooks/site.yml
```

