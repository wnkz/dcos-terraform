resource "aws_security_group" "slave" {
    name        = "dcos-SlaveSecurityGroup"
    description = "Mesos Slaves"
    vpc_id      = "${aws_vpc.dcos.id}"

    tags {
        "Environment" = "dcos"
    }
}

resource "aws_security_group_rule" "slave" {
    type = "ingress"
    from_port = 0
    to_port = 0
    protocol = "-1"
    self = true

    security_group_id = "${aws_security_group.slave.id}"
}

resource "aws_security_group_rule" "master_to_slave" {
    type = "ingress"
    from_port = 0
    to_port = 0
    protocol = "-1"

    security_group_id = "${aws_security_group.slave.id}"
    source_security_group_id = "${aws_security_group.master.id}"
}

resource "aws_security_group_rule" "public_slave_to_slave" {
    type = "ingress"
    from_port = 0
    to_port = 0
    protocol = "-1"

    security_group_id = "${aws_security_group.slave.id}"
    source_security_group_id = "${aws_security_group.public_slave.id}"
}

resource "aws_security_group_rule" "slave_outbound" {
    type = "egress"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]

    security_group_id = "${aws_security_group.slave.id}"
}
