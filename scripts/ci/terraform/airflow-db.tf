resource "aws_db_instance" "airflow-pg-db" {
allocated_storage          = "10"
engine                     = "postgres"
engine_version             = "9.4.4"
instance_class             = "db.t2.micro"
storage_type               = "gp2"
name                       = "airflow"
password                   = "root"
username                   = "root"
backup_retention_period    = "30"
backup_window              = "04:00-04:30"
maintenance_window         = "sun:04:30-sun:05:30"
auto_minor_version_upgrade = "false"
port                       = "5432"
storage_encrypted          = "false"
}

resource "aws_db_security_group" "default" {
  name = "rds_sg"

  ingress {
    cidr = "${aws_instance.airflow-web.*.public_ip}"
  }
}
