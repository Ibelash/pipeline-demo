terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# ⚠️ Fallas intencionales para el demo de IaC scanning (Checkov las debe marcar):

# 1) Bucket S3 sin encriptación y con ACL público
resource "aws_s3_bucket" "demo_bucket" {
  bucket = "demo-app-uploads-insecure"
  acl    = "public-read" # <- hallazgo esperado: bucket público
}

resource "aws_s3_bucket_versioning" "demo_bucket_versioning" {
  bucket = aws_s3_bucket.demo_bucket.id
  versioning_configuration {
    status = "Disabled" # <- hallazgo esperado: sin versionado
  }
}

# 2) Security group abierto al mundo en el puerto de administración
resource "aws_security_group" "demo_sg" {
  name        = "demo-app-sg"
  description = "Security group de la app de ejemplo"

  ingress {
    description = "SSH abierto a internet"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # <- hallazgo esperado: SSH expuesto a todo internet
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 3) Rol IAM con permisos excesivos
resource "aws_iam_role_policy" "demo_policy" {
  name = "demo-app-policy"
  role = aws_iam_role.demo_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "*"      # <- hallazgo esperado: permisos sin restricción
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role" "demo_role" {
  name = "demo-app-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}
