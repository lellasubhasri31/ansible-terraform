terraform {
  backend "s3" {
    bucket         = "my-tf-test-bucket9864"
    key            = "talent-academy/backend/terraform.tfstates"
    region         = "eu-central-1"
    dynamodb_table = "terraform-lock"
  }
}