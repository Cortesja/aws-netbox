# Naming scheme for all aws ui display names use '-' (hyphen)
# All terraform resource naming use '_' (underscore)

###############
# Subnet group
###############

resource "aws_elasticache_subnet_group" "netbox" {
  name        = "netbox-redis-subnets"
  subnet_ids = [
    aws_subnet.private_1.id,
    aws_subnet.private_2.id
  ]
}

################
# Elasticache ##
################

resource "aws_elasticache_cluster" "redis" {
  cluster_id            = "netbox-redis"
  engine                = "redis"
  node_type             = "cache.t4g.micro"
  num_cache_nodes       = 1
  port                  = 6379

  subnet_group_name     = aws_elasticache_subnet_group.netbox.name
  security_group_ids    = [aws_security_group.netbox_internal.id]

  lifecycle {
    prevent_destroy = true
  }
}
