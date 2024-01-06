

provider "aws" {
    region     = "${var.region}"
    access_key = "${var.AWS_ACCESS_KEY}"
    secret_key = "${var.AWS_SECRET_KEY}"
}

# rds

resource "aws_rds_cluster"  "petrovic_rds"{
    cluster_identifier = "petrovic-postgres-cluster"
    engine = "aurora-postgresql"
    engine_version = "15.4"
    master_username = "${var.rds_master_username}"
    master_password = "${var.rds_master_password}"
    backup_retention_period = 5
    preferred_backup_window = "07:00-09:00"
    skip_final_snapshot = true
}

resource "aws_rds_cluster_instance" "petrovic_rds" {
    count = 2
    identifier = "petrovic-postgres-cluster-${count.index}"
    cluster_identifier = aws_rds_cluster.petrovic_rds.id
    instance_class = "${var.rds_instance_type}"
    engine = aws_rds_cluster.petrovic_rds.engine
    engine_version = aws_rds_cluster.petrovic_rds.engine_version
    publicly_accessible = true
}



# sqs 
resource "aws_sqs_queue" "petrovic_queue" {
  name                      = "petrovic_queue"
  delay_seconds             = 90
  max_message_size          = 2048
  message_retention_seconds = 86400
  receive_wait_time_seconds = 10
  tags = {
    Environment = "petrovic"
  }
}
