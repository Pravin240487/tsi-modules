data "aws_ami" "amazon_linux_arm" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-kernel-*-arm64"]
  }

  filter {
    name   = "architecture"
    values = ["arm64"]
  }
}

resource "aws_iam_instance_profile" "this" {
  name = var.instance_profile_name
  role = split("/", var.iam_role_arn)[1]
}

resource "aws_security_group" "this" {
  name        = var.security_group_name
  description = "Security group for Graviton EC2"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.security_group_name
  }
}

resource "aws_instance" "this" {
  ami                    = data.aws_ami.amazon_linux_arm.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  iam_instance_profile  = aws_iam_instance_profile.this.name
  vpc_security_group_ids = [aws_security_group.this.id]

  associate_public_ip_address = false
  user_data = var.user_data

  tags = {
    Name = var.instance_name
  }
}
