output "lb_tg_arn" {
  

  value = aws_alb_target_group.mytera_target_gr.arn
}
output "lb_endpoint" {
  value = aws_alb.myterra_lb.dns_name
}

