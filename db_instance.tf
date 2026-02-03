######################
# Subnet Group
######################

resource "aws_db_subnet_group" "netbox" {
  name        = "netbox-db-subnets"
  subnet_ids = [
    aws_subnet.private-1.id,
    aws_subnet.private-2.id
  ]

  tags = {
    Name = "netbox-db-subnets"
  }
}

###############
# Database ####
###############

resource "aws_db_parameter_group" "force_ssl" {
  name    = "rds"
  family  = "postgres17"

  parameter {
    name    = "rds.force_ssl"
    value   = "0"
  }
}

resource "aws_db_instance" "netbox-rds" {
  allocated_storage           = 20
  db_name                     = "netboxdb"
  engine                      = "postgres"
  engine_version              = "17"
  instance_class              = "db.t3.micro"
  storage_type                = "gp3"

  username                    = local.db_creds.username
  password                    = local.db_creds.password
  port                        = 5432
  skip_final_snapshot         = true

  db_subnet_group_name        = aws_db_subnet_group.netbox.name
  vpc_security_group_ids      = [aws_security_group.netbox-priv.id]
  parameter_group_name        = aws_db_parameter_group.force_ssl.name
}
