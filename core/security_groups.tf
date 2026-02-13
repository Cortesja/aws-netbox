# Security group name = "netbox_internal"
resource "aws_security_group" "netbox_internal" {
  name        = "netbox-sg"
  description = "netbox ALB + ECS + RDS + Redis"
  vpc_id      = aws_vpc.netbox_vpc.id
}

resource "aws_security_group" "lb_traffic" {
  name        = "netbox-inbound-http"
  description = "allow internet traffic"
  vpc_id      = aws_vpc.netbox_vpc.id
}

############################
# INGRESS
############################

# ALB -> NetBox
resource "aws_vpc_security_group_ingress_rule" "http_8080" {
  security_group_id            = aws_security_group.netbox_internal.id
  referenced_security_group_id = aws_security_group.netbox_internal.id
  ip_protocol                  = "tcp"
  from_port                    = 8080
  to_port                      = 8080
  description                  = "ALB to NetBox"
}

# ECS -> PostgreSQL (RDS)
resource "aws_vpc_security_group_ingress_rule" "postgres_5432" {
  security_group_id            = aws_security_group.netbox_internal.id
  referenced_security_group_id = aws_security_group.netbox_internal.id
  ip_protocol                  = "tcp"
  from_port                    = 5432
  to_port                      = 5432
  description                  = "Postgres"
}

# ECS -> Redis
resource "aws_vpc_security_group_ingress_rule" "redis_6379" {
  security_group_id            = aws_security_group.netbox_internal.id
  referenced_security_group_id = aws_security_group.netbox_internal.id
  ip_protocol                  = "tcp"
  from_port                    = 6379
  to_port                      = 6379
  description                  = "Redis"
}

# ECS -> HTTPS (ECR, AWS APIs, ALB health checks, etc)
resource "aws_vpc_security_group_ingress_rule" "https_443" {
  security_group_id            = aws_security_group.netbox_internal.id
  referenced_security_group_id = aws_security_group.netbox_internal.id
  ip_protocol                  = "tcp"
  from_port                    = 443
  to_port                      = 443
  description                  = "HTTPS internal"
}

# Internet -> ALB
resource "aws_vpc_security_group_ingress_rule" "http_80" {
  security_group_id         = aws_security_group.lb_traffic.id
  cidr_ipv4                 = "118.238.29.185/32"
  ip_protocol               = "tcp"
  from_port                 = 443
  to_port                   = 443
  description               = "HTTPS from internet"
}


############################
# EGRESS
############################

resource "aws_vpc_security_group_egress_rule" "http_80" { 
  security_group_id = aws_security_group.netbox_internal.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
  description       = "HTTP"
}

resource "aws_vpc_security_group_egress_rule" "https_443" { 
  security_group_id = aws_security_group.netbox_internal.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  description       = "HTTPS"
}

resource "aws_vpc_security_group_egress_rule" "postgres_5432" { 
  security_group_id             = aws_security_group.netbox_internal.id
  referenced_security_group_id  = aws_security_group.netbox_internal.id
  ip_protocol                   = "tcp"
  from_port                     = 5432
  to_port                       = 5432
  description                   = "netbox to postgres"
}

resource "aws_vpc_security_group_egress_rule" "http_8080" {
  security_group_id             = aws_security_group.netbox_internal.id
  referenced_security_group_id  = aws_security_group.netbox_internal.id
  ip_protocol                   = "tcp"
  from_port                     = 8080
  to_port                       = 8080
  description                   = "netbox to ALB"
}

resource "aws_vpc_security_group_egress_rule" "redis_6379" {
  security_group_id             = aws_security_group.netbox_internal.id
  referenced_security_group_id  = aws_security_group.netbox_internal.id
  ip_protocol                   = "tcp"
  from_port                     = 6379
  to_port                       = 6379
  description                   = "netbox to redis"
}
