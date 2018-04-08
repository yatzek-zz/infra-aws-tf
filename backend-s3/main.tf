provider "aws" {
  region = "eu-west-1"
  version =  "~> 1.14"
}

resource "aws_s3_bucket" "terraform-state-storage" {
  bucket = "terraform-state-storage.jacek-szlachta.com"
  acl    = "private"

  versioning {
    enabled = true
  }

  lifecycle {
    prevent_destroy = true
  }

  tags {
    Name = "S3 Remote Terraform State Store"
  }

}

output "s3_bukcet_arn" {
  value = "${aws_s3_bucket.terraform-state-storage.arn}"
}

resource "aws_dynamodb_table" "dynamodb-terraform-state-lock" {
  name = "terraform-state-lock-dynamo"
  hash_key = "LockID"
  read_capacity = 20
  write_capacity = 20

  attribute {
    name = "LockID"
    type = "S"
  }

  tags {
    Name = "DynamoDB Terraform State Lock Table"
  }
}

# create s3 backend resource
# terraform.tf
//terraform {
//  backend "s3" {
//    encrypt = true
//    bucket = "terraform-state-storage.jacek-szlachta.com"
//    dynamodb_table = "terraform-state-lock-dynamo"
//    region = "us-east-1"
//    key = "s3-state-bucket/terraform.tfstate" # this has to be unique
//  }
//}