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
