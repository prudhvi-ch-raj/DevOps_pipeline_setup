variable "region" {
  type    = string
  default = "us-east-1"
}

variable "vm_size" {
  type    = string
  default = "t2.micro"
}

variable "vm_username" {
  type    = string
  default = "ec2-user"   # correct default user for RHEL/Amazon Linux
}
