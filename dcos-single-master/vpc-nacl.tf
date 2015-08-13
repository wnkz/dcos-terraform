resource "aws_network_acl" "private" {
    vpc_id = "${aws_vpc.dcos.id}"
    subnet_ids = ["${aws_subnet.private.id}"]

    ingress {
        from_port = 0
        to_port = 0
        rule_no = 100
        action = "allow"
        protocol = "-1"
        cidr_block = "0.0.0.0/0"
    }

    egress {
        from_port = 0
        to_port = 0
        rule_no = 100
        action = "allow"
        protocol = "-1"
        cidr_block = "0.0.0.0/0"
    }

    tags {
        "Environment" = "dcos"
    }
}

resource "aws_network_acl" "public" {
    vpc_id = "${aws_vpc.dcos.id}"
    subnet_ids = ["${aws_subnet.public.id}"]

    ingress {
        from_port = 0
        to_port = 0
        rule_no = 100
        action = "allow"
        protocol = "-1"
        cidr_block = "0.0.0.0/0"
    }

    egress {
        from_port = 0
        to_port = 0
        rule_no = 100
        action = "allow"
        protocol = "-1"
        cidr_block = "0.0.0.0/0"
    }

    tags {
        "Environment" = "dcos"
    }
}
