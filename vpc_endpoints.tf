####################
# ECR endpoints
####################
#
#resource "aws_vpc_endpoint" "ecr-api" {
#  vpc_id              = aws_vpc.netbox-vpc.id
#  service_name        = "com.amazonaws.ap-northeast-1.ecr.api"
#  private_dns_enabled = true
#  vpc_endpoint_type   = "Interface"
#}
#
#resource "aws_vpc_endpoint" "ecr-dkr" {
#  vpc_id              = aws_vpc.netbox-vpc.id
#  service_name        = "com.amazonaws.ap-northeast-1.ecr.dkr"
#  private_dns_enabled = true
#  vpc_endpoint_type   = "Interface"
#}
#
#resource "aws_vpc_endpoint" "ecr-s3" {
#  vpc_id            = aws_vpc.netbox-vpc.id
#  service_name      = "com.amazonaws.ap-northeast-1.s3"
#  vpc_endpoint_type = "Gateway"
#}
