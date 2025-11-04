terraform {
  backend "s3" {
    bucket         = "neeha-terraform-state-bucket"
    key            = "infra/terraform.tfstate"
    region         = "ap-northeast-3"
    dynamodb_table = "neeha-terraform"
  }
}