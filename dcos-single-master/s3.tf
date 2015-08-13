resource "aws_s3_bucket" "exhibitor" {
    bucket = "dcos-exhibitors3bucket"
    acl = "private"

    tags {
        Environment = "dcos"
    }
}
