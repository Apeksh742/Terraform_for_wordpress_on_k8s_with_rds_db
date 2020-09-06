resource "aws_db_instance" "DataBase" {
  allocated_storage    = 20
  max_allocated_storage = 100
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7.28"
  instance_class       = "db.t2.micro"
  name                 = var.mysql_db_name
  username             = var.mysql_username
  password             = var.mysql_password
  parameter_group_name = "default.mysql5.7"
  publicly_accessible = true
  skip_final_snapshot = true 

}

