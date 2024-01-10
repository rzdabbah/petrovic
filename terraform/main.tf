
provider "aws" {
    region     = "${var.region}"
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

#ec2 instance

variable "linux_ami" {
  description = "linux ami"
  type        = string
  default     = "ami-0de43e61758b7158c"
}


# my ip
data "http" "laptop_outbound_ip" {
  url = "http://ipv4.icanhazip.com"
}

resource "aws_security_group" "sg_petrovic" {
  description = "petrovic sg for terraform"
  vpc_id      = "vpc-d833bfbd"
  ingress {
    description = "Laptop Outbount IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.laptop_outbound_ip.body)}/32"]
  }
  dynamic "ingress" {
    for_each = var.security_groups
    content {
      description = ingress.value["name"]
      from_port   = ingress.value["from_port"]
      to_port     = ingress.value["to_port"]
      protocol    = ingress.value["protocol"]
      cidr_blocks = ingress.value["cidr_blocks"]
    }
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_instance" "instance" {
  ami                         = var.linux_ami 
  availability_zone           = var.ec2.availability_zone
  instance_type               = var.ec2.instance_type
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.sg_petrovic.id]
  #subnet_id                   = aws_subnet.main.id
  #key_name                    = aws_key_pair.deployer.id
  root_block_device {
    delete_on_termination = true
    encrypted             = false
    volume_size           = var.ec2.volume_size
    volume_type           = var.ec2.volume_type
  }
  user_data = file("templates/${var.ec2.os_type}.sh")
}