resource "aws_s3_bucket" "terraform_state" {
  bucket = "terraform-state-amalai-s31q"
    acl = "private"
    lifecycle {
        prevent_destroy = true
    }
    versioning {
        enabled = true
    }
    server_side_encryption_configuration {
      rule {
          apply_server_side_encryption_by_default {
          sse_algorithm = "AES256"
          }
      }
    }   
}

resource "aws_db_instance" "default_S3b" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  name                 = "mydb"
  username             = "foo1"
  password             = "foobarbazi"
  parameter_group_name = "default.mysql5.7"
}


resource "aws_dynamodb_table" "terraform_locks" {
  name = "terraform_state_locking"
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

terraform {
  backend "s3" {
    bucket = "terraform-state-amalai-s31q"
    key    = "global/s3/terraform.tfstate"
    region = "us-east-1"
    dynamodb_table = "terraform_state_locking"
    encrypt = true
  }
}
