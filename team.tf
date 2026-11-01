
# ===========================================================================
# IAM Users (Team Members)
# ===========================================================================

resource "aws_iam_user" "network" {
  name          = "mohamed-ayad"
  force_destroy = true
}

resource "aws_iam_user" "compute" {
  name          = "moaaz-ehab"
  force_destroy = true
}

resource "aws_iam_user" "data" {
  name          = "kareem-hamdi"
  force_destroy = true
}

resource "aws_iam_user" "security" {
  name          = "haitham-mohamed"
  force_destroy = true
}

# ===========================================================================
# Account Password Policy
# ===========================================================================

resource "aws_iam_account_password_policy" "this" {
  minimum_password_length        = 14
  require_lowercase_characters   = true
  require_uppercase_characters   = true
  require_numbers                = true
  require_symbols                = true
  allow_users_to_change_password = true
  password_reuse_prevention      = 5
}

# ===========================================================================
# User Policy Attachments
# ===========================================================================

resource "aws_iam_user_policy_attachments_exclusive" "network" {
  user_name = aws_iam_user.network.name

  policy_arns = [
    aws_iam_policy.base.arn,
    aws_iam_policy.self_service.arn,
  ]
}

resource "aws_iam_user_policy_attachments_exclusive" "compute" {
  user_name = aws_iam_user.compute.name

  policy_arns = [
    aws_iam_policy.base.arn,
    aws_iam_policy.self_service.arn,
  ]
}

resource "aws_iam_user_policy_attachments_exclusive" "data" {
  user_name = aws_iam_user.data.name

  policy_arns = [
    aws_iam_policy.base.arn,
    aws_iam_policy.self_service.arn,
  ]
}

resource "aws_iam_user_policy_attachments_exclusive" "security" {
  user_name = aws_iam_user.security.name

  policy_arns = [
    aws_iam_policy.base.arn,
    aws_iam_policy.self_service.arn,
  ]
}

# ===========================================================================
# Shared Base Policy
# Students can read project state and run Terraform plan.
# Only the team leader should run Terraform apply.
# ===========================================================================

resource "aws_iam_policy" "base" {
  name = "secure-aws-infra-base"
  path = "/team-admin/"

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid      = "StateList"
        Effect   = "Allow"
        Action   = "s3:ListBucket"
        Resource = aws_s3_bucket.terraform_state.arn

        Condition = {
          StringLike = {
            "s3:prefix" = "project/*"
          }
        }
      },
      {
        Sid      = "StateRead"
        Effect   = "Allow"
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.terraform_state.arn}/project/terraform.tfstate"
      },
      {
        Sid    = "StateLock"
        Effect = "Allow"

        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]

        Resource = "${aws_s3_bucket.terraform_state.arn}/project/terraform.tfstate.tflock"
      },
      {
        Sid    = "ProjectReadOnly"
        Effect = "Allow"

        Action = [
          "ec2:Describe*",
          "ec2:Get*",
          "elasticloadbalancing:Describe*",
          "autoscaling:Describe*",
          "rds:Describe*",
          "rds:ListTagsForResource",
          "cloudwatch:Describe*",
          "cloudwatch:Get*",
          "cloudwatch:List*",
          "logs:Describe*",
          "logs:List*",
          "cloudtrail:Describe*",
          "cloudtrail:Get*",
          "cloudtrail:List*",
          "kms:Describe*",
          "kms:Get*",
          "kms:List*",
          "guardduty:Get*",
          "guardduty:List*",
          "sns:Get*",
          "sns:List*",
          "events:Describe*",
          "events:List*",
          "secretsmanager:DescribeSecret",
          "secretsmanager:GetResourcePolicy",
          "secretsmanager:ListSecrets",
          "secretsmanager:ListSecretVersionIds",
          "s3:ListAllMyBuckets",
          "s3:GetBucketLocation",
          "tag:GetResources"
        ]

        Resource = "*"
      },
      {
        Sid    = "ProjectBucketConfigRead"
        Effect = "Allow"

        Action = [
          "s3:Get*",
          "s3:ListBucket"
        ]

        Resource = "arn:aws:s3:::secure-aws-infra-*"
      },
      {
        Sid    = "ProjectIamRead"
        Effect = "Allow"

        Action = [
          "iam:GetRole",
          "iam:GetRolePolicy",
          "iam:ListRolePolicies",
          "iam:ListAttachedRolePolicies",
          "iam:ListInstanceProfilesForRole",
          "iam:ListRoleTags",
          "iam:GetInstanceProfile",
          "iam:ListInstanceProfileTags",
          "iam:GetPolicy",
          "iam:GetPolicyVersion",
          "iam:ListPolicyVersions",
          "iam:ListPolicyTags"
        ]

        Resource = [
          "arn:aws:iam::*:role/secure-aws-infra-*",
          "arn:aws:iam::*:policy/secure-aws-infra-*",
          "arn:aws:iam::*:instance-profile/secure-aws-infra-*",
          "arn:aws:iam::*:role/aws-service-role/*",
          "arn:aws:iam::aws:policy/*"
        ]
      },
      {
        Sid    = "PublicAmiParameters"
        Effect = "Allow"

        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters"
        ]

        Resource = "arn:aws:ssm:us-east-1::parameter/aws/service/*"
      }
    ]
  })
}

# ===========================================================================
# Self-Service Policy
# Each student can change their own password and manage their own keys.
# ===========================================================================

resource "aws_iam_policy" "self_service" {
  name = "secure-aws-infra-self-service"
  path = "/team-admin/"

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid      = "ViewPasswordPolicy"
        Effect   = "Allow"
        Action   = "iam:GetAccountPasswordPolicy"
        Resource = "*"
      },
      {
        Sid    = "ManageOwnPasswordAndKeys"
        Effect = "Allow"

        Action = [
          "iam:ChangePassword",
          "iam:GetUser",
          "iam:CreateAccessKey",
          "iam:DeleteAccessKey",
          "iam:ListAccessKeys",
          "iam:UpdateAccessKey",
          "iam:GetAccessKeyLastUsed"
        ]

        Resource = "arn:aws:iam::*:user/$${aws:username}"
      }
    ]
  })
}
