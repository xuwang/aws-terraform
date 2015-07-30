resource "aws_subnet" "etcd-a" {
    vpc_id = "${var.vpc_id}"
    availability_zone = "us-west-2a"
    cidr_block = "${var.etcd_net.us-west-2a}"
    map_public_ip_on_launch = "true"
    tags {
        Name = "etcd-a"
    }
}

resource "aws_route_table_association" "etcd-rt-a" {
    subnet_id = "${aws_subnet.etcd-a.id}"
    route_table_id = "${var.vpc_route_table}"
}

resource "aws_subnet" "etcd-b" {
    vpc_id = "${var.vpc_id}"
    availability_zone = "us-west-2b"
    cidr_block = "${var.etcd_net.us-west-2b}"
    map_public_ip_on_launch = "true"
    tags {
        Name = "etcd-b"
    }
}
resource "aws_route_table_association" "etcd-rt-b" {
    subnet_id = "${aws_subnet.etcd-b.id}"
    route_table_id = "${var.vpc_route_table}"
}

resource "aws_subnet" "etcd-c" {
    vpc_id = "${var.vpc_id}"
    availability_zone = "us-west-2c"
    cidr_block = "${var.etcd_net.us-west-2c}"
    map_public_ip_on_launch = "true"
    tags {
        Name = "etcd-c"
    }
}

resource "aws_route_table_association" "etcd-rt-c" {
    subnet_id = "${aws_subnet.etcd-c.id}"
    route_table_id = "${var.vpc_route_table}"
}

resource "aws_security_group" "etcd"  {
    name = "etcd"
    vpc_id = "${var.vpc_id}"
    description = "etcd"

    # Allow all outbound traffic
    egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
    
    # Allow etcd peers to communicate, include etcd proxies
    ingress {
      from_port = 7001
      to_port = 7001
      protocol = "tcp"
      cidr_blocks = ["${var.vpc_cidr}"]
    }

    # Allow etcd2 peers to communicate, include etcd proxies
    ingress {
      from_port = 2380
      to_port = 2380
      protocol = "tcp"
      cidr_blocks = ["${var.vpc_cidr}"]
    }

    # Allow etcd clients to communicate
    ingress {
      from_port = 4001
      to_port = 4001
      protocol = "tcp"
      cidr_blocks = ["${var.vpc_cidr}"]
    }

    # Allow etcd2 clients to communicate
    ingress {
      from_port = 2379
      to_port = 2379
      protocol = "tcp"
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
      Name = "etcd"
    }
}
