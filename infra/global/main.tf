resource "aws_s3_bucket" "main" {
  bucket = "meteor-challenge-terraform-state"
}

resource "aws_s3_bucket_versioning" "main" {
  bucket = aws_s3_bucket.main.id

  versioning_configuration {
    status = "Enabled"
  }
}

// resource "aws_dynamodb_table" "main" {
//     
// }
