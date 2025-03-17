output "lb_endpoint" {
  value =  module.loadbalancing.lb_endpoint
}

output "instaces" {
  value = {for i in module.compute : i.tags.Name => i.public_ip}
  sensitive = true

}



