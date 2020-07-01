provider "aws" {
  profile = "terraform"
  region  = "eu-central-1"
}

resource "aws_s3_bucket" "tf_course" {
  bucket = "tf-course-apig"
  acl    = "private"
}

resource "aws_default_vpc" "default_vpc" {}

resource "aws_security_group" "tf_sec_group" {
  name        = "tf_sec_group"
  description = "Allow Inbound HTTP, and everything Outbound"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Terraform" : "true"
  }
}
