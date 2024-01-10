#terraform.tfvars
region = "us-west-2"
rds_instance_type = "db.r5.large"
rds_master_username = "mandomauser"
rds_master_password =  "mandomapassword"


ec2 = {
  instance_type     = "t2.micro"
  name              = "petrovic"
  os_type           = "linux"
  volume_size       = 20
  volume_type       = "gp3"
  availability_zone = "us-west-2a"
}

security_groups = [{
  from_port   = 22
  name        = "Office Wifi CIDR Range"
  protocol    = "tcp"
  to_port     = 22
  cidr_blocks = ["0.0.0.0/0"] # you can replace with your office wifi outbount IP range
  }, {
  from_port   = 80
  name        = "NGINX Port"
  protocol    = "tcp"
  to_port     = 80
  cidr_blocks = ["0.0.0.0/0"]
}]
