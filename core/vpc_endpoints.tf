####################
# ECR endpoints
####################

#resource "aws_vpc_endpoint" "ecr-api" {
#  vpc_id              = aws_vpc.netbox_vpc.id
#  service_name        = "com.amazonaws.ap-northeast-1.ecr.api"
#  vpc_endpoint_type   = "Interface"
# 
#  subnet_ids          = aws_subnet.private[*].id
#  security_group_ids  = [ aws_security_group.netbox_internal.id ]
#  private_dns_enabled = true
#}
#
#resource "aws_vpc_endpoint" "ecr-dkr" {
#  vpc_id              = aws_vpc.netbox_vpc.id
#  service_name        = "com.amazonaws.ap-northeast-1.ecr.dkr"
#  vpc_endpoint_type   = "Interface"
#
#  subnet_ids          = aws_subnet.private[*].id
#  security_group_ids  = [ aws_security_group.netbox_internal.id ]
#  private_dns_enabled = true
#}
#
################
## Logs
################
#
#resource "aws_vpc_endpoint" "logs" {
#  vpc_id            = aws_vpc.netbox_vpc.id
#  service_name      = "com.amazonaws.ap-northeast-1.logs"
#  vpc_endpoint_type = "Interface"
#
#  subnet_ids          = aws_subnet.private[*].id
#  security_group_ids = [ aws_security_group.netbox_internal.id ]
#  private_dns_enabled = true
#}
#
####################
## Secrets Manager
####################
#
#resource "aws_vpc_endpoint" "secrets" {
#  vpc_id              = aws_vpc.netbox_vpc.id
#  service_name        = "com.amazonaws.ap-northeast-1.secretsmanager"
#  vpc_endpoint_type   = "Interface"
#
#  subnet_ids          = aws_subnet.private[*].id
#  security_group_ids  = [ aws_security_group.netbox_internal.id ]
#  private_dns_enabled = true
#}
#
#####################
## S3 Bucket Endpoint
#####################
#
#resource "aws_vpc_endpoint" "ecr-s3" {
#  vpc_id            = aws_vpc.netbox_vpc.id
#  service_name      = "com.amazonaws.ap-northeast-1.s3"
#  vpc_endpoint_type = "Gateway"
#  security_group_ids  = [ aws_security_group.netbox_internal.id ]
#}
