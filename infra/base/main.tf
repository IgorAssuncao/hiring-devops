resource "aws_cloudwatch_log_group" "default" {
  name = "${var.org_name}_default_ecs_cluster_log_group"
}

resource "aws_ecs_cluster" "this" {
  name = var.org_name

  configuration {
    execute_command_configuration {
      logging = "OVERRIDE"
      log_configuration {
        cloud_watch_log_group_name = aws_cloudwatch_log_group.default.name
      }
    }
  }
}

resource "aws_iam_instance_profile" "this" {
  name = "ecsInstanceRole-profile"
  role = "ecsInstanceRole"
}

resource "aws_launch_template" "this" {
  name          = "${var.org_name}_default_ec2_launch_template"
  instance_type = "t3.micro"
  image_id      = "ami-0453898e98046c639"
  iam_instance_profile {
    name = aws_iam_instance_profile.this.name
  }
  network_interfaces {
    associate_public_ip_address = true
  }
  update_default_version = true
  key_name               = aws_key_pair.this.key_name
  user_data = base64encode(<<EOF
#!/bin/bash

yum install -y polkit
amazon-linux-extras disable docker
amazon-linux-extras install -y ecs
echo ECS_CLUSTER=meteor >> /etc/ecs/ecs.config
systemctl stop docker
systemctl disable --now docker && 
systemctl enable --now ecs
EOF
  )
}

resource "aws_key_pair" "this" {
  key_name   = "igor"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDFndSO9u28l4NmzYJBXkfOTKvCi3XWOacbdNzh8t+g+hGGe7MONV1gjkEvQeMZRGuYHq0h0LD0BfK9v3nSW/z+Uss+UnXeDnx86oO6Gt1MctF2KD9oKSNMPFIkJlYSH1qIgiEo+41e3AhZN/kUX6+o2Q7PkqprCg5yBajOOi/dqq2RGrHa0HzyQiTZHqcZWWigvVMAwC/pC3wJM714DwNZQ1XTeJEUGszZk9aQnLlnVcRQqCilYR3NfqYtHml5esmLUVTK7c/l7l3P8UwaAc/dozYksjCE9eLbFT/2Km8kVYfGm+QhSf14bfVOCMZg7SZOpajDqH/P8JVXmsAwtUBFwIr4YFIUJLUu+J3EOjI1RsgA9OfDdiHXtcHXn0MPoM2ETGxqAriq9xeJGxmEvFkoonUY+EBFVPaPlv5TxszOGxZJL1rnXOxpu4D+43ySBUU5k5aBHvEg4zwldC4L+AJ+WJ6lqJ5TPAHBIF7CbnmRos1sxBtfpib6YxS/UR0olFc= void-dev@void"
}

resource "aws_autoscaling_group" "this" {
  availability_zones = ["us-east-1a", "us-east-1b"]

  min_size         = 1
  max_size         = 1
  desired_capacity = 1

  launch_template {
    id = aws_launch_template.this.id
  }

  tag {
    key                 = "AmazonECSManaged"
    value               = true
    propagate_at_launch = true
  }
}

resource "aws_ecs_capacity_provider" "this" {
  name = "meteor-ecs-capacity-provider"

  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.this.arn

    managed_scaling {
      maximum_scaling_step_size = 1
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity           = 1
    }
  }
}

resource "aws_ecs_cluster_capacity_providers" "this" {
  cluster_name       = aws_ecs_cluster.this.name
  capacity_providers = [aws_ecs_capacity_provider.this.name]
}
