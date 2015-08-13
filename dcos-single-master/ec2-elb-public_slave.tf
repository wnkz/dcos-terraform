resource "aws_elb" "public_slave" {
    name = "dcos-PublicSlave"
    subnets = ["${aws_subnet.public.id}"]
    security_groups = ["${aws_security_group.public_slave.id}"]
    cross_zone_load_balancing = false
    idle_timeout = 60
    connection_draining = false
    connection_draining_timeout = 300

    listener {
        instance_port = 80
        instance_protocol = "http"
        lb_port = 80
        lb_protocol = "http"
        ssl_certificate_id = ""
    }

    listener {
        instance_port = 443
        instance_protocol = "tcp"
        lb_port = 443
        lb_protocol = "tcp"
        ssl_certificate_id = ""
    }

    health_check {
        healthy_threshold = 2
        unhealthy_threshold = 2
        interval = 30
        target = "TCP:80"
        timeout = 5
    }

    tags {
        Environment = "dcos"
    }
}
