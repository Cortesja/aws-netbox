# Naming scheme for all aws ui display names use '-' (hyphen)
# All terraform resource naming use '_' (underscore)

#######################
# Application Load Balancer
#######################

resource "aws_lb" "netbox_lb" {
  name                = "netbox-alb"
  internal            = "false"
  load_balancer_type  = "application"
  security_groups     = [aws_security_group.netbox-priv.id, aws_security_group.lb_traffic.id]
  subnets             = [aws_subnet.public_1.id, aws_subnet.public_2.id] # public subnet
}

###################
# Target Group
###################

resource "aws_lb_target_group" "netbox_target" {
  name        = "netbox-target-group"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.netbox_vpc.id

  health_check {
    path = "/"
    matcher = "200-399" # we need 204
  }
}

###################
# Listener
###################

resource "aws_lb_listener" "front_end" {
  load_balancer_arn       = aws_lb.netbox_lb.arn
  port                    = 80
  protocol                = "HTTP"

  default_action {
    type              = "forward"
    target_group_arn  = aws_lb_target_group.netbox_target.arn
  }
}
