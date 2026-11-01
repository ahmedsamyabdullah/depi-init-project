provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Project   = "secure-aws-infrastructure"
      ManagedBy = "terraform"
      Stack     = "init"
    }
  }
}
