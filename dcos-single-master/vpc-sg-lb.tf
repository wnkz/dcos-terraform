resource "aws_security_group" "lb" {
    name = "dcos-LbSecurityGroup"
    description = "Mesos Master LB"
    vpc_id = "${aws_vpc.dcos.id}"

    tags {
        "Environment" = "dcos"
    }
}

resource "aws_security_group_rule" "lb1" {
    type = "ingress"
    from_port = 2181
    to_port = 2181
    protocol = "tcp"

    security_group_id = "${aws_security_group.lb.id}"
    source_security_group_id = "${aws_security_group.slave.id}"
}

resource "aws_security_group_rule" "lb2" {
    type = "egress"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]

    security_group_id = "${aws_security_group.lb.id}"
}
