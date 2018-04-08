provider "aws" {
  region = "eu-west-1"
  version =  "~> 1.14"
}

terraform {
  backend "s3" {
    encrypt = true
    bucket = "terraform-state-storage.jacek-szlachta.com"
    dynamodb_table = "terraform-state-lock-dynamo"
    region = "eu-west-1"
    key = "vpc/terraform.tfstate" # this has to be unique
  }
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "my-vpc"

  cidr = "10.0.0.0/16"

  azs             = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  private_subnets = ["10.0.0.0/19", "10.0.64.0/19", "10.0.128.0/19"]
  public_subnets  = ["10.0.32.0/20", "10.0.96.0/20", "10.0.160.0/20"]

  enable_nat_gateway = true
  enable_dns_hostnames = true

  tags = {
    Owner       = "user"
    Environment = "dev"
  }
}

//Practical VPC design:
//https://medium.com/aws-activate-startup-blog/practical-vpc-design-8412e1a18dcc
//
//10.0.0.0/16:
//    10.0.0.0/18 — AZ A
//    10.0.64.0/18 — AZ B
//    10.0.128.0/18 — AZ C
//    10.0.192.0/18 — Spare
//
//
//10.0.0.0/16:
//    10.0.0.0/18 — AZ A
//        10.0.0.0/19 — Private
//        10.0.32.0/19
//               10.0.32.0/20 — Public
//               10.0.48.0/20
//                   10.0.48.0/21 — Protected
//                   10.0.56.0/21 — Spare
//    10.0.64.0/18 — AZ B
//        10.0.64.0/19 — Private
//        10.0.96.0/19
//               10.0.96.0/20 — Public
//               10.0.112.0/20
//                   10.0.112.0/21 — Protected
//                   10.0.120.0/21 — Spare
//    10.0.128.0/18 — AZ C
//        10.0.128.0/19 — Private
//        10.0.160.0/19
//               10.0.160.0/20 — Public
//               10.0.176.0/20
//                   10.0.176.0/21 — Protected
//                   10.0.184.0/21 — Spare
//    10.0.192.0/18 — Spare AZ
//        10.0.192.0/19 — Private
//        10.0.224.0/19
//               10.0.224.0/20 — Public
//               10.0.240.0/20
//                   10.0.240.0/21 — Protected
//                   10.0.248.0/21 — Spare
