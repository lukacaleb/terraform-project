variable "vpc_id" {}
variable "target_group_arns" {}

resource "aws_lb_target_group" "main" {
  name     = "web-servers"
  port     = 80
  protocol = "HTTP"
}

resource "aws_lb_listener" "main" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.main.arn
    type             = "forward"
  }
}

resource "aws_lb" "main" {
  name               = "my-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = [var.vpc_id]
  enable_deletion_protection = false
}

resource "aws_security_group" "alb" {
  name        = "alb-sg"
  description = "Allow traffic to ALB"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "alb_dns_name" {
  value = aws_lb.main.dns_name
}