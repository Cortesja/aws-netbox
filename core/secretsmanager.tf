# Naming Scheme for AWS Secrets Manager items is '_'
# django_secret (note the underscore)

####################
# Django SECRET_KEY
####################

# Will have to change the name that goes in the second argument here.
# After every terraform destory the name used here will be a secret marked for deletion.
# Same for the db-passwd as well.
data "aws_secretsmanager_random_password" "django_secret_key" {
  password_length = 50
  exclude_numbers = true
}

resource "aws_secretsmanager_secret" "django_secret_key" {
  name = "netbox_django_secret"
}

resource "aws_secretsmanager_secret_version" "django_secret_key" {
  secret_id = aws_secretsmanager_secret.django_secret_key.id
  secret_string = jsonencode({
    username = "netbox"
    password = data.aws_secretsmanager_random_password.django_secret_key.random_password})
}

####################
# db-passwd
####################

resource "aws_secretsmanager_secret" "database_passwd" {
  name = "netbox_db_passwd"
}

data "aws_secretsmanager_random_password" "database_passwd" {
  password_length = 32
  exclude_numbers = true
  exclude_punctuation = true
}

resource "aws_secretsmanager_secret_version" "database_passwd" {
  secret_id     = aws_secretsmanager_secret.database_passwd.id
  secret_string = jsonencode({
    username = "netbox"
    password = data.aws_secretsmanager_random_password.database_passwd.random_password})
}

######################
# SUPERUSER PASSWORD
######################

resource "aws_secretsmanager_secret" "superuser_creds" {
  name = "netbox_superuser_creds"
}

data "aws_secretsmanager_random_password" "superuser_creds" {
  password_length = 16
  exclude_punctuation = true
}

resource "aws_secretsmanager_secret_version" "superuser_creds" {
  secret_id     = aws_secretsmanager_secret.superuser_creds.id
  secret_string = jsonencode({
    username = "admin"
    password = data.aws_secretsmanager_random_password.superuser_creds.random_password})
}
