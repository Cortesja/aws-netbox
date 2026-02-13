##################
# Load Balancer
##################

output "vpc" {
  value = aws_vpc.netbox_vpc.id
}

output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}

output "sg_alb" {
  value = aws_security_group.lb_traffic.id
}

###############################
# Task Definitions
###############################

output "db_host" {
  value = aws_db_instance.netbox_rds.address
}

output "db_port" {
  value = aws_db_instance.netbox_rds.port
}

output "db_user" {
  value = local.db_creds.username
  sensitive = true
}

output "db_name" {
  value = aws_db_instance.netbox_rds.db_name
}

output "redis_host" {
  value = aws_elasticache_cluster.redis.cache_nodes[0].address
}

output "redis_port" {
  value = aws_elasticache_cluster.redis.port
}

output "database_passwd" {
  value = aws_secretsmanager_secret.datab_password.arn
}

output "django_creds" {
  value = aws_secretsmanager_secret.session_secret_key.arn
}

output "superuser_creds" {
  value = aws_secretsmanager_secret.admin_creds.arn
}

###############################
# ECS Service
###############################

output "sg" {
  value = aws_security_group.netbox_internal.id
}

output "private_subnet_ids" {
  value = aws_subnet.private[*].id
}

##############################
# S3 Bucket
##############################

output "s3_media_name" {
  value = aws_s3_bucket.netbox_media.bucket
}
