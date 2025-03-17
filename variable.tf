variable "aws_region" {
  default = "us-east-1"
}
variable "access_ip" {
  type = string
}
variable "db_user" {
  sensitive = true
}
variable "db_name" {
  sensitive = true
}
variable "db_password" {
  sensitive = true
}