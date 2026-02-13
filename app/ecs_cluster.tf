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

resource "aws_ecs_task_definition" "netbox_ui" {
  family                    = "netbox-ui"
  requires_compatibilities  = ["FARGATE"]
  network_mode              = "awsvpc"
  cpu                       = "1024"
  memory                    = "2048"
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "ARM64"
  }
  ephemeral_storage {
    size_in_gib = 21
  }
  
  execution_role_arn        = data.aws_iam_role.ecsTaskExecutionRole.arn
  task_role_arn             = data.aws_iam_role.netboxTaskRole.arn

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
        { name = "DB_HOST",             value = data.terraform_remote_state.core.outputs.db_host },
        { name = "DB_PORT",             value = tostring(data.terraform_remote_state.core.outputs.db_port) },
        { name = "DB_USER",             value = data.terraform_remote_state.core.outputs.db_user },
        { name = "DB_NAME",             value = tostring(data.terraform_remote_state.core.outputs.db_name) },
        { name = "DB_SSLMODE",          value = "require" },
        { name = "REDIS_HOST",          value = data.terraform_remote_state.core.outputs.redis_host },
        { name = "REDIS_PORT",          value = tostring(data.terraform_remote_state.core.outputs.redis_port) },
        { name = "REDIS_SSL",           value = "false" },

        { name = "AWS_STORAGE_BUCKET_NAME",    value = data.terraform_remote_state.core.outputs.s3_media_name }
      ]

      secrets = [
        { 
          name      = "SUPERUSER_NAME"
          valueFrom = "${data.terraform_remote_state.core.outputs.superuser_creds}:username::"
        },
        { 
          name      = "SUPERUSER_PASSWORD"
          valueFrom = "${data.terraform_remote_state.core.outputs.superuser_creds}:password::"
        },
        {
          name      = "DB_PASSWORD"
          valueFrom = "${data.terraform_remote_state.core.outputs.database_passwd}:password::"
        },
        {
          name      = "SECRET_KEY"
          valueFrom = "${data.terraform_remote_state.core.outputs.django_creds}:password::"
        }
      ]
      # This activates the cloud watch logs. turn off when it works to avoid extra costs.
      logConfiguration = {
        logDriver = "awslogs"
        options = { 
          awslogs-group = "/ecs/netbox"
          awslogs-region = "ap-northeast-1"
          awslogs-stream-prefix = "netbox-ui"
        }
      }
    }
  ])
}

resource "aws_ecs_task_definition" "netbox_worker" {
  family                    = "netbox-worker"
  requires_compatibilities  = ["FARGATE"]
  network_mode              = "awsvpc"
  cpu                       = "512"
  memory                    = "1024"
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "ARM64"
  }
  ephemeral_storage {
    size_in_gib = 21
  }
  
  execution_role_arn        = data.aws_iam_role.ecsTaskExecutionRole.arn
  task_role_arn             = data.aws_iam_role.netboxTaskRole.arn

  container_definitions = jsonencode([
    {
      name      = "netbox"
      image     = local.nb_image
      essential = true

      command = [
        "/opt/netbox/venv/bin/python",
        "/opt/netbox/netbox/manage.py",
        "rqworker"
      ]

      environment = [
        # Without this "HOME" line we get 'failed: could not open certificate file "/root/.postgresql/postgresql.crt": Permission denied.
        # Cannot read certain file locations so we set HOME to a directory that can be accessed universally.
        { name = "HOME",                value = "/tmp" },
        { name = "DB_HOST",             value = data.terraform_remote_state.core.outputs.db_host },
        { name = "DB_PORT",             value = tostring(data.terraform_remote_state.core.outputs.db_port) },
        { name = "DB_USER",             value = data.terraform_remote_state.core.outputs.db_user },
        { name = "DB_NAME",             value = tostring(data.terraform_remote_state.core.outputs.db_name) },
        { name = "DB_SSLMODE",          value = "require" },
        { name = "REDIS_HOST",          value = data.terraform_remote_state.core.outputs.redis_host },
        { name = "REDIS_PORT",          value = tostring(data.terraform_remote_state.core.outputs.redis_port) },
        { name = "REDIS_SSL",           value = "false" },
        
        { name = "AWS_STORAGE_BUCKET_NAME",    value = data.terraform_remote_state.core.outputs.s3_media_name }
      ]

      secrets = [
        {
          name      = "DB_PASSWORD"
          valueFrom = "${data.terraform_remote_state.core.outputs.database_passwd}:password::"
        },
        {
          name      = "SECRET_KEY"
          valueFrom = "${data.terraform_remote_state.core.outputs.django_creds}:password::"
        }
      ]

      # This activates the cloud watch logs. turn off when it works to avoid extra costs.
      logConfiguration = {
        logDriver = "awslogs"
        options = { 
          awslogs-group = "/ecs/netbox"
          awslogs-region = "ap-northeast-1"
          awslogs-stream-prefix = "netbox-worker"
        }
      }
    }
  ])
}

resource "aws_ecs_task_definition" "netbox_migrate_task" {
  family                    = "netbox-migrate-task"
  requires_compatibilities  = ["FARGATE"]
  network_mode              = "awsvpc"
  cpu                       = "512"
  memory                    = "1024"
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "ARM64"
  }
  ephemeral_storage {
    size_in_gib = 21
  }
  
  execution_role_arn        = data.aws_iam_role.ecsTaskExecutionRole.arn
  task_role_arn             = data.aws_iam_role.netboxTaskRole.arn

  container_definitions = jsonencode([
    {
      name      = "netbox"
      image     = local.nb_image
      essential = true

      command = [
        "/opt/netbox/venv/bin/python",
        "/opt/netbox/netbox/manage.py",
        "migrate"
      ]

      environment = [
        # Without this "HOME" line we get 'failed: could not open certificate file "/root/.postgresql/postgresql.crt": Permission denied.
        # Cannot read certain file locations so we set HOME to a directory that can be accessed universally.
        { name = "HOME",                value = "/tmp" },
        { name = "DB_HOST",             value = data.terraform_remote_state.core.outputs.db_host },
        { name = "DB_PORT",             value = tostring(data.terraform_remote_state.core.outputs.db_port) },
        { name = "DB_USER",             value = data.terraform_remote_state.core.outputs.db_user },
        { name = "DB_NAME",             value = tostring(data.terraform_remote_state.core.outputs.db_name) },
        { name = "DB_SSLMODE",          value = "require" },
        { name = "REDIS_HOST",          value = data.terraform_remote_state.core.outputs.redis_host },
        { name = "REDIS_PORT",          value = tostring(data.terraform_remote_state.core.outputs.redis_port) },
        { name = "REDIS_SSL",           value = "false" },
        
        { name = "AWS_STORAGE_BUCKET_NAME",    value = data.terraform_remote_state.core.outputs.s3_media_name }
      ]

      secrets = [
        {
          name      = "DB_PASSWORD"
          valueFrom = "${data.terraform_remote_state.core.outputs.database_passwd}:password::"
        },
        {
          name      = "SECRET_KEY"
          valueFrom = "${data.terraform_remote_state.core.outputs.django_creds}:password::"
        }
      ]

      # This activates the cloud watch logs. turn off when it works to avoid extra costs.
      logConfiguration = {
        logDriver = "awslogs"
        options = { 
          awslogs-group = "/ecs/netbox"
          awslogs-region = "ap-northeast-1"
          awslogs-stream-prefix = "netbox-migrate"
        }
      }
    }
  ])
}
#####################
# ECS Service
#####################

resource "aws_ecs_service" "netbox_ui" {
  name                    = "netbox-ui"
  cluster                 = aws_ecs_cluster.netbox.id
  task_definition         = aws_ecs_task_definition.netbox_ui.arn
  desired_count           = 2
  launch_type             = "FARGATE"
  enable_execute_command  = true # Need to exec into the container to change password

  health_check_grace_period_seconds = 300

  # Allow smoother updates with terraform apply
  force_new_deployment = true

  network_configuration {
    assign_public_ip = false
    security_groups = [data.terraform_remote_state.core.outputs.sg]
    subnets = data.terraform_remote_state.core.outputs.private_subnet_ids
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.netbox_target.arn
    container_name = "netbox"
    container_port  = 8080
  }
}

resource "aws_ecs_service" "netbox_worker" {
  name                    = "netbox-worker"
  cluster                 = aws_ecs_cluster.netbox.id
  task_definition         = aws_ecs_task_definition.netbox_worker.arn
  desired_count           = 2
  launch_type             = "FARGATE"
  enable_execute_command  = true

  health_check_grace_period_seconds = 300

  force_new_deployment    = true

  network_configuration {
    assign_public_ip      = false
    security_groups       = [data.terraform_remote_state.core.outputs.sg]
    subnets               = data.terraform_remote_state.core.outputs.private_subnet_ids
  }
}
