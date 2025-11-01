variable "project_name"{
    description = "name of project"
    type = string 
    default = "vijaya-terraform-microS"
}
variable "key"{
    description = "key for auth purpose"
    type = string
    default = "vijaya-key-cloudwatch"
}
variable "region"{
    description = "region available"
    type = string
    default = "us-west-2"
}
variable "vpc_cidr" {
  description = "cidr for vpc"  
  type = string
  default = "30.0.0.0/16"

}
variable "public_subnet_cidr" {
  description = "public subnet cidr"  
  type = string
  default = "30.0.1.0/24"
}

variable "private_subnet_cidrs" {
    description = "list of private subnet cidrs"
    type = list(string)
    default = [ "30.0.101.0/24","30.0.102.0/24" ]
}

variable "az_count" {
 description = "number of available zones"
 type = number
 default = 1
}

variable "enable_nat_gateway" {
  description = "nat gateway present or not"  
  type = bool
  default = true
}

variable "allowed_ssh_cidrs" {
    description = "cidrs to be allowed to SSH to bastion"
    type = list(string)
    default = [ "0.0.0.0/0" ]
  
}
variable "tags" {
    description = "basic info about project"
    type = string
    default = "vijaya-terraform-ms"
  
}
variable "instance_type" {
    description = "EC2 instance type"
    type = string
    default = "t3.micro"
}
variable "ami_id" {
   description = "ami ID for EC2 instance"
   type = string
   default = "ami-06d455b8b50b0de4d"
}