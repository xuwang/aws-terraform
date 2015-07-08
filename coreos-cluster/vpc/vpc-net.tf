# Docker vpc main module
variable "vpc" {
    default = {
      cidr = "10.0.0.0/16"
    }
}

variable "etcd_net" {
    default = {
        us-west-2a = "10.0.1.0/26"
        us-west-2b = "10.0.1.64/26"
        us-west-2c = "10.0.1.128/26"
    }
}

variable "rds_net" {
    default = {
        us-west-2a = "10.0.3.0/26"
        us-west-2b = "10.0.3.64/26"
        us-west-2c = "10.0.3.128/26"
    }
}

variable "elb_net" {
    default = {
        us-west-2a = "10.0.4.0/26"
        us-west-2b = "10.0.4.64/26"
        us-west-2c = "10.0.4.128/26"
    }
}

variable "worker_net" {
    default = {
        us-west-2a = "10.0.5.0/26"
        us-west-2b = "10.0.5.64/26"
        us-west-2c = "10.0.5.128/26"
    }
}

variable "all_net" {
    default = {
        all_net = "0.0.0.0/0"
    }
}

resource "aws_vpc" "coreos-cluster" {
    cidr_block = "${var.vpc.cidr}"
    tags {
        Name = "coreos-cluster-vpc"
        Billing = "${var.project_tags.coreos-cluster}"
    }
    enable_dns_support = true
    enable_dns_hostnames = true
}

resource "aws_internet_gateway" "igw" {
    vpc_id = "${aws_vpc.coreos-cluster.id}"
}

resource "aws_route_table" "coreos-cluster_rt" {
    vpc_id = "${aws_vpc.coreos-cluster.id}"
    route {
        cidr_block = "${var.all_net.all_net}"
        gateway_id = "${aws_internet_gateway.igw.id}"
    }
}

resource "aws_subnet" "etcd-a" {
    vpc_id = "${aws_vpc.coreos-cluster.id}"
    availability_zone = "us-west-2a"
    cidr_block = "${var.etcd_net.us-west-2a}"
    map_public_ip_on_launch = "true"

    tags {
        Name = "etcd-a"
        Billing = "${var.project_tags.coreos-cluster}"
    }
}

resource "aws_route_table_association" "etcd-rt-a" {
    subnet_id = "${aws_subnet.etcd-a.id}"
    route_table_id = "${aws_route_table.coreos-cluster_rt.id}"
}

resource "aws_subnet" "etcd-b" {
    vpc_id = "${aws_vpc.coreos-cluster.id}"
    availability_zone = "us-west-2b"
    cidr_block = "${var.etcd_net.us-west-2b}"
    map_public_ip_on_launch = "true"

    tags {
        Name = "etcd-b"
        Billing = "${var.project_tags.coreos-cluster}"
    }
}
resource "aws_route_table_association" "etcd-rt-b" {
    subnet_id = "${aws_subnet.etcd-b.id}"
    route_table_id = "${aws_route_table.coreos-cluster_rt.id}"
}

resource "aws_subnet" "etcd-c" {
    vpc_id = "${aws_vpc.coreos-cluster.id}"
    availability_zone = "us-west-2c"
    cidr_block = "${var.etcd_net.us-west-2c}"
    map_public_ip_on_launch = "true"

    tags {
        Name = "etcd-c"
        Billing = "${var.project_tags.coreos-cluster}"
    }
}

resource "aws_route_table_association" "etcd-rt-c" {
    subnet_id = "${aws_subnet.etcd-c.id}"
    route_table_id = "${aws_route_table.coreos-cluster_rt.id}"
}

resource "aws_subnet" "elb-a" {
    vpc_id = "${aws_vpc.coreos-cluster.id}"
    availability_zone = "us-west-2a"
    cidr_block = "${var.elb_net.us-west-2a}"
    map_public_ip_on_launch = "true"

    tags {
        Name = "elb_net-a"
        Billing = "${var.project_tags.coreos-cluster}"
    }
}
resource "aws_route_table_association" "elb-rt-a" {
    subnet_id = "${aws_subnet.elb-a.id}"
    route_table_id = "${aws_route_table.coreos-cluster_rt.id}"
}

resource "aws_subnet" "elb-b" {
    vpc_id = "${aws_vpc.coreos-cluster.id}"
    availability_zone = "us-west-2b"
    cidr_block = "${var.elb_net.us-west-2b}"
    map_public_ip_on_launch = "true"

    tags {
        Name = "elb-b"
        Billing = "${var.project_tags.coreos-cluster}"
    }
}
resource "aws_route_table_association" "elb-rt-b" {
    subnet_id = "${aws_subnet.elb-b.id}"
    route_table_id = "${aws_route_table.coreos-cluster_rt.id}"
}

resource "aws_subnet" "elb-c" {
    vpc_id = "${aws_vpc.coreos-cluster.id}"
    availability_zone = "us-west-2c"
    cidr_block = "${var.elb_net.us-west-2c}"
    map_public_ip_on_launch = "true"

    tags {
        Name = "elb-c"
        Billing = "${var.project_tags.coreos-cluster}"
    }
}
resource "aws_route_table_association" "elb-rt-c" {
    subnet_id = "${aws_subnet.elb-c.id}"
    route_table_id = "${aws_route_table.coreos-cluster_rt.id}"
}

resource "aws_subnet" "worker-a" {
    vpc_id = "${aws_vpc.coreos-cluster.id}"
    availability_zone = "us-west-2a"
    cidr_block = "${var.worker_net.us-west-2a}"
    map_public_ip_on_launch = "true"

    tags {
        Name = "worker-a"
        Billing = "${var.project_tags.coreos-cluster}"
    }
}

resource "aws_route_table_association" "worker-rt-a" {
    subnet_id = "${aws_subnet.worker-a.id}"
    route_table_id = "${aws_route_table.coreos-cluster_rt.id}"
}

resource "aws_subnet" "worker-b" {
    vpc_id = "${aws_vpc.coreos-cluster.id}"
    availability_zone = "us-west-2b"
    cidr_block = "${var.worker_net.us-west-2b}"
    map_public_ip_on_launch = "true"

    tags {
        Name = "worker-b"
        Billing = "${var.project_tags.coreos-cluster}"
    }
}
resource "aws_route_table_association" "worker-rt-b" {
    subnet_id = "${aws_subnet.worker-b.id}"
    route_table_id = "${aws_route_table.coreos-cluster_rt.id}"
}

resource "aws_subnet" "worker-c" {
    vpc_id = "${aws_vpc.coreos-cluster.id}"
    availability_zone = "us-west-2c"
    cidr_block = "${var.worker_net.us-west-2c}"
    map_public_ip_on_launch = "true"

    tags {
        Name = "worker-c"
        Billing = "${var.project_tags.coreos-cluster}"
    }
}

resource "aws_route_table_association" "worker-rt-c" {
    subnet_id = "${aws_subnet.worker-c.id}"
    route_table_id = "${aws_route_table.coreos-cluster_rt.id}"
}

resource "aws_subnet" "rds-a" {
    vpc_id = "${aws_vpc.coreos-cluster.id}"
    availability_zone = "us-west-2a"
    cidr_block = "${var.rds_net.us-west-2a}"
    map_public_ip_on_launch = "true"

    tags {
        Name = "rds-a"
        Billing = "${var.project_tags.coreos-cluster}"
    }
}
resource "aws_route_table_association" "rds-rt-a" {
    subnet_id = "${aws_subnet.rds-a.id}"
    route_table_id = "${aws_route_table.coreos-cluster_rt.id}"
}

resource "aws_subnet" "rds-b" {
    vpc_id = "${aws_vpc.coreos-cluster.id}"
    availability_zone = "us-west-2b"
    cidr_block = "${var.rds_net.us-west-2b}"
    map_public_ip_on_launch = "false"

    tags {
        Name = "rds-b"
        Billing = "${var.project_tags.coreos-cluster}"
    }
}
resource "aws_route_table_association" "rds-rt-b" {
    subnet_id = "${aws_subnet.rds-b.id}"
    route_table_id = "${aws_route_table.coreos-cluster_rt.id}"
}

resource "aws_subnet" "rds-c" {
    vpc_id = "${aws_vpc.coreos-cluster.id}"
    availability_zone = "us-west-2c"
    cidr_block = "${var.rds_net.us-west-2c}"
    map_public_ip_on_launch = "false"

    tags {
        Name = "rds-c"
        Billing = "${var.project_tags.coreos-cluster}"
    }
}

resource "aws_route_table_association" "rds-rt-c" {
    subnet_id = "${aws_subnet.rds-c.id}"
    route_table_id = "${aws_route_table.coreos-cluster_rt.id}"
}

resource "aws_security_group" "etcd_sg"  {
    name = "etcd-sg"
    vpc_id = "${aws_vpc.coreos-cluster.id}"
    description = "etcd-sg SG"

    # Allow all outbound traffic
    egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
    
    # Allow etcd peers to communicate
    ingress {
      from_port = 7001
      to_port = 7001
      protocol = "tcp"
      self = true
    }

    # Allow etcd2 peers to communicate
    ingress {
      from_port = 2380
      to_port = 2380
      protocol = "tcp"
      self = true
    }

    # Allow etcd clients to communicate
    ingress {
      from_port = 4001
      to_port = 4001
      protocol = "tcp"
      cidr_blocks = ["${var.vpc.cidr}"]
    }
    # Allow etcd2 clients to communicate
    ingress {
      from_port = 2379
      to_port = 2379
      protocol = "tcp"
      cidr_blocks = ["${var.vpc.cidr}"]
    }

    # Allow SSH from campus hosts
    ingress {
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = ["${var.allow_from_myip}"]
      self =  true
    }

    tags {
      Name = "etcd_sg"
    }
}

resource "aws_security_group" "elb_sg"  {
    name = "elb-sg"
    vpc_id = "${aws_vpc.coreos-cluster.id}"
    description = "elb-sg SG"

    # Add outbound rule
    egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
      from_port = 443
      to_port = 443
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }

    tags {
      Name = "elb_sg"
    }
}

resource "aws_security_group" "rds_sg"  {
    name = "rds-sg"
    vpc_id = "${aws_vpc.coreos-cluster.id}"
    description = "rds-sg SG"
    depends_on = ["aws_security_group.etcd_sg", "aws_security_group.worker_sg"]

    # Allow all outbound traffic
    egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
    
    # Allow MySQL access
    ingress {
      from_port = 3306
      to_port = 3306
      protocol = "tcp"
      security_groups = ["${aws_security_group.etcd_sg.id}", "${aws_security_group.worker_sg.id}"]
      cidr_blocks = ["${var.allow_from_myip}"]
    }
    # Allow PostgresSQL access
    ingress {
      from_port = 5432
      to_port = 5432
      protocol = "tcp"
      cidr_blocks = ["${var.allow_from_myip}", "${var.vpc.cidr}" ]
    }
    tags {
      Name = "rds_sg"
    }
}

resource "aws_security_group" "worker_sg"  {
    name = "worker-sg"
    vpc_id = "${aws_vpc.coreos-cluster.id}"
    description = "worker-sg SG"

    # Allow all outbound traffic
    egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
    
    ingress {
      from_port = 1024
      to_port = 65535
      protocol = "tcp"
      security_groups = ["${aws_security_group.elb_sg.id}"]
    }

    ingress {
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = ["10.0.0.0/16", "${var.allow_from_myip}"]
      security_groups = ["${aws_security_group.etcd_sg.id}"]
    }

    tags {
      Name = "worker_sg"
    }
}

resource "aws_security_group" "dockerhub_sg"  {
    name = "dockerhub-sg"
    vpc_id = "${aws_vpc.coreos-cluster.id}"
    description = "dockerhub-sg SG"

    # Add outbound rule
    egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
      from_port = 5000
      to_port = 8080
      protocol = "tcp"
      cidr_blocks = [ "${var.vpc.cidr}", "${var.allow_from_myip}"]
    }

    tags {
      Name = "worker_sg"
    }
}

resource "aws_security_group" "admiral_sg"  {
    name = "admiral-sg"
    vpc_id = "${aws_vpc.coreos-cluster.id}"
    
    description = "admiral-sg SG"
    
    # Add outbound rule
    egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = [ "${var.allow_from_myip}" ]
      security_groups = ["${aws_security_group.etcd_sg.id}"]
    }
  
    ingress {
      from_port = 5000
      to_port = 9000
      protocol = "tcp"
      cidr_blocks = [ "${var.vpc.cidr}" ]
    }

    # For splunk logging
    ingress {
      from_port = 10514
      to_port = 10514
      protocol = "tcp"
      cidr_blocks = [ "${var.vpc.cidr}" ]
    }
  
    
    tags {
      Name = "admiral_sg"
    }
}

# Output

# VPC
output "vpc_id" {
    value = "\"${aws_vpc.coreos-cluster.id}\""
}
output "vpc_cidr" {
    value = "\"${aws_vpc.coreos-cluster.cidr_block}\""
}

# Etcd
output "subnet_etcd-us-west-2a" {
    value = "\"${aws_subnet.etcd-a.id}\""
}
output "subnet_etcd-us-west-2b" {
    value = "\"${aws_subnet.etcd-b.id}\""
}
output "subnet_etcd-us-west-2c" {
    value = "\"${aws_subnet.etcd-c.id}\""
}

# ELB
output "subnet_elb-us-west-2a" {
    value = "\"${aws_subnet.elb-a.id}\""
}
output "subnet_elb-us-west-2b" {
    value = "\"${aws_subnet.elb-b.id}\""
}
output "subnet_elb-us-west-2c" {
    value = "\"${aws_subnet.elb-c.id}\""
}

# Admiral (apps)
output "subnet_admiral-us-west-2a" {
    value = "\"${aws_subnet.etcd-a.id}\""
}
output "subnet_admiral-us-west-2b" {
    value = "\"${aws_subnet.etcd-b.id}\""
}
output "subnet_admiral-us-west-2c" {
    value = "\"${aws_subnet.etcd-c.id}\""
}

# RDS
output "subnet_rds-us-west-2a" {
    value = "\"${aws_subnet.rds-a.id}\""
}
output "subnet_rds-us-west-2b" {
    value = "\"${aws_subnet.rds-b.id}\""
}
output "subnet_rds-us-west-2c" {
    value = "\"${aws_subnet.rds-c.id}\""
}
output "subnet_worker-us-west-2b" {
    value = "\"${aws_subnet.worker-b.id}\""
}
output "subnet_worker-us-west-2c" {
    value = "\"${aws_subnet.worker-c.id}\""
}
# Hosting
output "subnet_worker-us-west-2a" {
    value = "\"${aws_subnet.worker-a.id}\""
}
output "subnet_worker-us-west-2b" {
    value = "\"${aws_subnet.worker-b.id}\""
}
output "subnet_worker-us-west-2c" {
    value = "\"${aws_subnet.worker-c.id}\""
}

# Security groups
output "security_group_admiral" {
    value = "\"${aws_security_group.admiral_sg.id}\""
}
output "security_group_dockerhub" {
    value = "\"${aws_security_group.dockerhub_sg.id}\""
}
output "security_group_elb" {
    value = "\"${aws_security_group.elb_sg.id}\""
}
output "security_group_etcd" {
    value = "\"${aws_security_group.etcd_sg.id}\""
}
output "security_group_worker" {
    value = "\"${aws_security_group.worker_sg.id}\""
}
output "security_group_rds" {
    value = "\"${aws_security_group.rds_sg.id}\""
}
