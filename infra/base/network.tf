# resource "aws_elb" "ecs_service" {
#   name               = "${var.org_name}-challenge-lb-ecs"
#   availability_zones = ["us-east-1a", "us-east-1b"]
#   internal           = false
# 
#   listener {
#     instance_port     = 3000
#     instance_protocol = "http"
#     lb_port           = 80
#     lb_protocol       = "http"
#   }
# 
#   health_check {
#     healthy_threshold   = 2
#     unhealthy_threshold = 10
#     timeout             = 60
#     target              = "HTTP:80/"
#     interval            = 90
#   }
# }

resource "aws_lb" "ecs_service" {
  name               = "${var.org_name}-challenge-lb-ecs"
  internal           = false
  load_balancer_type = "application"
  subnets            = ["subnet-099648338ddae909a", "subnet-0c5f06f819efedcec"]
  security_groups    = ["sg-027c98b0e2e776912"]
}

resource "aws_lb_listener" "ecs_service" {
  load_balancer_arn = aws_lb.ecs_service.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs_service.arn
  }
}

resource "aws_lb_listener_rule" "ecs_service" {
  listener_arn = aws_lb_listener.ecs_service.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs_service.arn
  }

  condition {
    http_request_method {
      values = ["GET", "HEAD", "PUT", "POST", "DELETE"]
    }
  }
}

resource "aws_lb_target_group" "ecs_service" {
  name        = "${var.org_name}-challenge-lb-tg-ecs"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = "vpc-0317f30b48970f4e9"

  health_check {
    enabled             = true
    port                = 80
    protocol            = "HTTP"
    interval            = 5
    timeout             = 2
    healthy_threshold   = 2
    unhealthy_threshold = 10
  }
}

resource "aws_lb_target_group_attachment" "ecs_service_instance" {
  target_group_arn = aws_lb_target_group.ecs_service.arn
  target_id        = "i-041d05aa652db5e4d"
  port             = 80
}
