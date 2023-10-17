resource "aws_s3_bucket" "backend" {
  count = terraform.workspace == "default" ? 1 : 0

  bucket_prefix = "terraform-backend"

  tags = {
    Name        = "Terraform Backend"
    Environment = terraform.workspace
  }
}

output "backend_bucket_name" {
  value = aws_s3_bucket.backend.0.id
}

resource "aws_s3_bucket_versioning" "backend" {
  count = terraform.workspace == "default" ? 1 : 0

  bucket = aws_s3_bucket.backend.0.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "backend" {
  count = terraform.workspace == "default" ? 1 : 0

  bucket = aws_s3_bucket.backend.0.id

  rule {
    apply_server_side_encryption_by_default {
      # kms_master_key_id = aws_kms_key.mykey.arn
      sse_algorithm = "AES256" # "aws:kms"
    }
  }
}

resource "aws_dynamodb_table" "terraform_lock" {
  count = terraform.workspace == "default" ? 1 : 0

  name                        = "terraform_state"
  deletion_protection_enabled = true
  read_capacity               = 5
  write_capacity              = 5
  hash_key                    = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
  tags = {
    "Name" = "DynamoDB Terraform State Lock Table"
  }
}
