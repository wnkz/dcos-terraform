resource "aws_security_group" "slave" {
    name        = "dcos-SlaveSecurityGroup"
    description = "Mesos Slaves"
    vpc_id      = "${aws_vpc.dcos.id}"

    tags {
        "Environment" = "dcos"
    }
}

resource "aws_security_group_rule" "slave1" {
    type = "ingress"
    from_port = 0
    to_port = 0
    protocol = "-1"
    self = true

    security_group_id = "${aws_security_group.slave.id}"
}

resource "aws_security_group_rule" "slave2" {
    type = "ingress"
    from_port = 0
    to_port = 0
    protocol = "-1"

    security_group_id = "${aws_security_group.slave.id}"
    source_security_group_id = "${aws_security_group.master.id}"
}

resource "aws_security_group_rule" "slave3" {
    type = "ingress"
    from_port = 0
    to_port = 0
    protocol = "-1"

    security_group_id = "${aws_security_group.slave.id}"
    source_security_group_id = "${aws_security_group.public_slave.id}"
}

resource "aws_security_group_rule" "slave4" {
    type = "egress"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]

    security_group_id = "${aws_security_group.slave.id}"
}
