
data "aws_availability_zones" "available" {

}


resource "random_shuffle" "list_azs" {
  input        = data.aws_availability_zones.available.names
  result_count = var.max_subnets

}





resource "random_integer" "random" {
  min = 1
  max = 100

}

resource "aws_vpc" "terra-vpc" {

  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true



  tags = {


    Name = "myterra-${random_integer.random.id}"
  }

  lifecycle {
    create_before_destroy = true
  }



}

resource "aws_subnet" "terra-pub-sub" {

  count                   = var.public_sn_count
  vpc_id                  = aws_vpc.terra-vpc.id
  cidr_block              = var.public_cidrs[count.index]
  map_public_ip_on_launch = true
  availability_zone       = random_shuffle.list_azs.result[count.index]


  tags = {

    Name = "terra-public-${count.index + 1}"
  }
}

resource "aws_route_table_association" "association" {
  count     = var.public_sn_count
  subnet_id = aws_subnet.terra-pub-sub.*.id[count.index]

  route_table_id = aws_route_table.myterra_public_rt.id
}






resource "aws_subnet" "terra-private-sub" {

  count                   = var.private_sn_count
  vpc_id                  = aws_vpc.terra-vpc.id
  cidr_block              = var.private_cidrs[count.index]
  map_public_ip_on_launch = false
  availability_zone       = random_shuffle.list_azs.result[count.index]


  tags = {

    Name = "terra-private-${count.index + 1}"
  }
}


resource "aws_internet_gateway" "igw" {

  vpc_id = aws_vpc.terra-vpc.id




}

resource "aws_route_table" "myterra_public_rt" {
  vpc_id = aws_vpc.terra-vpc.id

  tags = {
    Name = "myterra-route"
  }
}

resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.myterra_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id

}
resource "aws_default_route_table" "default_route_table" {
  default_route_table_id = aws_vpc.terra-vpc.default_route_table_id




}


resource "aws_security_group" "myterra_sg" {
  name        = "myterra_sg"
  description = "Allow SSH and all outbound traffic"
}
resource "aws_security_group" "rds_sg" {
  name        = "db sg"
  description = "Allow connection to the db"


}

resource "aws_security_group_rule" "rds_access" {
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  cidr_blocks       = [var.vpc_cidr] # Ensure var.access_ip is a valid CIDR string (e.g., "192.168.1.1/32")
  security_group_id = aws_security_group.myterra_sg.id
}






# Ingress rule for SSH
resource "aws_security_group_rule" "ssh_access" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [var.access_ip] # Ensure var.access_ip is a valid CIDR string (e.g., "192.168.1.1/32")
  security_group_id = aws_security_group.myterra_sg.id
}


resource "aws_security_group_rule" "http_access" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = [var.access_ip] # Ensure var.access_ip is a valid CIDR string (e.g., "192.168.1.1/32")
  security_group_id = aws_security_group.myterra_sg.id
}











# Egress rule allowing all outbound traffic
resource "aws_security_group_rule" "all_outbound" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.myterra_sg.id
}



resource "aws_db_subnet_group" "myterra_rds_subnet_grp" {
  count = var.db_subnet_grp == true ? 1 : 0
  name  = "my_terra_rds_subnet_grp"

  subnet_ids = aws_subnet.terra-private-sub[*].id
  tags = {

    Name = "my_terra_subnet_grp"
  }

}

