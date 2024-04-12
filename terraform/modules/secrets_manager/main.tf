resource "aws_secretsmanager_secret" "secret" {
  name                           = var.secret_name
  force_overwrite_replica_secret = true
  tags                           = var.tags
  dynamic "replica" {
    for_each = var.replication_regions
    content {
      region = replica.key
    }
  }
}

resource "aws_secretsmanager_secret_policy" "secret_policy" {
  secret_arn = aws_secretsmanager_secret.secret.arn
  policy     = var.secret_policy
}



resource "aws_secretsmanager_secret_version" "splunk_api_token" {
  secret_id     = aws_secretsmanager_secret.secret.id
  secret_string = var.secret_value
}
