# Naming scheme for all aws ui display names use '-' (hyphen)
# All terraform resource naming use '_' (underscore)

###################
# ECS cluster
###################

resource "aws_ecs_cluster" "netbox" {
  name = "netbox-cluster"
}

###################
# Task Definition
###################

resource "aws_ecs_task_definition" "netbox" {
  family                    = "netbox"
  requires_compatibilities  = ["FARGATE"]
  network_mode              = "awsvpc"
  cpu                       = "1024"
  memory                    = "2048"
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "ARM64"
  }
  ephemeral_storage {
    size_in_gib = 30
  }
  
  execution_role_arn        = data.aws_iam_role.ecsTaskExecutionRole.arn
  task_role_arn             = data.aws_iam_role.ecsTaskExecutionRole.arn

  container_definitions = jsonencode([
    {
      name      = "netbox"
      image     = local.nb_image
      essential = true

      portMappings = [
        {
          name          = "http"
          containerPort = 8080
          hostPort      = 8080
          protocol      = "tcp"
          appProtocol   = "http"
        }
      ]

      environment = [
        # Without this "HOME" line we get 'failed: could not open certificate file "/root/.postgresql/postgresql.crt": Permission denied.
        # Cannot read certain file locations so we set HOME to a directory that can be accessed universally.
        { name = "HOME",                value = "/tmp" },
        { name = "DB_HOST",             value = aws_db_instance.netbox_rds.address },
        { name = "DB_PORT",             value = tostring(aws_db_instance.netbox_rds.port) },
        { name = "DB_USER",             value = local.db_creds.username },
        { name = "DB_NAME",             value = tostring(aws_db_instance.netbox_rds.db_name) },
        { name = "DB_SSLMODE",          value = "require" },
        { name = "REDIS_HOST",          value = aws_elasticache_cluster.redis.cache_nodes[0].address },
        { name = "REDIS_PORT",          value = tostring(aws_elasticache_cluster.redis.port) },
        { name = "REDIS_SSL",           value = "false" },
        { name = "SUPERUSER_NAME",      value = local.superuser_creds.username },
        { name = "SUPERUSER_PASSWORD",  value = local.superuser_creds.password } # aws ecs execute-command into the container and change the password. or use any other credential storing.
      ]

      secrets = [
        {
          name      = "DB_PASSWORD"
          valueFrom = "${aws_secretsmanager_secret.db_password.arn}:password::"
        },
        {
          name      = "SECRET_KEY"
          valueFrom = "${aws_secretsmanager_secret.django_secret.arn}:password::"
        }
      ]
      # This activates the cloud watch logs. turn off when it works to avoid extra costs.
      logConfiguration = {
        logDriver = "awslogs"
        options = { 
          awslogs-group = "/ecs/netbox"
          awslogs-region = "ap-northeast-1"
          awslogs-stream-prefix = "web-ui"
        }
      }
    }
  ])
}

#####################
# ECS Service
#####################

resource "aws_ecs_service" "netbox" {
  name            = "web-ui"
  cluster         = aws_ecs_cluster.netbox.id
  task_definition = aws_ecs_task_definition.netbox.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  enable_execute_command = true # Need to exec into the container to change password

  health_check_grace_period_seconds = 300

  # Allow smoother updates with terraform apply
  force_new_deployment = true

  network_configuration {
    assign_public_ip = false
    security_groups = [aws_security_group.netbox_internal.id]
    subnets = [aws_subnet.private_1.id, aws_subnet.private_2.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.netbox_target.arn
    container_name = "netbox"
    container_port  = 8080
  }
}
