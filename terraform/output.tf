output "frontend_public_ip" {
  value = aws_instance.vijaya-frontend.public_ip
}

output "backend_private_ip" {
  value = aws_instance.vijaya-backend.private_ip
}

output "db_private_ip" {
  value = aws_instance.vijaya-db.private_ip
}
