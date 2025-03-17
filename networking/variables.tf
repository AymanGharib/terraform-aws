variable "vpc_cidr" {

}
variable "public_cidrs" {
  type = list(any)
}
variable "private_cidrs" {
  type = list(any)
}
variable "public_sn_count" {

}
variable "private_sn_count" {

}
variable "max_subnets" {

}
variable "access_ip" {
  type = string
}

variable "db_subnet_grp" {
  type = bool
}