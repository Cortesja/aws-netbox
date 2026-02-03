####################
# Django SECRET_KEY
####################

# Will have to change the name that goes in the second argument here.
# After every terraform destory the name used here will be a secret marked for deletion.
# Same for the db-passwd as well.
data "aws_secretsmanager_random_password" "django_secret" {
  password_length = 50
  exclude_numbers = true
}

resource "aws_secretsmanager_secret" "django_secret" {
  name = "django_secret"
}

resource "aws_secretsmanager_secret_version" "django_secret" {
  secret_id = aws_secretsmanager_secret.django_secret.id
  secret_string = jsonencode({
    username = "netbox"
    password = data.aws_secretsmanager_random_password.django_secret.random_password})
}

####################
# db-passwd
####################

resource "aws_secretsmanager_secret" "db_password" {
  name = "db_password"
}

data "aws_secretsmanager_random_password" "db_password" {
  password_length = 32
  exclude_numbers = true
  exclude_punctuation = true
}

resource "aws_secretsmanager_secret_version" "db_password" {
  secret_id     = aws_secretsmanager_secret.db_password.id
  secret_string = jsonencode({
    username = "netbox"
    password = data.aws_secretsmanager_random_password.db_password.random_password})
}

locals {
  # RDS postgesql DB credentials 
  db_creds = jsondecode(aws_secretsmanager_secret_version.db_password.secret_string)
  # Django session django_secret, username + password, jsonenconded.
  django_creds = jsondecode(aws_secretsmanager_secret_version.django_secret.secret_string)
  # netbox-version
  nb_image = "docker.io/netboxcommunity/netbox:v4.3-3.3.0"
}
