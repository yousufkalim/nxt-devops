variable "vpc_id" {
  type = string
}


# Create a redis cluster using elastic cache
resource "aws_elasticache_cluster" "cache_cluster" {
  cluster_id           = "cluster-1"
  engine               = "redis"
  node_type            = "cache.m4.large"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis3.2"
  engine_version       = "3.2.10"
  port                 = 6379
}

# Create a security group to restrict access to the Redis cache
resource "aws_security_group" "cache_sg" {
  name        = "my-redis-cache-sg"
  description = "Security group for Redis cache"

  ingress {
    from_port = 6379
    to_port = 6379
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create a subnet for the Redis cache
resource "aws_subnet" "cache_subnet" {
  vpc_id = var.vpc_id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "redis-cache-subnet"
  }
}
