
# Secure AWS Infrastructure - Team Bootstrap

## Project Overview

This bootstrap setup prepares a shared Terraform environment for a team of five members using a **single AWS account**.

It creates:
- A shared S3 bucket for Terraform remote state.
- Four IAM users for team members.
- Shared IAM policies for project access.
- Password policy and controlled permissions.

| Activity | Students | Team Leader |
|---|---|---|
| Write Terraform code | Yes | Yes |
| terraform fmt / validate | Yes | Yes |
| terraform plan | Yes | Yes |
| terraform apply | No | Yes |

Only the team leader runs Terraform apply.

---

## Team Members

| Role | IAM Username | Member |
|---|---|---|
| Network | mohamed-ayad | Mohamed Ayad |
| Compute | moaaz-ehab | Moaaz Ehab |
| Data | kareem-hamdi | Kareem Hamdi |
| Security | haitham-mohamed | Haitham Mohamed |

---

## Leader Steps

### 1. Prepare

1. Use the IAM administrator account with MFA.
2. Never use the AWS root account for routine operations.
3. Confirm the AWS region is `us-east-1`.
4. Confirm the Terraform configuration uses the project naming convention.

### 2. Create the shared resources

Run from this bootstrap folder:

```powershell
terraform init
terraform fmt -recursive
terraform validate
terraform plan
```

Review the plan carefully.

Only the team leader can run:

```powershell
terraform apply
```

### 3. Configure the Bootstrap Remote State

After successful creation of the S3 bucket, create `backend.tf`:

```hcl
terraform {
  backend "s3" {
    bucket       = "secure-aws-infra-097908022344-tfstate"
    key          = "init/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
```

Then migrate the existing local state:

```powershell
terraform init -migrate-state
```

Verify that migration succeeded before deleting any local state files.

### 4. Enable Student Console Access

For each student:

1. Open AWS IAM.
2. Select the student's IAM user.
3. Enable console access.
4. Generate a temporary password.
5. Require password change at first sign-in.
6. Send login details privately.

### 5. Configure the Main Project Repository

The main project repository is:

`secure-aws-multi-account-infrastructure`

The project uses one AWS account.

Its S3 backend configuration:

```hcl
terraform {
  backend "s3" {
    bucket       = "secure-aws-infra-097908022344-tfstate"
    key          = "project/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}
```

Configure the AWS provider separately using the approved credentials method:

```hcl
provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Project   = "secure-aws-infrastructure"
      ManagedBy = "terraform"
    }
  }
}
```

### 6. GitHub Collaboration

1. Add all four students as repository collaborators.
2. Protect the `main` branch.
3. Require pull requests before merging.
4. Require at least one approval.
5. Each student works on a separate branch.
6. Only the team leader merges approved changes and applies infrastructure changes.

### 7. Daily Workflow

Team leader:

```powershell
git checkout main
git pull
terraform fmt -recursive
terraform validate
terraform plan
```

Review the plan.

If it is correct:

```powershell
terraform apply
```

Never apply unexpected destroy or replace operations without investigation.

---

## Student Steps

### 1. Sign in

1. Open the AWS sign-in URL.
2. Sign in using the provided IAM username and temporary password.
3. Change the password.
4. Configure MFA if required by the team.

### 2. Configure AWS CLI

Use the credentials method approved by the team leader.

Never share credentials or commit them to GitHub.

### 3. Clone the project

```powershell
git clone <project-repo-url>
cd secure-aws-multi-account-infrastructure
terraform init
```

### 4. Daily Development Workflow

Create a separate branch:

```powershell
git checkout main
git pull
git checkout -b feature/your-task
```

Write code in your assigned Terraform files.

Run:

```powershell
terraform fmt
terraform validate
terraform plan
```

Push your branch:

```powershell
git add .
git commit -m "Add assigned infrastructure"
git push -u origin feature/your-task
```

Open a Pull Request and include the Terraform plan output.

Wait for the team leader's review and approval.

---

## Security Rules

- Students must never run `terraform apply`.
- Never commit passwords, access keys, tokens, or state files.
- Never share credentials in GitHub or group chats.
- Report all AccessDenied errors to the team leader.
- Do not apply unexpected destroy or replace operations.
- The team leader is responsible for reviewing and applying infrastructure changes.
