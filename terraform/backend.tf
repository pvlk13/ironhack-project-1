terraform {
  required_version = ">= 1.0"
  backend "s3" {
    bucket = "project-vijaya-microservices"
    key = "IRONHACK-PROJECT-1/terraform.tfstate"
    region = "us-west-2"
    dynamodb_table = "terraform-state-lock"   
  }
}