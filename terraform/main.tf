#VPC
resource "aws_vpc" "vijaya-vpc"{
    cidr_block = var.vpc_cidr
    enable_dns_support = true
    enable_dns_hostnames = true
    tags = {
      Name = "${var.project_name}-vpc"
    }
}
#Internet Gateway
resource "aws_internet_gateway" "vijaya-igw"{
    vpc_id = aws_vpc.vijaya-vpc.id
    tags = {
      Name = "${var.project_name}-igw"
    }
}
#EIP
resource "aws_eip" "vijaya-eip" {
  tags = {
    Name = "${var.project_name}-eip"
  }
}
#Public Subnet
resource "aws_subnet" "vijaya-public-subnet" {
    vpc_id = aws_vpc.vijaya-vpc.id
    cidr_block = var.public_subnet_cidr
    map_public_ip_on_launch = true
    availability_zone = "${var.region}b"
    tags = {
      Name = "${var.project_name}-public-subnet"
    }
}
#NAT gateway
resource "aws_nat_gateway" "vijaya-nat" {
  allocation_id =  aws_eip.vijaya-eip.id
  subnet_id = aws_subnet.vijaya-public-subnet.id
  depends_on = [aws_internet_gateway.vijaya-igw]
  tags = {
    Name = "${var.project_name}-nat"
  }
}
#Private Subnet
resource "aws_subnet" "vijaya-private-subnet" {
    count=length(var.private_subnet_cidrs)
    vpc_id = aws_vpc.vijaya-vpc.id
    cidr_block = var.private_subnet_cidrs[count.index]
    availability_zone = "${var.region}b"
    tags = {
        Name = "${var.project_name}-private-subnet-${count.index+1}"
    } 
}
#Public Route Table
resource "aws_route_table" "vijaya-public-rt" {
  vpc_id = aws_vpc.vijaya-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.vijaya-igw.id
  }
  tags = {
    Name = "${var.project_name}-public-rt"
  }
}
#association RT to subnet
resource "aws_route_table_association" "vijaya-rt-association" {
    subnet_id = aws_subnet.vijaya-public-subnet.id
    route_table_id = aws_route_table.vijaya-public-rt.id
  
}
#Private RT
resource "aws_route_table" "vijaya-private-rt" {
  vpc_id = aws_vpc.vijaya-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.vijaya-nat.id
  }
  tags = {
    Name = "${var.project_name}-private-RT"
  }
}
#associate to private subnet
resource "aws_route_table_association" "vijaya-private-rt-asso" {
    count = length(var.private_subnet_cidrs)
    subnet_id = aws_subnet.vijaya-private-subnet[count.index].id
    route_table_id = aws_route_table.vijaya-private-rt.id
  
}
# Security Group of Bastion Host(frontend)
resource "aws_security_group" "vijaya-frontend-sg" {
    name = "vijaya-frontend-sg"
    description = "security group for bastion host(vote+result)"
    vpc_id = aws_vpc.vijaya-vpc.id
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "for ssh"
    }
    ingress{
      from_port = 5001
      to_port = 5001
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "for accessing the frontend thru 5001 port"
    }
    ingress{
      from_port = 443
      to_port = 443
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "for HTTPS requests"
    }
    ingress{
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "for HTTP requests"
    }
    egress{
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      description = "for outbound traffic"
    }

    tags = {
        Name = "${var.project_name}-frontend-sg"
    }
  
}
#Security Groups for Backend
resource "aws_security_group" "vijaya-backend-sg" {
    name = "vijaya-backend-sg"
    description = "security groups for backend(redis+worker)"
    vpc_id = aws_vpc.vijaya-vpc.id
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        security_groups = [aws_security_group.vijaya-frontend-sg.id]
        description = "for sshing "
    }
    ingress {
        from_port = 6379
        to_port = 6379
        protocol = "tcp"
        security_groups = [aws_security_group.vijaya-frontend-sg.id]
        description = "to accessing the redis thru frontend"
    }
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        description = "for outbound traffic"

    } 

    tags = {
      Name = "${var.project_name}-backend-sg"
    }
  
}
#Security Group for Database
resource "aws_security_group" "vijaya-db-sg" {
    name = "vijaya-db-sg"
    description = "sg for backend (postreSQL)"
    vpc_id = aws_vpc.vijaya-vpc.id
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        security_groups = [aws_security_group.vijaya-frontend-sg.id]
        description = "sshing from bastion host"
    }
    ingress{
        from_port = 5432
        to_port = 5432
        protocol = "tcp"
        security_groups = [aws_security_group.vijaya-backend-sg.id]
        description = "for worker to access postgres"
    }
    ingress{
        from_port = 5432
        to_port = 5432
        protocol = "tcp"
        security_groups = [aws_security_group.vijaya-frontend-sg.id]
        description = "for the frontend to access postgres"
    }
    egress{
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        description = "from postgres to outside"
    }
    tags = {
        Name = "${var.project_name}-db-sg"
    }
}
#Create frontend instance(vote+result)
resource "aws_instance" "vijaya-frontend" {
  ami = var.ami_id
  instance_type = var.instance_type
  subnet_id = aws_subnet.vijaya-public-subnet.id
  key_name = var.key
  vpc_security_group_ids = [aws_security_group.vijaya-frontend-sg.id]
  tags = {
    Name = "${var.project_name}-frontend-b"
  }
}
#Create backend instance(worker+redis)
resource "aws_instance" "vijaya-backend" {
    ami = var.ami_id
    instance_type = var.instance_type
    subnet_id = aws_subnet.vijaya-private-subnet[0].id
    key_name = var.key
    vpc_security_group_ids = [aws_security_group.vijaya-backend-sg.id]
    tags = {
      Name = "${var.project_name}-backend-b"
    }
      
}
#Create db instance(postreSQL)
resource "aws_instance" "vijaya-db"{
    ami = var.ami_id
    instance_type = var.instance_type
    subnet_id = aws_subnet.vijaya-private-subnet[1].id
    key_name = var.key
    vpc_security_group_ids = [aws_security_group.vijaya-db-sg.id]
    tags = {
      Name = "${var.project_name}-db-b"
    }
}