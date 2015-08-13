resource "aws_iam_user" "dcos" {
    name = "dcos-IAMUser"
    path = "/"
}

resource "aws_iam_user_policy" "root" {
    name   = "root"
    user   = "${aws_iam_user.dcos.name}"
    policy = <<POLICY
{
  "Statement": [
    {
      "Resource": [
        "arn:aws:s3:::${aws_s3_bucket.exhibitor.id}/*",
        "arn:aws:s3:::${aws_s3_bucket.exhibitor.id}"
      ],
      "Action": [
        "s3:AbortMultipartUpload",
        "s3:DeleteObject",
        "s3:GetBucketAcl",
        "s3:GetBucketPolicy",
        "s3:GetObject",
        "s3:GetObjectAcl",
        "s3:ListBucket",
        "s3:ListBucketMultipartUploads",
        "s3:ListMultipartUploadParts",
        "s3:PutObject",
        "s3:PutObjectAcl"
      ],
      "Effect": "Allow"
    },
    {
      "Resource": "*",
      "Action": [
        "ec2:DescribeKeyPairs",
        "ec2:DescribeSubnets",
        "autoscaling:DescribeLaunchConfigurations",
        "autoscaling:UpdateAutoScalingGroup",
        "autoscaling:DescribeAutoScalingGroups",
        "autoscaling:DescribeScalingActivities",
        "elasticloadbalancing:DescribeLoadBalancers"
      ],
      "Effect": "Allow"
    }
  ],
  "Version": "2012-10-17"
}
POLICY
}

resource "aws_iam_role" "master" {
    name = "dcos-MasterRole"
    path = "/"
    assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy" "root" {
    name = "root"
    role = "${aws_iam_role.master.unique_id}"
    policy = <<POLICY
{
  "Statement": [
    {
      "Resource": [
        "arn:aws:s3:::dcos-ea-exhibitors3bucket-8uy23n8zav0j/*",
        "arn:aws:s3:::dcos-ea-exhibitors3bucket-8uy23n8zav0j"
      ],
      "Action": [
        "s3:AbortMultipartUpload",
        "s3:DeleteObject",
        "s3:GetBucketAcl",
        "s3:GetBucketPolicy",
        "s3:GetObject",
        "s3:GetObjectAcl",
        "s3:ListBucket",
        "s3:ListBucketMultipartUploads",
        "s3:ListMultipartUploadParts",
        "s3:PutObject",
        "s3:PutObjectAcl"
      ],
      "Effect": "Allow"
    },
    {
      "Resource": [
        "arn:aws:cloudformation:us-east-1:377056401362:stack/dcos-ea/cd5acf30-3acf-11e5-9767-500150b34c18",
        "arn:aws:cloudformation:us-east-1:377056401362:stack/dcos-ea/cd5acf30-3acf-11e5-9767-500150b34c18/*"
      ],
      "Action": [
        "cloudformation:*"
      ],
      "Effect": "Allow"
    },
    {
      "Resource": "*",
      "Action": [
        "ec2:DescribeKeyPairs",
        "ec2:DescribeSubnets",
        "autoscaling:DescribeLaunchConfigurations",
        "autoscaling:UpdateAutoScalingGroup",
        "autoscaling:DescribeAutoScalingGroups",
        "autoscaling:DescribeScalingActivities",
        "elasticloadbalancing:DescribeLoadBalancers"
      ],
      "Effect": "Allow"
    }
  ],
  "Version": "2012-10-17"
}
POLICY
}

resource "aws_iam_instance_profile" "master" {
    name  = "dcos-MasterInstanceProfile"
    path  = "/"
    roles = ["${aws_iam_role.master.unique_id}"]
}
