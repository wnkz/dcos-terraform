resource "aws_launch_configuration" "master" {
    image_id = "${lookup(var.coreos_amis, var.aws_region)}"
    instance_type = "${var.master_instance_type}"
    key_name = "${var.key_name}"
    security_groups = ["${aws_security_group.master.id}", "${aws_security_group.admin.id}"]
    associate_public_ip_address = true
    enable_monitoring = true
    ebs_optimized = true
    iam_instance_profile = "${aws_iam_instance_profile.master.name}"

    root_block_device {
        volume_type = "gp2"
        volume_size = 8
        delete_on_termination = true
    }

    ebs_block_device {
        device_name = "/dev/xvdb"
        volume_type = "gp2"
        volume_size = 20
        delete_on_termination = true
    }

    user_data = <<EOF
#cloud-config
"coreos":
  "units":
  - "command": |-
      start
    "content": |-
      [Unit]
      Description=Write out dynamic config values
      [Service]
      Type=oneshot
      # TODO(cmaloney): Remove these and get rid of the bits that require them.
      ExecStart=/usr/bin/bash -c "echo EXHIBITOR_HOSTNAME=$(curl -s http://169.254.169.254/latest/meta-data/hostname) >> /etc/mesosphere/setup-packages/dcos-provider-aws--setup/etc/cloudenv"
      ExecStart=/usr/bin/bash -c "echo MARATHON_HOSTNAME=$(curl -s http://169.254.169.254/latest/meta-data/hostname) >> /etc/mesosphere/setup-packages/dcos-provider-aws--setup/etc/cloudenv"
    "name": |-
      config-writer.service
  - "command": |-
      stop
    "mask": !!bool |-
      true
    "name": |-
      etcd.service
  - "command": |-
      stop
    "mask": !!bool |-
      true
    "name": |-
      update-engine.service
  - "command": |-
      stop
    "mask": !!bool |-
      true
    "name": |-
      locksmithd.service
  - "command": |-
      stop
    "name": |-
      systemd-resolved.service
  - "command": |-
      start
    "content": |
      [Unit]
      Description=Formats the /var/lib ephemeral drive
      Before=var-lib.mount dbus.service
      [Service]
      Type=oneshot
      RemainAfterExit=yes
      ExecStart=/bin/bash -c '(blkid -t TYPE=ext4 | grep xvdb) || (/usr/sbin/mkfs.ext4 -F /dev/xvdb)'
    "name": |-
      format-var-lib-ephemeral.service
  - "command": |-
      start
    "content": |-
      [Unit]
      Description=Mount /var/lib
      Before=dbus.service
      [Mount]
      What=/dev/xvdb
      Where=/var/lib
      Type=ext4
    "name": |-
      var-lib.mount
  - "command": |-
      start
    "content": |
      [Unit]
      Before=dcos.target
      [Service]
      Type=oneshot
      ExecStartPre=/usr/bin/mkdir -p /etc/profile.d
      ExecStart=/usr/bin/ln -sf /opt/mesosphere/environment.export /etc/profile.d/dcos.sh
    "name": |-
      link-env.service
  - "content": |
      [Unit]
      Description=Download the DCOS
      After=network-online.target
      Wants=network-online.target
      ConditionPathExists=!/opt/mesosphere/
      [Service]
      EnvironmentFile=/etc/mesosphere/setup-flags/bootstrap-id
      Type=oneshot
      ExecStartPre=/usr/bin/bash -c "until wget --progress=dot -e dotbytes=10M --continue https://downloads.mesosphere.com/dcos/EarlyAccess/bootstrap/$${BOOTSTRAP_ID}.bootstrap.tar.xz -O /tmp/bootstrap.tar.xz; do echo 'failed to download'; sleep 5; done"
      ExecStartPre=/usr/bin/mkdir -p /opt/mesosphere
      ExecStart=/usr/bin/tar -axf /tmp/bootstrap.tar.xz -C /opt/mesosphere
      ExecStartPost=-/usr/bin/rm -f /tmp/bootstrap.tar.xz
    "name": |-
      dcos-download.service
  - "command": |-
      start
    "content": |-
      [Unit]
      Description=Prep the Pkgpanda working directories for this host.
      Requires=dcos-download.service
      After=dcos-download.service
      [Service]
      Type=oneshot
      EnvironmentFile=/opt/mesosphere/environment
      ExecStart=/opt/mesosphere/bin/pkgpanda setup --no-block-systemd
      [Install]
      WantedBy=multi-user.target
    "enable": !!bool |-
      true
    "name": |-
      dcos-setup.service
  "update":
    "reboot-strategy": |-
      off
"write_files":
- "content": |
    https://downloads.mesosphere.com/dcos/EarlyAccess
  "owner": |-
    root
  "path": |-
    /etc/mesosphere/setup-flags/repository-url
  "permissions": !!int |-
    420
- "content": |
    BOOTSTRAP_ID=9e9fb00a14d28255246585f1088cdf81dcf121c2
  "owner": |-
    root
  "path": |-
    /etc/mesosphere/setup-flags/bootstrap-id
  "permissions": !!int |-
    420
- "content": |-
    ["dcos-config--setup_f85e9b37baa6a6e576295efa91ae64d15a3d2320"]
  "owner": |-
    root
  "path": |-
    /etc/mesosphere/setup-flags/cluster-packages.json
  "permissions": !!int |-
    420
- "content": |
    {
      "environment": {
        "PROVIDER": "aws"
      }
    }
  "path": |-
    /etc/mesosphere/setup-packages/dcos-provider-aws--setup/pkginfo.json
- "content": |
    AWS_REGION=${var.aws_region}
    AWS_ACCESS_KEY_ID=${aws_iam_access_key.dcos.id}
    AWS_SECRET_ACCESS_KEY=${aws_iam_access_key.dcos.secret}
    ZOOKEEPER_CLUSTER_SIZE=1
    MASTER_ELB=${aws_elb.internal.dns_name}
    EXTERNAL_ELB=${aws_elb.default.dns_name}
    # Must set FALLBACK_DNS to an AWS region-specific DNS server which returns
    # the internal IP when doing lookups on AWS public hostnames.
    FALLBACK_DNS=10.0.0.2
  "path": |-
    /etc/mesosphere/setup-packages/dcos-provider-aws--setup/etc/cloudenv
- "content": |
    MESOS_CLUSTER=dcos
  "path": |-
    /etc/mesosphere/setup-packages/dcos-provider-aws--setup/etc/mesos-master-provider
- "content": |
    AWS_S3_BUCKET=${aws_s3_bucket.exhibitor.id}
    AWS_S3_PREFIX=dcos
    EXHIBITOR_WEB_UI_PORT=8181
  "path": |-
    /etc/mesosphere/setup-packages/dcos-provider-aws--setup/etc/exhibitor
- "content": ""
  "path": |-
    /etc/mesosphere/roles/master
- "content": ""
  "path": |-
    /etc/mesosphere/roles/aws_master
- "content": ""
  "path": |-
    /etc/mesosphere/roles/aws
EOF

    lifecycle {
        create_before_destroy = true
    }
}
