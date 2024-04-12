output "secret_name" {
  description = "Secret name."
  value       = aws_secretsmanager_secret.secret.name
}

output "secret_arn" {
  description = "Secret arn."
  value       = aws_secretsmanager_secret.secret.arn
}