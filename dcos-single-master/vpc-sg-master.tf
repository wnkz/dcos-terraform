resource "aws_security_group" "master" {
    name        = "dcos-MasterSecurityGroup"
    description = "Mesos Masters"
    vpc_id      = "${aws_vpc.dcos.id}"

    tags {
        "Environment" = "dcos"
    }
}

resource "aws_security_group_rule" "master" {
    type = "ingress"
    from_port = 0
    to_port = 0
    protocol = "-1"
    self = true

    security_group_id = "${aws_security_group.master.id}"
}

resource "aws_security_group_rule" "slave_to_master" {
    type = "ingress"
    from_port = 0
    to_port = 0
    protocol = "-1"

    security_group_id = "${aws_security_group.master.id}"
    source_security_group_id = "${aws_security_group.slave.id}"
}

resource "aws_security_group_rule" "public_slave_to_master" {
    type = "ingress"
    from_port = 0
    to_port = 0
    protocol = "-1"

    security_group_id = "${aws_security_group.master.id}"
    source_security_group_id = "${aws_security_group.public_slave.id}"
}

resource "aws_security_group_rule" "lb_to_master1" {
    type = "ingress"
    from_port = 5050
    to_port = 5050
    protocol = "tcp"

    security_group_id = "${aws_security_group.master.id}"
    source_security_group_id = "${aws_security_group.lb.id}"
}

resource "aws_security_group_rule" "lb_to_master2" {
    type = "ingress"
    from_port = 2181
    to_port = 2181
    protocol = "tcp"

    security_group_id = "${aws_security_group.master.id}"
    source_security_group_id = "${aws_security_group.lb.id}"
}

resource "aws_security_group_rule" "lb_to_master3" {
    type = "ingress"
    from_port = 8181
    to_port = 8181
    protocol = "tcp"

    security_group_id = "${aws_security_group.master.id}"
    source_security_group_id = "${aws_security_group.lb.id}"
}

resource "aws_security_group_rule" "lb_to_master4" {
    type = "ingress"
    from_port = 8080
    to_port = 8080
    protocol = "tcp"

    security_group_id = "${aws_security_group.master.id}"
    source_security_group_id = "${aws_security_group.lb.id}"
}

resource "aws_security_group_rule" "lb_to_master5" {
    type = "ingress"
    from_port = 80
    to_port = 80
    protocol = "tcp"

    security_group_id = "${aws_security_group.master.id}"
    source_security_group_id = "${aws_security_group.lb.id}"
}

resource "aws_security_group_rule" "master_outbound" {
    type = "egress"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]

    security_group_id = "${aws_security_group.master.id}"
}
