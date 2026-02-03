#######################
# Application Load Balancer
#######################

resource "aws_lb" "netbox-load" {
  name                = "netbox-load"
  internal            = "false"
  load_balancer_type  = "application"
  security_groups     = [aws_security_group.netbox-priv.id, aws_security_group.lb-traffic.id]
  subnets             = [aws_subnet.public-1.id, aws_subnet.public-2.id] # public subnet
}

###################
# Target Group
###################

resource "aws_lb_target_group" "netbox-target" {
  name        = "targets"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.netbox-vpc.id

  health_check {
    path = "/"
    matcher = "200-399"
  }
}

###################
# Listener
###################

resource "aws_lb_listener" "front-end" {
  load_balancer_arn       = aws_lb.netbox-load.arn
  port                    = 80
  protocol                = "HTTP"

  default_action {
    type              = "forward"
    target_group_arn  = aws_lb_target_group.netbox-target.arn
  }
}
