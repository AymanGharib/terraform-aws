output "vpc_id" {
  value = aws_vpc.terra-vpc.id
}

output "db_subnet_group_name" {
  value = aws_db_subnet_group.myterra_rds_subnet_grp[*].name
}

output "db_security_group" {
  value = [aws_security_group_rule.rds_access.id]
}

output "public_sg" {
  value = [aws_security_group.myterra_sg.id]
}

output "public_subnets" {
  value = aws_subnet.terra-pub-sub[*].id

}