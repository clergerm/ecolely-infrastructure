# Ecolely Infrastructure

Terraform infrastructure code for managing Ecolely AWS resources.

This repository uses:

- Terraform for infrastructure provisioning
- AWS as the cloud provider
- Amazon S3 as the Terraform remote backend
- Separate Terraform state files per environment (`dev`, `test`, `prod`)

---

# Prerequisites

Install the following tools:

- Terraform
- AWS CLI
- Git

Verify installations:

```bash
terraform version
```

```bash
aws --version
```

---

# AWS Authentication

Terraform uses your local AWS credentials.

Verify AWS authentication:

```bash
aws sts get-caller-identity
```

Example response:

```json
{
  "Account": "AWS_ACCOUNT_ID",
  "Arn": "arn:aws:iam::AWS_ACCOUNT_ID:user/example"
}
```

---

# Step 1: Create Terraform Backend S3 Bucket (One Time Only)

Terraform uses Amazon S3 as a remote backend to store Terraform state.

The S3 bucket must be created manually in the AWS Console before running Terraform.

Required bucket:

```text
ecolely-terraform-state
```

Region:

```text
us-east-1
```

Configure the bucket with the following settings.

---

### Block Public Access

Enable:

```text
Block all public access
```

This prevents Terraform state files from being publicly accessible.

---

### Bucket Versioning

Enable:

```text
Versioning: Enabled
```

Versioning allows previous Terraform state versions to be recovered if needed.

---

### Default Encryption

Enable:

```text
Server-side encryption
Encryption type: SSE-S3
Encryption algorithm: AES-256
```

---

After creation, verify the bucket exists:

```text
S3
└── ecolely-terraform-state
```

Terraform stores state files separately by environment:

```text
ecolely-terraform-state/

├── dev/
│   └── terraform.tfstate
│
├── test/
│   └── terraform.tfstate
│
└── prod/
    └── terraform.tfstate
```

---

# Step 2: Configure Terraform Backend

The backend configuration is defined in:

```text
backend.tf
```

Example:

```hcl
terraform {
  backend "s3" {}
}
```

Environment-specific backend configurations:

```text
backend-dev.tfvars
backend-test.tfvars
backend-prod.tfvars
```

Example:

`backend-dev.tfvars`

```hcl
bucket       = "ecolely-terraform-state"
key          = "dev/terraform.tfstate"
region       = "us-east-1"
use_lockfile = true
```

---

# Step 3: Initialize Terraform

Terraform must be initialized with the correct backend before running `plan` or `apply`.

### Development Environment

```bash
terraform init \
  -backend-config="backend-dev.tfvars"
```

Terraform state location:

```text
s3://ecolely-terraform-state/dev/terraform.tfstate
```

---

### Test Environment

```bash
terraform init \
  -backend-config="backend-test.tfvars"
```

Terraform state location:

```text
s3://ecolely-terraform-state/test/terraform.tfstate
```

---

### Production Environment

```bash
terraform init \
  -backend-config="backend-prod.tfvars"
```

Terraform state location:

```text
s3://ecolely-terraform-state/prod/terraform.tfstate
```

---

# Step 4: Format and Validate Terraform

Format Terraform files:

```bash
terraform fmt
```

Validate Terraform configuration:

```bash
terraform validate
```

---

# Step 5: Review Infrastructure Changes

Create a Terraform execution plan before applying changes.

### Development

```bash
terraform plan \
  -var-file="ecolely-dev.tfvars"
```

### Test

```bash
terraform plan \
  -var-file="ecolely-test.tfvars"
```

### Production

```bash
terraform plan \
  -var-file="ecolely-prod.tfvars"
```

Terraform compares:

```text
Terraform configuration
        |
        v
Remote S3 state
        |
        v
AWS resources
```

---

# Step 6: Apply Infrastructure Changes

Deploy the selected environment.

### Development

```bash
terraform apply \
  -var-file="ecolely-dev.tfvars"
```

### Test

```bash
terraform apply \
  -var-file="ecolely-test.tfvars"
```

### Production

```bash
terraform apply \
  -var-file="ecolely-prod.tfvars"
```

---

# Terraform State Management

Terraform state is stored remotely in Amazon S3:

```text
ecolely-terraform-state/

├── dev/
│   └── terraform.tfstate
│
├── test/
│   └── terraform.tfstate
│
└── prod/
    └── terraform.tfstate
```

Benefits:

- Shared state between team members
- No local Terraform state files
- Environment isolation
- State locking support
- State version history through S3 versioning

---

# Important Notes

Always initialize the backend before running Terraform commands on a fresh checkout.

Recommended workflow:

```bash
terraform init \
  -backend-config="backend-dev.tfvars"

terraform plan \
  -var-file="ecolely-dev.tfvars"

terraform apply \
  -var-file="ecolely-dev.tfvars"
```

Avoid running:

```bash
terraform apply
```

before initializing the S3 backend.

---

# Terraform State Files

Do not commit Terraform state files.

The following files should remain local:

```text
terraform.tfstate
terraform.tfstate.*
.terraform/
```

Add them to `.gitignore`.

Remote state location:

```text
s3://ecolely-terraform-state/
```

---

# Switching Between Environments

To switch environments, reinitialize Terraform with the desired backend configuration.

### Development

```bash
terraform init \
  -backend-config="backend-dev.tfvars"
```

### Test

```bash
terraform init \
  -backend-config="backend-test.tfvars"
```

### Production

```bash
terraform init \
  -backend-config="backend-prod.tfvars"
```

Terraform connects to the corresponding remote state file.

---

# Destroy Resources

Remove resources from an environment.

### Development

```bash
terraform destroy \
  -var-file="ecolely-dev.tfvars"
```

### Test

```bash
terraform destroy \
  -var-file="ecolely-test.tfvars"
```

### Production

```bash
terraform destroy \
  -var-file="ecolely-prod.tfvars"
```

---

# Terraform Workflow Summary

```text
1. Create S3 backend bucket manually
        |
        v
ecolely-terraform-state


2. terraform init
        |
        v
Connect Terraform project to S3 backend


3. terraform plan
        |
        v
Review infrastructure changes


4. terraform apply
        |
        v
Deploy AWS infrastructure
```