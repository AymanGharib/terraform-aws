 locals {
  vpc_cidr = "10.123.0.0/16"
}







module "networking" {
  source           = "./networking"
  vpc_cidr         = local.vpc_cidr
  public_sn_count  = 2
  private_sn_count = 2
  public_cidrs     = [for i in range(2, 10, 2) : cidrsubnet("10.123.0.0/16", 8, i)]
  private_cidrs    = [for i in range(1, 10, 2) : cidrsubnet("10.123.0.0/16", 8, i)]
  max_subnets      = 5
  access_ip        = var.access_ip
  db_subnet_grp    = true
}


module "datbase" {
  source                 = "./database"
  db_engine_version      = "5.7.22"
  db_instance_class      = "db.t2.micro"
  dbname                 = var.db_name
  dbuser                 = var.db_user
  dbpassword             = var.db_password
  db_identifier          = "myterra-db"
  skip_db_snapshot       = true
  db_subnet_group_name   = module.networking.db_subnet_group_name[0]
  vpc_security_group_ids = module.networking.db_security_group


}


module "loadbalancing" {
  source                = "./loadbalacing"
  public_sg             = module.networking.public_sg
  public_subnets        = module.networking.public_subnets
  tg_port               = 8000
  tg_protocol           = "HTTP"
  vpc_id                = module.networking.vpc_id
  lb_healthy_treshhold  = 2
  lb_unhealthy_treshold = 2
  lb_interval           = 20
  lb_timeout            = 3
  listener_port         = 80
  listener_protocol     = "HTTP"

}

module "compute" {
  source = "./compute"
  instance_count = 1 
  instace_type  =  "t2.micro"
  public_sg = module.networking.public_sg
  public_subnets = module.networking.public_subnets
  vol_size =  8
  key_name = "myterra-key"

  public_key_path  = "${path.module}/id_rsa.pub"

  user_data_path = "${path.module}/userdata.tpl"
  
  dbname                 = var.db_name
  db_user                = var.db_user
  db_pass             = var.db_password 
  db_endpoint  = module.datbase.db_endpoint
  lb_target_group_arn = module.loadbalancing.lb_tg_arn


}




 