
variable "region" {
    description = "AWS region"
    type=string
}
# no need use 
# export AWS_ACCESS_KEY_ID=
# export AWS_SECRET_ACCESS_KEY=
#variable "AWS_ACCESS_KEY" {
#    description = "AWS ACCESS KEY"
#    type=string
#}

#variable "AWS_SECRET_KEY" {
#    description = "AWS SECRET KEY"
#    type=string
#}

variable "rds_instance_type" {
    description = "AWS region"
}

variable "rds_master_username" {
    description = "rds master username"
}

variable "rds_master_password" {
    description = "rds master password"
}


variable "ec2" {
  description = "The attribute of EC2 information"
  type = object({
    name              = string
    os_type           = string
    instance_type     = string
    volume_size       = number
    volume_type       = string
    availability_zone = string
  })
}

variable "security_groups" {
  description = "The attribute of security_groups information"
  type = list(object({
    name        = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
}