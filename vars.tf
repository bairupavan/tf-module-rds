variable "env" {}
variable "name" {
  default = "rds"
}
variable "vpc_id" {}
variable "subnet_ids" {}
variable "tags" {}
variable "allow_db_cidr" {}
variable "port" {
  default = 3306
}
variable "engine_version" {}
variable "instance_count" {}
variable "instance_class" {}

