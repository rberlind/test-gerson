variable "server_port" {
  description = "The port the server will use for HTTP requests"
  default = 8080
}

variable "access_key" {
  description = "aws access_key"
}

variable "secret_key" {
  description = "aws secret_key"
}

variable "region" {
  description = "aws region"
}

provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

resource "aws_instance" "example" {
  # Ubuntu Server 14.04 LTS (HVM), SSD Volume Type in us-east-1
  count = 1
  ami = "ami-2d39803a"
  instance_type = "t2.medium"
  vpc_security_group_ids = ["${aws_security_group.instance.id}"]

  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World test" > index.html
              nohup busybox httpd -f -p "${var.server_port}" &
              EOF

  tags {
    Name = "terraform-example"
  }
}

resource "aws_security_group" "instance" {
  name = "terraform-example-instance"

  # Inbound HTTP from anywhere
  ingress {
    from_port = "${var.server_port}"
    to_port = "${var.server_port}"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "public_ip" {
  value = "${aws_instance.example.*.public_ip}"
}
