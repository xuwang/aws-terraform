# Docker vpc main module
variable "vpc" {
    default = {
      cidr = "10.0.0.0/16"
    }
}

variable "bastion_net" {
    default = {
        us-west-2a = "10.0.0.0/26"
        us-west-2b = "10.0.0.64/26"
        us-west-2c = "10.0.0.128/26"
    }
}

variable "etcd_elb_net" {
    default = {
        us-west-2a = "10.0.1.0/26"
        us-west-2b = "10.0.1.64/26"
        us-west-2c = "10.0.1.128/26"
    }
}

variable "etcd_net" {
    default = {
        us-west-2a = "10.0.2.0/26"
        us-west-2b = "10.0.2.64/26"
        us-west-2c = "10.0.2.128/26"
    }
}

variable "rds_net" {
    default = {
        us-west-2a = "10.0.3.0/26"
        us-west-2b = "10.0.3.64/26"
        us-west-2c = "10.0.3.128/26"
    }
}

variable "ext_elb_net" {
    default = {
        us-west-2a = "10.0.4.0/26"
        us-west-2b = "10.0.4.64/26"
        us-west-2c = "10.0.4.128/26"
    }
}

variable "hosting_net" {
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

resource "aws_vpc" "mylab" {
    cidr_block = "${var.vpc.cidr}"
    tags {
        Name = "mylab-vpc"
        Billing = "${var.project_tags.mylab}"
    }
    enable_dns_support = true
    enable_dns_hostnames = true
}

resource "aws_internet_gateway" "igw" {
    vpc_id = "${aws_vpc.mylab.id}"
}

resource "aws_route_table" "mylab_rt" {
    vpc_id = "${aws_vpc.mylab.id}"
    route {
        cidr_block = "${var.all_net.all_net}"
        gateway_id = "${aws_internet_gateway.igw.id}"
    }
}
# docker-bastion-a
resource "aws_subnet" "docker-bastion-a" {
    vpc_id = "${aws_vpc.mylab.id}"
    availability_zone = "us-west-2a"
    cidr_block = "${var.bastion_net.us-west-2a}"
    map_public_ip_on_launch = "true"

    tags {
        Name = "docker-bastion-a"
        Billing = "${var.project_tags.mylab}"
    }
}
resource "aws_route_table_association" "docker-bastion-aa" {
    subnet_id = "${aws_subnet.docker-bastion-a.id}"
    route_table_id = "${aws_route_table.mylab_rt.id}"
}

# docker-bastion-b
resource "aws_subnet" "docker-bastion-b" {
    vpc_id = "${aws_vpc.mylab.id}"
    availability_zone = "us-west-2b"
    cidr_block = "${var.bastion_net.us-west-2b}"
    map_public_ip_on_launch = "true"

    tags {
        Name = "docker-bastion-b"
        Billing = "${var.project_tags.mylab}"
    }
}
resource "aws_route_table_association" "docker-bastion-ba" {
    subnet_id = "${aws_subnet.docker-bastion-b.id}"
    route_table_id = "${aws_route_table.mylab_rt.id}"
}

# docker-bastion-c {
resource "aws_subnet" "docker-bastion-c" {
    vpc_id = "${aws_vpc.mylab.id}"
    availability_zone = "us-west-2c"
    cidr_block = "${var.bastion_net.us-west-2c}"
    map_public_ip_on_launch = "true"

    tags {
        Name = "docker-bastion-c"
        Billing = "${var.project_tags.mylab}"
    }
}

resource "aws_route_table_association" "docker-bastion-ca" {
    subnet_id = "${aws_subnet.docker-bastion-c.id}"
    route_table_id = "${aws_route_table.mylab_rt.id}"
}
resource "aws_subnet" "docker-etcd-a" {
    vpc_id = "${aws_vpc.mylab.id}"
    availability_zone = "us-west-2a"
    cidr_block = "${var.etcd_net.us-west-2a}"
    map_public_ip_on_launch = "true"

    tags {
        Name = "docker-etcd-a"
        Billing = "${var.project_tags.mylab}"
    }
}

resource "aws_route_table_association" "docker-etcd-aa" {
    subnet_id = "${aws_subnet.docker-etcd-a.id}"
    route_table_id = "${aws_route_table.mylab_rt.id}"
}

resource "aws_subnet" "docker-etcd-b" {
    vpc_id = "${aws_vpc.mylab.id}"
    availability_zone = "us-west-2b"
    cidr_block = "${var.etcd_net.us-west-2b}"
    map_public_ip_on_launch = "true"

    tags {
        Name = "docker-etcd-b"
        Billing = "${var.project_tags.mylab}"
    }
}
resource "aws_route_table_association" "docker-etcd-ba" {
    subnet_id = "${aws_subnet.docker-etcd-b.id}"
    route_table_id = "${aws_route_table.mylab_rt.id}"
}

resource "aws_subnet" "docker-etcd-c" {
    vpc_id = "${aws_vpc.mylab.id}"
    availability_zone = "us-west-2c"
    cidr_block = "${var.etcd_net.us-west-2c}"
    map_public_ip_on_launch = "true"

    tags {
        Name = "docker-etcd-c"
        Billing = "${var.project_tags.mylab}"
    }
}

resource "aws_route_table_association" "docker-etcd-ca" {
    subnet_id = "${aws_subnet.docker-etcd-c.id}"
    route_table_id = "${aws_route_table.mylab_rt.id}"
}

resource "aws_subnet" "docker-etcd_elb-a" {
    vpc_id = "${aws_vpc.mylab.id}"
    availability_zone = "us-west-2a"
    cidr_block = "${var.etcd_elb_net.us-west-2a}"
    map_public_ip_on_launch = "true"

    tags {
        Name = "docker-etcd_elb-a"
    }
}
resource "aws_route_table_association" "docker-etcd_elb-aa" {
    subnet_id = "${aws_subnet.docker-etcd_elb-a.id}"
    route_table_id = "${aws_route_table.mylab_rt.id}"
}

resource "aws_subnet" "docker-etcd_elb-b" {
    vpc_id = "${aws_vpc.mylab.id}"
    availability_zone = "us-west-2b"
    cidr_block = "${var.etcd_elb_net.us-west-2b}"
    map_public_ip_on_launch = "true"

    tags {
        Name = "docker-etcd_elb_net-b"
        Billing = "${var.project_tags.mylab}"
    }
}
resource "aws_route_table_association" "docker-etcd_elb-ba" {
    subnet_id = "${aws_subnet.docker-etcd_elb-b.id}"
    route_table_id = "${aws_route_table.mylab_rt.id}"
}

resource "aws_subnet" "docker-etcd_elb-c" {
    vpc_id = "${aws_vpc.mylab.id}"
    availability_zone = "us-west-2c"
    cidr_block = "${var.etcd_elb_net.us-west-2c}"
    map_public_ip_on_launch = "true"

    tags {
        Name = "docker-etcd_elb_net-c"
        Billing = "${var.project_tags.mylab}"
    }
}
resource "aws_route_table_association" "docker-etcd_elb-ca" {
    subnet_id = "${aws_subnet.docker-etcd_elb-c.id}"
    route_table_id = "${aws_route_table.mylab_rt.id}"
}

resource "aws_subnet" "docker-ext_elb-a" {
    vpc_id = "${aws_vpc.mylab.id}"
    availability_zone = "us-west-2a"
    cidr_block = "${var.ext_elb_net.us-west-2a}"
    map_public_ip_on_launch = "true"

    tags {
        Name = "docker-ext_elb_net-a"
        Billing = "${var.project_tags.mylab}"
    }
}
resource "aws_route_table_association" "docker-ext_elb-aa" {
    subnet_id = "${aws_subnet.docker-ext_elb-a.id}"
    route_table_id = "${aws_route_table.mylab_rt.id}"
}

resource "aws_subnet" "docker-ext_elb-b" {
    vpc_id = "${aws_vpc.mylab.id}"
    availability_zone = "us-west-2b"
    cidr_block = "${var.ext_elb_net.us-west-2b}"
    map_public_ip_on_launch = "true"

    tags {
        Name = "docker-ext_elb-b"
        Billing = "${var.project_tags.mylab}"
    }
}
resource "aws_route_table_association" "docker-ext_elb-ba" {
    subnet_id = "${aws_subnet.docker-ext_elb-b.id}"
    route_table_id = "${aws_route_table.mylab_rt.id}"
}

resource "aws_subnet" "docker-ext_elb-c" {
    vpc_id = "${aws_vpc.mylab.id}"
    availability_zone = "us-west-2c"
    cidr_block = "${var.ext_elb_net.us-west-2c}"
    map_public_ip_on_launch = "true"

    tags {
        Name = "docker-ext_elb-c"
        Billing = "${var.project_tags.mylab}"
    }
}
resource "aws_route_table_association" "docker-ext_elb-ca" {
    subnet_id = "${aws_subnet.docker-ext_elb-c.id}"
    route_table_id = "${aws_route_table.mylab_rt.id}"
}

resource "aws_subnet" "docker-hosting-a" {
    vpc_id = "${aws_vpc.mylab.id}"
    availability_zone = "us-west-2a"
    cidr_block = "${var.hosting_net.us-west-2a}"
    map_public_ip_on_launch = "true"

    tags {
        Name = "docker-hosting-a"
        Billing = "${var.project_tags.mylab}"
    }
}

resource "aws_route_table_association" "docker-hosting-aa" {
    subnet_id = "${aws_subnet.docker-hosting-a.id}"
    route_table_id = "${aws_route_table.mylab_rt.id}"
}

resource "aws_subnet" "docker-hosting-b" {
    vpc_id = "${aws_vpc.mylab.id}"
    availability_zone = "us-west-2b"
    cidr_block = "${var.hosting_net.us-west-2b}"
    map_public_ip_on_launch = "true"

    tags {
        Name = "docker-hosting-b"
        Billing = "${var.project_tags.mylab}"
    }
}
resource "aws_route_table_association" "docker-hosting-ba" {
    subnet_id = "${aws_subnet.docker-hosting-b.id}"
    route_table_id = "${aws_route_table.mylab_rt.id}"
}

resource "aws_subnet" "docker-hosting-c" {
    vpc_id = "${aws_vpc.mylab.id}"
    availability_zone = "us-west-2c"
    cidr_block = "${var.hosting_net.us-west-2c}"
    map_public_ip_on_launch = "true"

    tags {
        Name = "docker-hosting-c"
        Billing = "${var.project_tags.mylab}"
    }
}

resource "aws_route_table_association" "docker-hosting-ca" {
    subnet_id = "${aws_subnet.docker-hosting-c.id}"
    route_table_id = "${aws_route_table.mylab_rt.id}"
}

resource "aws_subnet" "docker-rds-a" {
    vpc_id = "${aws_vpc.mylab.id}"
    availability_zone = "us-west-2a"
    cidr_block = "${var.rds_net.us-west-2a}"
    map_public_ip_on_launch = "true"

    tags {
        Name = "docker-rds-a"
        Billing = "${var.project_tags.mylab}"
    }
}
resource "aws_route_table_association" "docker-rds-aa" {
    subnet_id = "${aws_subnet.docker-rds-a.id}"
    route_table_id = "${aws_route_table.mylab_rt.id}"
}

resource "aws_subnet" "docker-rds-b" {
    vpc_id = "${aws_vpc.mylab.id}"
    availability_zone = "us-west-2b"
    cidr_block = "${var.rds_net.us-west-2b}"
    map_public_ip_on_launch = "false"

    tags {
        Name = "docker-rds-b"
        Billing = "${var.project_tags.mylab}"
    }
}
resource "aws_route_table_association" "docker-rds-ba" {
    subnet_id = "${aws_subnet.docker-rds-b.id}"
    route_table_id = "${aws_route_table.mylab_rt.id}"
}

resource "aws_subnet" "docker-rds-c" {
    vpc_id = "${aws_vpc.mylab.id}"
    availability_zone = "us-west-2c"
    cidr_block = "${var.rds_net.us-west-2c}"
    map_public_ip_on_launch = "false"

    tags {
        Name = "docker-rds-c"
        Billing = "${var.project_tags.mylab}"
    }
}

resource "aws_route_table_association" "docker-rds-ca" {
    subnet_id = "${aws_subnet.docker-rds-c.id}"
    route_table_id = "${aws_route_table.mylab_rt.id}"
}

/*
# Security groups
resource "aws_security_group" "allow_icmp" {
  name = "allow_all"
  description = "Allow all inbound ICMP traffic"

  ingress {
      from_port = -1
      to_port = -1
      protocol = "icmp"
      cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "allow_icmp"
  }
}

resource "aws_security_group" "allow_udp_53" {
  name = "allow_udp_53"
  description = "Allow all inbound udp 53"

  ingress {
      from_port = 53
      to_port = 53
      protocol = "udp"
      cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "allow_udp_53"
  }
}

*/


resource "aws_security_group" "bastion_sg"  {
    name = "docker-bastion-sg"
    vpc_id = "${aws_vpc.mylab.id}"
    description = "docker-bastion-sg SG"

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
    ingress {
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }

    tags {
      Name = "bastion_sg"
    }
}

resource "aws_security_group" "etcd_elb_sg"  {
    name = "docker-etcd_elb-sg"
    vpc_id = "${aws_vpc.mylab.id}" 
    description = "docker-etcd_elb-sg SG"

    tags {
      Name = "etcd_elb_sg"
    }
}

resource "aws_security_group" "etcd_sg"  {
    name = "docker-etcd-sg"
    vpc_id = "${aws_vpc.mylab.id}"
    description = "docker-etcd-sg SG"
    
    # Allow etcd peers to communicate
    ingress {
      from_port = 7001
      to_port = 7001
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

    # Allow SSH from campus hosts
    ingress {
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = ["${aws_security_group.bastion_sg.id}"]
      security_groups = ["${aws_security_group.bastion_sg.id}"]
      self =  true
    }

    tags {
      Name = "etcd_sg"
    }
}

resource "aws_security_group" "rds_sg"  {
    name = "docker-rds-sg"
    vpc_id = "${aws_vpc.mylab.id}"
    description = "docker-rds-sg SG"
    depends_on = ["aws_security_group.bastion_sg","aws_security_group.etcd_sg", "aws_security_group.hosting_sg"]

    # Allow MySQL access
    ingress {
      from_port = 3306
      to_port = 3306
      protocol = "tcp"
      security_groups = ["${aws_security_group.bastion_sg.id}","${aws_security_group.etcd_sg.id}", "${aws_security_group.hosting_sg.id}"]
      cidr_blocks = ["${var.allow_from_mylab_forsythe}", "${var.allow_from_su_pub_vpn}" ]
    }
    # Allow PostgresSQL access
    ingress {
      from_port = 5432
      to_port = 5432
      protocol = "tcp"
      security_groups = ["${aws_security_group.bastion_sg.id}","${aws_security_group.etcd_sg.id}", "${aws_security_group.hosting_sg.id}"]
      cidr_blocks = ["${var.allow_from_mylab_forsythe}", "${var.allow_from_su_pub_vpn}" ]
    }
    tags {
      Name = "rds_sg"
    }
}


resource "aws_security_group" "ext_elb_sg"  {
    name = "docker-ext_elb-sg"
    vpc_id = "${aws_vpc.mylab.id}" 
    description = "docker-ext_elb-sg SG"

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
      Name = "ext_elb_sg"
    }
}

resource "aws_security_group" "hosting_sg"  {
    name = "docker-hosting-sg"
    vpc_id = "${aws_vpc.mylab.id}"
    description = "docker-hosting-sg SG"

    ingress {
      from_port = 1024
      to_port = 65535
      protocol = "tcp"
      security_groups = ["${aws_security_group.ext_elb_sg.id}"]
    }

    ingress {
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = ["10.0.0.0/16"]
      security_groups = ["${aws_security_group.bastion_sg.id}", "${aws_security_group.etcd_sg.id}"]
    }

    #ingress {
    #  from_port = 22
    #  to_port = 22
    #  protocol = "tcp"
    #  security_groups = ["${aws_security_group.bastion_sg.id}", "${aws_security_group.etcd_sg.id}"]
    #}
    tags {
      Name = "hosting_sg"
    }
}

# Output

# VPC
output "vpc_id" {
    value = "\"${aws_vpc.mylab.id}\""
}
output "vpc_cidr" {
    value = "\"${aws_vpc.mylab.cidr_block}\""
}

# Load balancer 
output "subnet_ext_elb-us-west-2a" {
    value = "\"${aws_subnet.docker-ext_elb-a.id}\""
}
output "subnet_ext_elb-us-west-2b" {
    value = "\"${aws_subnet.docker-ext_elb-b.id}\""
}
output "subnet_ext_elb-us-west-2c" {
    value = "\"${aws_subnet.docker-ext_elb-c.id}\""
}

# Etcd
output "subnet_etcd-a-us-west-2a" {
    value = "\"${aws_subnet.docker-etcd-a.id}\""
}
output "subnet_etcd-b-us-west-2b" {
    value = "\"${aws_subnet.docker-etcd-b.id}\""
}
output "subnet_etcd-c-us-west-2c" {
    value = "\"${aws_subnet.docker-etcd-c.id}\""
}

# Bastion
output "subnet_bastion-us-west-2a" {
    value = "\"${aws_subnet.docker-bastion-a.id}\""
}
output "subnet_bastion-us-west-2b" {
    value = "\"${aws_subnet.docker-bastion-b.id}\""
}
output "subnet_bastion-us-west-2c" {
    value = "\"${aws_subnet.docker-bastion-c.id}\""
}

# Core (apps)
output "subnet_core-us-west-2a" {
    value = "\"${aws_subnet.docker-etcd-a.id}\""
}
output "subnet_core-us-west-2b" {
    value = "\"${aws_subnet.docker-etcd-b.id}\""
}
output "subnet_core-us-west-2c" {
    value = "\"${aws_subnet.docker-etcd-c.id}\""
}

# RDS
output "subnet_rds-us-west-2a" {
    value = "\"${aws_subnet.docker-rds-a.id}\""
}
output "subnet_rds-us-west-2b" {
    value = "\"${aws_subnet.docker-rds-b.id}\""
}
output "subnet_rds-us-west-2c" {
    value = "\"${aws_subnet.docker-rds-c.id}\""
}
output "subnet_hosting-us-west-2b" {
    value = "\"${aws_subnet.docker-hosting-b.id}\""
}
output "subnet_hosting-us-west-2c" {
    value = "\"${aws_subnet.docker-hosting-c.id}\""
}
# Hosting
output "subnet_hosting-us-west-2a" {
    value = "\"${aws_subnet.docker-hosting-a.id}\""
}
output "subnet_hosting-us-west-2b" {
    value = "\"${aws_subnet.docker-hosting-b.id}\""
}
output "subnet_hosting-us-west-2c" {
    value = "\"${aws_subnet.docker-hosting-c.id}\""
}

# Security groups
output "security_group_bastion" {
    value = "\"${aws_security_group.bastion_sg.id}\""
}
output "security_group_docker-ext-elb" {
    value = "\"${aws_security_group.ext_elb_sg.id}\""
}
output "security_group_etcd" {
    value = "\"${aws_security_group.etcd_sg.id}\""
}
output "security_group_hosting" {
    value = "\"${aws_security_group.hosting_sg.id}\""
}
output "security_group_rds" {
    value = "\"${aws_security_group.rds_sg.id}\""
}
