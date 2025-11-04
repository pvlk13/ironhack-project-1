output "frontend_public_ip" {
  value = aws_instance.neeha_frontend.public_ip
}
output "backend_private_ip" {
  value = aws_instance.neeha_backend.private_ip
}

output "database_private_ip" {
  value = aws_instance.neeha_database.private_ip
}
