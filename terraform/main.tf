# Configure the AWS provider
provider "aws" {
  region = var.region
}

# Create a VPC
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr_block
}

output "vpc_id" {
  value = aws_vpc.vpc.id
}

module "auth" {
  source = "./modules/auth"
}

module "servers" {
  source = "./modules/servers"
  vpc_id = aws_vpc.vpc.id
}

module "caching" {
  source = "./modules/caching"
  vpc_id = aws_vpc.vpc.id
}

module "database" {
  source = "./modules/database"
  vpc_id = aws_vpc.vpc.id
}

module "storage" {
  source = "./modules/storage"
}