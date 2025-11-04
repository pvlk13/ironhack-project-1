resource "aws_instance" "neeha_frontend" {
  ami                    = "ami-043df19be943e03b6"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.vote_result_sg.id]

  tags = {
    Name        = "neeha_frontend"
    Environment = "dev"
    Owner       = "Nalband"
  }
}


resource "aws_instance" "neeha_backend" {
  ami             = "ami-043df19be943e03b6"
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.private_b.id
  security_groups = [aws_security_group.redis_worker_sg.id]
  tags = {
    Name        = "neeha_backend"
    Environment = "dev"
    Owner       = "Nalband"
  }
}

resource "aws_instance" "neeha_database" {
  ami                    = "ami-043df19be943e03b6"
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.private_c.id
  vpc_security_group_ids = [aws_security_group.postgres_sg.id]

  tags = {
    Name        = "neeha_database"
    Environment = "dev"
    Owner       = "Nalband"
  }
}