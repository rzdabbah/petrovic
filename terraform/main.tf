
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
    cidr_blocks = ["${chomp(data.http.laptop_outbound_ip.response_body)}/32"]
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

data "aws_iam_policy_document" "instance_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com","sqs.amazonaws.com","ecr.amazonaws.com"]
    }
  }
}
resource "aws_iam_role" "worker_role" {
  name               = "worker_role"
  path               = "/system/"
  assume_role_policy = data.aws_iam_policy_document.instance_assume_role_policy.json

  inline_policy {
    name = "my_inline_policy"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action   = ["ecr:*","sqs:*"]
          Effect   = "Allow"
          Resource = "*"
        },
      ]
    })
  }
}


resource "aws_iam_role_policy_attachment" "example_attachment" {
  role       = aws_iam_role.worker_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

resource "aws_iam_instance_profile" "worker_profile" {
  name = "worker_profile"
  role = aws_iam_role.worker_role.name
}

data "aws_ecr_repository" "petrovic" {
  name = "petrovic"
}
data "aws_ecr_image" "service_image" {
  repository_name = "petrovic"
  image_tag       = "latest"
}
resource "aws_instance" "petrovic_worker_instance" {
  ami                         = var.linux_ami 
  availability_zone           = var.ec2.availability_zone
  instance_type               = var.ec2.instance_type
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.sg_petrovic.id]
  #subnet_id                  = aws_subnet.main.id
  #key_name                   = aws_key_pair.deployer.id
  iam_instance_profile        = aws_iam_instance_profile.worker_profile.name

  root_block_device {
    delete_on_termination = true
    encrypted             = false
    volume_size           = var.ec2.volume_size
    volume_type           = var.ec2.volume_type
  }
  user_data = templatefile("templates/docker_run.tftpl", { 
    ECR_REPO_URL= data.aws_ecr_repository.petrovic.repository_url, 
    IMAGE_NAME = "petrovic" ,
    QUEUE_URL = aws_sqs_queue.petrovic_queue.url,
    DB_HOST=join("", aws_rds_cluster.petrovic_rds[*].endpoint) ,
    DB_DBNMAE="postgres",
    DB_USERNMAE=var.rds_master_username,
    DB_USERPASSWORD=var.rds_master_password
})
  user_data_replace_on_change = true
}
output "user_data" {
  value = aws_instance.petrovic_worker_instance.user_data
}

output "queue_url" {
  value = aws_sqs_queue.petrovic_queue.url
}

output "laptop_outbound_ip"{
  value = data.http.laptop_outbound_ip.response_body
}
output "rds_endpoint" {
  value       =  join("", aws_rds_cluster.petrovic_rds[*].endpoint) 
  description = "The DNS address of the RDS instance"
}