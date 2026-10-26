provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Project   = "depi-team-n"
      ManagedBy = "terraform"
      Stack     = "init"
    }
  }
}
