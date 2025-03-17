
resource "aws_alb" "myterra_lb" {
  name            = "myterra-load-balancer"
  subnets         = var.public_subnets
  security_groups = var.public_sg
  idle_timeout    = 400


}
resource "aws_alb_target_group" "mytera_target_gr" {
  name     = "myterra-lb-tg-${substr(uuid(), 0, 3)}"
  port     = var.tg_port
  protocol = var.tg_protocol
  vpc_id   = var.vpc_id
  lifecycle {
    ignore_changes        = [name]
    create_before_destroy = true
  }
  health_check {
    healthy_threshold   = var.lb_healthy_treshhold
    unhealthy_threshold = var.lb_unhealthy_treshold
    timeout             = var.lb_timeout
    interval            = var.lb_interval

  }

}


resource "aws_lb_listener" "myterra_listener" {
  load_balancer_arn = aws_alb.myterra_lb.arn
  port              = var.listener_port
  protocol          = var.listener_protocol
  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.mytera_target_gr.arn
  }
}