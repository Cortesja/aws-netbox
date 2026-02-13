# Naming Scheme for AWS Secrets Manager items is '_'
# session_secret_key (note the underscore)

####################
# Django SECRET_KEY
####################

# Will have to change the name that goes in the second argument here.
# After every terraform destory the name used here will be a secret marked for deletion.
# Same for the db-passwd as well.

# Django secret key
data "aws_secretsmanager_random_password" "session_secret_key" {
  password_length = 50
  exclude_numbers = true
}

resource "aws_secretsmanager_secret" "session_secret_key" {
  name = "netbox_django_key"
}

resource "aws_secretsmanager_secret_version" "session_secret_key" {
  secret_id = aws_secretsmanager_secret.session_secret_key.id
  secret_string = jsonencode({
    username = "netbox"
    password = data.aws_secretsmanager_random_password.session_secret_key.random_password})
}

####################
# db-passwd
####################

resource "aws_secretsmanager_secret" "datab_password" {
  name = "netbox_datab_creds"
}

data "aws_secretsmanager_random_password" "datab_password" {
  password_length = 32
  exclude_numbers = true
  exclude_punctuation = true
}

resource "aws_secretsmanager_secret_version" "datab_password" {
  secret_id     = aws_secretsmanager_secret.datab_password.id
  secret_string = jsonencode({
    username = "netbox"
    password = data.aws_secretsmanager_random_password.datab_password.random_password})
}

######################
# SUPERUSER PASSWORD
######################

resource "aws_secretsmanager_secret" "admin_creds" {
  name = "netbox_admin_creds"
}

data "aws_secretsmanager_random_password" "admin_creds" {
  password_length = 16
  exclude_punctuation = true
}

resource "aws_secretsmanager_secret_version" "admin_creds" {
  secret_id     = aws_secretsmanager_secret.admin_creds.id
  secret_string = jsonencode({
    username = "admin"
    password = data.aws_secretsmanager_random_password.admin_creds.random_password})
}
