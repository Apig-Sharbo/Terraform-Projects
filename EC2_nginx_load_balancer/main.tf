provider "aws" {
  profile = "terraform"
  region  = "eu-central-1"
}

resource "aws_default_vpc" "default_vpc" {}


resource "aws_default_subnet" "default_az1" {
  availability_zone = "eu-central-1a"
  tags = {
    "Terraform" : "true"
  }
}

resource "aws_default_subnet" "default_az2" {
  availability_zone = "eu-central-1b"
  tags = {
    "Terraform" : "true"
  }
}

resource "aws_default_subnet" "default_az3" {
  availability_zone = "eu-central-1c"
  tags = {
    "Terraform" : "true"
  }
}


resource "aws_security_group" "tf_sec_group" {
  name        = "tf_sec_group"
  description = "Allow Inbound HTTP and SSH, and Outbound everything"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
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


resource "aws_key_pair" "deploy_key" {
  key_name   = "Terraform-test"
  public_key = file("~/.ssh/aws-ubuntu-1804.pub")
}

resource "aws_instance" "prod_web" {
  count = 2

  ami           = "ami-08602dbb603c18eff"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.deploy_key.key_name

  /*
  If you want to use existing key_name from aws,
  you should remove "aws_key_pair" resource.
  It's just confusing.
  */
  # key_name      = "aws-ubuntu-18.04"

  vpc_security_group_ids = [
    aws_security_group.tf_sec_group.id
  ]

  tags = {
    "Name" : "Nginx"
    "Terraform" : "true"
  }
}

# resource "aws_eip_association" "prod_web" {
#   instance_id   = aws_instance.prod_web[0].id
#   allocation_id = aws_eip.prod_web.id
# }
# resource "aws_eip" "prod_web" {
#   tags = {
#     "Terraform" : "true"
#   }
# }

resource "aws_elb" "prod_web" {
  name      = "prod-web"
  instances = aws_instance.prod_web.*.id

  subnets = [
    aws_default_subnet.default_az1.id,
    aws_default_subnet.default_az2.id,
    aws_default_subnet.default_az3.id,
  ]
  security_groups = [aws_security_group.tf_sec_group.id]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
}
