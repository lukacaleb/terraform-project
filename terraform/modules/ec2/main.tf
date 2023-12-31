resource "aws_launch_template" "main" {
  name          = "web-server-template"
  #version       = "$Latest"
  image_id      = "ami-xxxxxxxxxxxxxxxxx"  # Change to a suitable AMI
  instance_type = "t2.micro"
  #key_name      = var.key_name
  vpc_security_group_ids = [aws_security_group.main.id]
  user_data = <<-EOF
              #!/bin/bash
              echo "Hostname or IP: \$(hostname -i)" > /usr/share/nginx/html/index.html
              yum install -y nginx
              systemctl start nginx
              systemctl enable nginx
              EOF
}

resource "aws_security_group" "main" {
  name        = "web-server-sg"
  description = "Allow traffic from ALB to web servers"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.alb.id]
  }
}

resource "aws_security_group" "alb" {
  name        = "alb-sg"
  description = "Allow traffic to ALB"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_autoscaling_group" "main" {
  desired_capacity     = 2
  max_size             = 3
  min_size             = 1
  launch_template {
    id      = aws_launch_template.main.id
    version = "$Latest"
  }
  vpc_zone_identifier  = [aws_subnet.private.id]
}

resource "aws_lb_target_group" "main" {
  name     = "web-servers"
  port     = 80
  protocol = "HTTP"
}

output "target_group_arns" {
  value = [aws_lb_target_group.main.arn]
}