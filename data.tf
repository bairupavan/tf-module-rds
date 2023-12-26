data "aws_ssm_parameter" "db_user" {
  name  = "${var.env}.${var.name}.db_user"
}

data "aws_ssm_parameter" "db_password" {
  name = "${var.env}.${var.name}.db_password"
}