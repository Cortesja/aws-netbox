# Security group name = "netbox-priv"
resource "aws_security_group" "netbox-priv" {
  name        = "netbox-sg"
  description = "netbox ALB + ECS + RDS + Redis"
  vpc_id      = aws_vpc.netbox-vpc.id
}

resource "aws_security_group" "lb-traffic" {
  name        = "ALB-Front-End"
  description = "allow internet traffic"
  vpc_id      = aws_vpc.netbox-vpc.id
}

############################
# INGRESS
############################

# ALB → NetBox
resource "aws_vpc_security_group_ingress_rule" "http_8080" {
  security_group_id            = aws_security_group.netbox-priv.id
  referenced_security_group_id = aws_security_group.netbox-priv.id
  ip_protocol                  = "tcp"
  from_port                    = 8080
  to_port                      = 8080
  description                  = "ALB to NetBox"
}

# ECS → PostgreSQL (RDS)
resource "aws_vpc_security_group_ingress_rule" "postgres_5432" {
  security_group_id            = aws_security_group.netbox-priv.id
  referenced_security_group_id = aws_security_group.netbox-priv.id
  ip_protocol                  = "tcp"
  from_port                    = 5432
  to_port                      = 5432
  description                  = "Postgres"
}

# ECS → Redis
resource "aws_vpc_security_group_ingress_rule" "redis_6379" {
  security_group_id            = aws_security_group.netbox-priv.id
  referenced_security_group_id = aws_security_group.netbox-priv.id
  ip_protocol                  = "tcp"
  from_port                    = 6379
  to_port                      = 6379
  description                  = "Redis"
}

# ECS → HTTPS (ECR, AWS APIs, ALB health checks, etc)
resource "aws_vpc_security_group_ingress_rule" "https_443" {
  security_group_id            = aws_security_group.netbox-priv.id
  referenced_security_group_id = aws_security_group.netbox-priv.id
  ip_protocol                  = "tcp"
  from_port                    = 443
  to_port                      = 443
  description                  = "HTTPS internal"
}

# Internet > ALB
resource "aws_vpc_security_group_ingress_rule" "http_traffic" {
  security_group_id         = aws_security_group.lb-traffic.id
  cidr_ipv4                 = "0.0.0.0/0"
  ip_protocol               = "tcp"
  from_port                 = 80
  to_port                   = 80
  description               = "HTTP from internet"
}


############################
# EGRESS
############################

resource "aws_vpc_security_group_egress_rule" "http" { 
  security_group_id = aws_security_group.netbox-priv.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
  description       = "HTTP"
}

resource "aws_vpc_security_group_egress_rule" "https" { 
  security_group_id = aws_security_group.netbox-priv.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  description       = "HTTPS"
}

resource "aws_vpc_security_group_egress_rule" "postgres_5432" { 
  security_group_id             = aws_security_group.netbox-priv.id
  referenced_security_group_id  = aws_security_group.netbox-priv.id
  ip_protocol                   = "tcp"
  from_port                     = 5432
  to_port                       = 5432
  description                   = "netbox to postgres"
}

resource "aws_vpc_security_group_egress_rule" "netbox_8080" {
  security_group_id             = aws_security_group.netbox-priv.id
  referenced_security_group_id  = aws_security_group.netbox-priv.id
  ip_protocol                   = "tcp"
  from_port                     = 8080
  to_port                       = 8080
  description                   = "netbox to ALB"
}

resource "aws_vpc_security_group_egress_rule" "redis_6379" {
  security_group_id             = aws_security_group.netbox-priv.id
  referenced_security_group_id  = aws_security_group.netbox-priv.id
  ip_protocol                   = "tcp"
  from_port                     = 6379
  to_port                       = 6379
  description                   = "netbox to redis"
}
