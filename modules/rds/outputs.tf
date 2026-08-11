output "endpoint" {
  description = "Connection endpoint"
   value       = aws_db_instance.this.endpoint
}

output "address" {
  description = "Hostname "
  value       = aws_db_instance.this.address
}

output "port" {
  value = aws_db_instance.this.port
}

output "db_name" {
  value = aws_db_instance.this.db_name
}

output "master_user_secret_arn" {
  description = "Secrets Manager ARN holding the auto-generated master credentials."
  value       = aws_db_instance.this.master_user_secret[0].secret_arn
}
