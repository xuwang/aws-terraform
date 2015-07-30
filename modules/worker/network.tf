resource "aws_subnet" "worker-a" {
    vpc_id = "${var.vpc_id}"
    availability_zone = "us-west-2a"
    cidr_block = "${var.worker_net.us-west-2a}"
    map_public_ip_on_launch = "true"
    tags {
        Name = "worker-a"
    }
}

resource "aws_route_table_association" "worker-rt-a" {
    subnet_id = "${aws_subnet.worker-a.id}"
    route_table_id = "${var.vpc_route_table}"
}

resource "aws_subnet" "worker-b" {
    vpc_id = "${var.vpc_id}"
    availability_zone = "us-west-2b"
    cidr_block = "${var.worker_net.us-west-2b}"
    map_public_ip_on_launch = "true"
    tags {
        Name = "worker-b"
    }
}
resource "aws_route_table_association" "worker-rt-b" {
    subnet_id = "${aws_subnet.worker-b.id}"
    route_table_id = "${var.vpc_route_table}"
}

resource "aws_subnet" "worker-c" {
    vpc_id = "${var.vpc_id}"
    availability_zone = "us-west-2c"
    cidr_block = "${var.worker_net.us-west-2c}"
    map_public_ip_on_launch = "true"
    tags {
        Name = "worker-c"
    }
}

resource "aws_route_table_association" "worker-rt-c" {
    subnet_id = "${aws_subnet.worker-c.id}"
    route_table_id = "${var.vpc_route_table}"
}

resource "aws_security_group" "worker"  {
    name = "worker"
    vpc_id = "${var.vpc_id}"
    description = "worker"

    # Allow all outbound traffic
    egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }

    # Allow access from vpc
    ingress {
      from_port = 10
      to_port = 65535
      protocol = "tcp"
      cidr_blocks = ["${var.vpc_cidr}"]
    }

    # Allow access from vpc
    ingress {
      from_port = 10
      to_port = 65535
      protocol = "udp"
      cidr_blocks = ["${var.vpc_cidr}"]
    }

    # Allow SSH from my hosts
    ingress {
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = ["${var.allow_ssh_cidr}"]
      self = true
    }

    tags {
      Name = "worker"
    }
}
