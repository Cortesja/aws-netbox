# Naming scheme for all aws ui display names use '-' (hyphen)
# All terraform resource naming use '_' (underscore)

#######################
# Application Load Balancer
#######################

resource "aws_lb" "netbox_lb" {
  name                = "netbox-alb"
  internal            = "false"
  load_balancer_type  = "application"
  security_groups     = [data.terraform_remote_state.core.outputs.sg, data.terraform_remote_state.core.outputs.sg_alb]
  subnets             = data.terraform_remote_state.core.outputs.public_subnet_ids
}

###################
# Target Group
###################

resource "aws_lb_target_group" "netbox_target" {
  name        = "netbox-target-group"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = data.terraform_remote_state.core.outputs.vpc

  health_check {
    path = "/login/"
    matcher = "200" # we need 204
    interval = 60
  }
}

###################
# Listener
###################

resource "aws_lb_listener" "front_end" {
  load_balancer_arn       = aws_lb.netbox_lb.arn
  port                    = 443
  protocol                = "HTTPS"
  # ssl_policy            = # Default it ELBSecurityPolicy-2016-08
  certificate_arn         = data.aws_acm_certificate.netbox_dev.arn

  default_action {
    type              = "forward"
    target_group_arn  = aws_lb_target_group.netbox_target.arn
  }
}
