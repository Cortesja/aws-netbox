# Naming scheme for all aws ui display names use '-' (hyphen)
# All terraform resource naming use '_' (underscore)

######################
# Subnet Group
######################

resource "aws_db_subnet_group" "netbox" {
  name        = "netbox-db-subnets"
  subnet_ids  = aws_subnet.private[*].id

  tags = { Name = "netbox-db-subnets" }
}

###############
# Database ####
###############

# Use existing parameter group to disable ssl
data "aws_db_parameter_group" "db_parameter_group" {
  name      = "disable-ssl-postgres17"
}

resource "aws_db_instance" "netbox_rds" {
  identifier                  = "netbox-database"
  allocated_storage           = 20
  db_name                     = "netboxdb"
  engine                      = "postgres"
  engine_version              = "17"
  instance_class              = "db.t4g.small"
  storage_type                = "gp3"

  username                    = local.db_creds.username
  password                    = local.db_creds.password
  port                        = 5432
  skip_final_snapshot         = true

  db_subnet_group_name        = aws_db_subnet_group.netbox.name
  vpc_security_group_ids      = [aws_security_group.netbox_internal.id]
  parameter_group_name        = data.aws_db_parameter_group.db_parameter_group.name

  ### Multi-zone
  multi_az                    = true

  ##################
  # Backup settings
  ##################

  backup_retention_period     = 7
  backup_window               = "13:00-14:00"
  copy_tags_to_snapshot       = true
  maintenance_window          = "Sun:00:00-Sun:03:00"

  deletion_protection         = false

  storage_encrypted           = true
  kms_key_id                  = data.aws_kms_key.rds.arn
}
