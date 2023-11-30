provider "aws" {
  region = "us-west-2"
  alias  = "replica"
}

variable "vpc_id" {
  type = string
}


# Create a subnet for the RDS database
resource "aws_subnet" "public_subnet" {
  vpc_id = var.vpc_id
  cidr_block = "10.0.3.0/24"
  map_public_ip_on_launch = true
}

# Create a security group for the RDS database
resource "aws_security_group" "rds_sg" {
  name = "rds-sg"
  description = "Security group for RDS database"

  ingress {
    from_port = 5432
    to_port = 5432
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create an RDS instance
resource "aws_db_instance" "rds_instance" {
  allocated_storage       = 50
  identifier              = "nxtrds"
  engine                  = "postgres"
  engine_version          = "13.4"
  instance_class          = "db.t3.micro"
  db_name                 = "nxt_rds"
  username                = "masterusername"
  password                = "mypassword"
  backup_retention_period = 7
  storage_encrypted       = true
  skip_final_snapshot     = true

  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  # Auto scaling
  max_allocated_storage = 100
}

resource "aws_kms_key" "rds_kms" {
  description = "Encryption key for automated backups"

  provider = aws.replica
}

# Automated backup replication
resource "aws_db_instance_automated_backups_replication" "default" {
  source_db_instance_arn = aws_db_instance.rds_instance.arn
  kms_key_id             = aws_kms_key.rds_kms.arn

  provider = aws.replica
}
