resource "aws_security_group" "sg" {
  name        = "${var.name}-${var.env}-sg"
  description = "${var.name}-${var.env}-sg"
  vpc_id      = var.vpc_id

  # access these for only app subnets
  ingress {
    description = "rds"
    from_port   = var.port
    to_port     = var.port
    protocol    = "tcp"
    cidr_blocks = var.allow_db_cidr
  }

  # outside access
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(var.tags, { Name = "${var.name}-${var.env}-sg" })
}

resource "aws_db_subnet_group" "subnet-group" {
  name       = "${var.name}-${var.env}-subnet-group"
  subnet_ids = var.subnet_ids

  tags = merge(var.tags, { Name = "${var.name}-${var.env}-subnet-group" })
}

resource "aws_db_parameter_group" "param-group" {
  name   = "${var.name}-${var.env}-param-group"
  family = "aurora-mysql5.7"
  tags = merge(var.tags, { Name = "${var.name}-${var.env}-param-group" })
}

resource "aws_rds_cluster" "cluster" {
  cluster_identifier      = "${var.name}-${var.env}-cluster"
  engine                  = "aurora-mysql"
  engine_version          = var.engine_version
  database_name           = "dummy"
  master_username         = data.aws_ssm_parameter.db_user
  master_password         = data.aws_ssm_parameter.db_password
  backup_retention_period = 5
  preferred_backup_window = "07:00-09:00"
  db_subnet_group_name    = aws_db_subnet_group.subnet-group.name
  vpc_security_group_ids  = [aws_security_group.sg.id]
  skip_final_snapshot     = true
  tags                    = merge(var.tags, { Name = "${var.name}-${var.env}-cluster" })
}

resource "aws_rds_cluster_instance" "cluster_instances" {
  count                   = var.instance_count
  identifier              = "aurora-cluster-${count.index + 1}"
  cluster_identifier      = aws_rds_cluster.cluster.id
  instance_class          = var.instance_class
  engine                  = aws_rds_cluster.cluster.engine
  engine_version          = aws_rds_cluster.cluster.engine_version
  db_subnet_group_name    = aws_db_subnet_group.subnet-group.name
  db_parameter_group_name = aws_db_parameter_group.param-group.name
  tags                    = merge(var.tags, { Name = "${var.name}-${var.env}-cluster-instance" })
}