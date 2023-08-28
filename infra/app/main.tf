resource "aws_ecs_service" "this" {
  name          = "${var.org_name}-challenge-service"
  cluster       = data.terraform_remote_state.base.outputs.main_ecs_cluster_arn
  desired_count = 1
  iam_role      = "ecsServiceCustom"

  force_new_deployment = true

  task_definition = aws_ecs_task_definition.this.arn

  capacity_provider_strategy {
    capacity_provider = "meteor-ecs-capacity-provider"
    weight            = 100
  }

  deployment_controller {
    type = "ECS"
  }

  load_balancer {
    # elb_name       = data.terraform_remote_state.base.outputs.main_ecs_elb_name
    target_group_arn = "arn:aws:elasticloadbalancing:us-east-1:894919937483:targetgroup/meteor-challenge-lb-tg-ecs/cb4fa903cc0fbb79"
    container_name   = var.container_name
    container_port   = var.container_port
  }

  # network_configuration {
  #   subnets         = ["subnet-099648338ddae909a", "subnet-0c5f06f819efedcec"]
  #   security_groups = ["sg-027c98b0e2e776912"]
  # }

  depends_on = [aws_ecs_task_definition.this]
}

resource "aws_ecs_task_definition" "this" {
  family                   = "${var.org_name}-challenge-ecs-task-def"
  requires_compatibilities = ["EC2"]
  network_mode             = "bridge"
  container_definitions = jsonencode([
    {
      name      = "${var.org_name}-challenge-app"
      image     = "igorassuncao/meteor"
      cpu       = 10
      memory    = 256
      essential = true
      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
        }
      ]
      environment = [
        {
          name  = "MONGODB_ADDON_URI"
          value = "mongodb://meteorhiring:meteorhiring@ac-nhcvxhf-shard-00-00.bebrwbu.mongodb.net:27017/message?ssl=true&authSource=admin&replicaSet=atlas-1jchvv-shard-0"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options : {
          awslogs-group : "meteor_default_ecs_cluster_log_group"
          awslogs-region : "us-east-1"
        }
      }
    }
  ])
}
