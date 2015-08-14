resource "aws_elb" "internal" {
    name = "dcos-InternalMasterLoadBalancer"
    subnets = ["${aws_subnet.public.id}"]
    security_groups = ["${aws_security_group.lb.id}", "${aws_security_group.slave.id}", "${aws_security_group.admin.id}", "${aws_security_group.public_slave.id}", "${aws_security_group.master.id}"]
    cross_zone_load_balancing = false
    idle_timeout = 60
    connection_draining = false
    connection_draining_timeout = 300
    internal = true

    listener {
        instance_port = 8181
        instance_protocol = "http"
        lb_port = 8181
        lb_protocol = "http"
        ssl_certificate_id = ""
    }

    listener {
        instance_port = 2181
        instance_protocol = "tcp"
        lb_port = 2181
        lb_protocol = "tcp"
        ssl_certificate_id = ""
    }

    listener {
        instance_port = 443
        instance_protocol = "tcp"
        lb_port = 443
        lb_protocol = "tcp"
        ssl_certificate_id = ""
    }

    listener {
        instance_port = 80
        instance_protocol = "http"
        lb_port = 80
        lb_protocol = "http"
        ssl_certificate_id = ""
    }

    listener {
        instance_port = 8080
        instance_protocol = "http"
        lb_port = 8080
        lb_protocol = "http"
        ssl_certificate_id = ""
    }

    listener {
        instance_port = 5050
        instance_protocol = "http"
        lb_port = 5050
        lb_protocol = "http"
        ssl_certificate_id = ""
    }

    health_check {
        healthy_threshold = 2
        unhealthy_threshold = 2
        interval = 30
        target = "HTTP:5050/health"
        timeout = 5
    }

    tags {
        Environment = "dcos"
    }
}
