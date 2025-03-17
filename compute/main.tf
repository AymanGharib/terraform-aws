data "aws_ami" "server_ami" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]

  }


}
resource "random_id" "myterra_node_id" {
   count = var.instance_count
  byte_length = 4
keepers = {
key_name  = var.key_name
}
} 
 resource "aws_instance" "name" {
  count = var.instance_count

   instance_type = var.instace_type
   ami = data.aws_ami.server_ami.id
   tags = {
   
Name  = "myterra-node-${random_id.myterra_node_id[count.index].dec}"



   }



   vpc_security_group_ids = var.public_sg

   subnet_id =  var.public_subnets[count.index]
   user_data = templatefile(var.user_data_path, {


nodename  = "myterra-node-${random_id.myterra_node_id[count.index].dec}"
dbuser  = var.db_user
dbpass =  var.db_pass
db_endpoint  = var.db_endpoint
dbname =  var.dbname

   } )
   root_block_device {
     volume_size = var.vol_size
   }
}

resource "aws_key_pair" "ssh_auth" {
    public_key = file(var.public_key_path)
    key_name = var.key_name
  
}



resource "aws_lb_target_group_attachment" "myterra_target_attach" {
  
count = var.instance_count

target_group_arn = var.lb_target_group_arn

target_id = aws_instance.name[count.index].id

port = 8000




}


