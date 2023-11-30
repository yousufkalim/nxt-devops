variable "vpc_id" {
  type = string
}

resource "aws_subnet" "public_subnet" {
  vpc_id = var.vpc_id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true
}

# Create a security group for the EC2 instances
resource "aws_security_group" "web_sg" {
  name = "web-sg"
  description = "Security group for web servers"

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create an EC2 instance launch template
resource "aws_launch_template" "backend_lt" {
  name = "backend-lt"

  image_id = "ami-05983a09f7dc1c18f"
  instance_type = "t2.micro"

  user_data = <<-EOF
      #!/bin/bash

      # Install Docker
      curl -fsSL https://get.docker.com | sh

      # Install Nginx
      sudo apt-get update && sudo apt-get install -y nginx
      EOF
}

# Create an autoscaling group for the EC2 instances
resource "aws_autoscaling_group" "backend_asg" {
  name = "backend-asg"
  min_size = 1
  max_size = 3
  target_group_arns = [aws_lb_target_group.backend_tg.arn]

  launch_template {
    id = aws_launch_template.backend_lt.id
  }

  vpc_zone_identifier = [aws_subnet.public_subnet.id]
}

# Create a load balancer for the EC2 instances
resource "aws_lb" "backend_lb" {
  name = "backend-lb"
  subnets = [aws_subnet.public_subnet.id]

  internal = false
}

# Create a target group for the EC2 instances
resource "aws_lb_target_group" "backend_tg" {
  name = "backend-tg"
  port = 80
  protocol = "HTTP"
  vpc_id = var.vpc_id

  health_check {
    interval = 30
    timeout = 5
    path = "/"
    matcher = "200,302"
  }
}

# Create LB Listener
resource "aws_lb_listener" "backend_listener" {
  load_balancer_arn = aws_lb.backend_lb.arn
  port              = "80"
  protocol          = "HTTP"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend_tg.arn
  }
}

# Create a listener rule for the load balancer
resource "aws_lb_listener_rule" "backend_listener_rule" {
  listener_arn = aws_lb_listener.backend_listener.arn
  priority = 10
  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.backend_tg.arn
  }

  condition {
    path_pattern {
      values = ["/static/*"]
    }
  }

  condition {
    host_header {
      values = ["example.com"]
    }
  }
}
