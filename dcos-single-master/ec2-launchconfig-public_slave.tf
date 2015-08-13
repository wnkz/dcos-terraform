resource "aws_launch_configuration" "public_slave" {
    image_id = "${lookup(var.coreos_amis, var.aws_region)}"
    instance_type = "m4.xlarge"
    key_name = "${var.key_name}"
    security_groups = ["${aws_security_group.public_slave.id}"]
    associate_public_ip_address = true
    enable_monitoring = true
    ebs_optimized = true

    root_block_device {
        volume_type = "gp2"
        volume_size = 8
        delete_on_termination = true
    }

    ebs_block_device {
        device_name = "/dev/sdb"
        volume_type = "gp2"
        volume_size = 100
        delete_on_termination = true
    }

    user_data = <<EOF
#cloud-config
write_files:
  - path: /etc/mesosphere/setup-flags/repository-url
    permissions: 0644
    owner: root
    content: |
      https://downloads.mesosphere.io/dcos/stable

  - path: /etc/mesosphere/roles/slave_public

  - path: /etc/mesosphere/setup-packages/dcos-config--setup/pkginfo.json
    content: '{}'
  - path: /etc/mesosphere/setup-packages/dcos-config--setup/etc/mesos-dns.json
    content: |
      {
        "zk": "zk://127.0.0.1:2181/mesos",
        "refreshSeconds": 30,
        "ttl": 60,
        "domain": "mesos",
        "port": 53,
        "resolvers": ["10.0.0.2"],
        "timeout": 5,
        "listener": "0.0.0.0",
        "email": "root.mesos-dns.mesos"
      }
  - path: /etc/mesosphere/setup-packages/dcos-config--setup/etc/mesos-master
    content: |
      MESOS_LOG_DIR=/var/log/mesos
      MESOS_WORK_DIR=/var/lib/mesos/master
      MESOS_ZK=zk://127.0.0.1:2181/mesos
      MESOS_QUORUM=1
      MESOS_CLUSTER=dcos-ea
      MESOS_ROLES=slave_public
  - path: /etc/mesosphere/setup-packages/dcos-config--setup/etc/mesos-slave
    content: |
      MESOS_MASTER=zk://leader.mesos:2181/mesos
      MESOS_CONTAINERIZERS=docker,mesos
      MESOS_LOG_DIR=/var/log/mesos
      MESOS_EXECUTOR_REGISTRATION_TIMEOUT=5mins
      MESOS_ISOLATION=cgroups/cpu,cgroups/mem
      MESOS_WORK_DIR=/var/lib/mesos/slave
      MESOS_RESOURCES=ports:[1025-2180,2182-3887,3889-5049,5052-8079,8082-8180,8182-65535]
      MESOS_SLAVE_SUBSYSTEMS=cpu,memory
  - path: /etc/mesosphere/setup-packages/dcos-config--setup/etc/mesos-slave-public
    content: |
      MESOS_MASTER=zk://leader.mesos:2181/mesos
      MESOS_CONTAINERIZERS=docker,mesos
      MESOS_LOG_DIR=/var/log/mesos
      MESOS_EXECUTOR_REGISTRATION_TIMEOUT=5mins
      MESOS_ISOLATION=cgroups/cpu,cgroups/mem
      MESOS_WORK_DIR=/var/lib/mesos/slave
      MESOS_RESOURCES=ports:[1-21,23-5050,5052-65535]
      MESOS_SLAVE_SUBSYSTEMS=cpu,memory
      MESOS_DEFAULT_ROLE=slave_public
      MESOS_ATTRIBUTES=public_ip:true

  - path: /etc/mesosphere/setup-packages/dcos-config--setup/etc/cloudenv
    content: |
      AWS_REGION=us-east-1
      AWS_STACK_ID=arn:aws:cloudformation:us-east-1:377056401362:stack/dcos-ea/cd5acf30-3acf-11e5-9767-500150b34c18
      AWS_STACK_NAME=dcos-ea
      AWS_ACCESS_KEY_ID=AKIAIOC7DB4RXXJ5OFSQ
      AWS_SECRET_ACCESS_KEY=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
      ZOOKEEPER_CLUSTER_SIZE=1
      MASTER_ELB=internal-dcos-ea-InternalMa-1G59QJV4DKIWK-2042233934.us-east-1.elb.amazonaws.com
      EXTERNAL_ELB=dcos-ea-ElasticLoa-11FCHY9433KXM-1085728503.us-east-1.elb.amazonaws.com
      # Must set FALLBACK_DNS to an AWS region-specific DNS server which returns
      # the internal IP when doing lookups on AWS public hostnames.
      FALLBACK_DNS=10.0.0.2
  - path: /etc/mesosphere/setup-packages/dcos-config--setup/etc/exhibitor
    content: |
      AWS_S3_BUCKET=dcos-ea-exhibitors3bucket-8uy23n8zav0j
      AWS_S3_PREFIX=dcos-ea
      EXHIBITOR_WEB_UI_PORT=8181

coreos:
  update:
    reboot-strategy: off
  units:
    - name: format-var-lib-ephemeral.service
      command: start
      content: |
        [Unit]
        Description=Formats the /var/lib ephemeral drive
        Before=var-lib.mount dbus.service
        [Service]
        Type=oneshot
        RemainAfterExit=yes
        ExecStart=/bin/bash -c '(blkid -t TYPE=ext4 | grep xvdb) || (/usr/sbin/mkfs.ext4 -F /dev/xvdb)'
    - name: var-lib.mount
      command: start
      content: |
        [Unit]
        Description=Mount /var/lib
        Before=dbus.service
        [Mount]
        What=/dev/xvdb
        Where=/var/lib
        Type=ext4

    - name: etcd.service
      mask: true
      command: stop
    - name: update-engine.service
      mask: true
      command: stop
    - name: locksmithd.service
      mask: true
      command: stop
    - name: systemd-resolved.service
      command: stop
    - name: config-writer.service
      command: start
      content: |
        [Unit]
        Description=Write out dynamic config values
        [Service]
        Type=oneshot
        ExecStart=/usr/bin/bash -c "echo EXHIBITOR_HOSTNAME=$(curl -s http://169.254.169.254/latest/meta-data/hostname) >> /etc/mesosphere/setup-packages/dcos-config--setup/etc/cloudenv"
        ExecStart=/usr/bin/bash -c "echo MARATHON_HOSTNAME=$(curl -s http://169.254.169.254/latest/meta-data/hostname) >> /etc/mesosphere/setup-packages/dcos-config--setup/etc/cloudenv"
        ExecStart=/usr/bin/bash -c "echo MESOS_HOSTNAME=$(curl -s http://169.254.169.254/latest/meta-data/hostname) >> /etc/mesosphere/setup-packages/dcos-config--setup/etc/mesos-master"
        ExecStart=/usr/bin/bash -c "echo MESOS_HOSTNAME=$(curl -s http://169.254.169.254/latest/meta-data/hostname) >> /etc/mesosphere/setup-packages/dcos-config--setup/etc/mesos-slave"

    - name: link-env.service
      command: start
      content: |
        [Unit]
        Before=dcos.target
        [Service]
        Type=oneshot
        ExecStartPre=/usr/bin/mkdir -p /etc/profile.d
        ExecStart=/usr/bin/ln -sf /opt/mesosphere/environment.export /etc/profile.d/dcos.sh
    - name: dcos-download.service
      content: |
        [Unit]
        Description=Download the DCOS
        After=network-online.target
        Wants=network-online.target
        ConditionPathExists=!/opt/mesosphere/
        [Service]
        Type=oneshot
        ExecStartPre=/usr/bin/bash -c 'until wget --progress=dot -e dotbytes=10M --continue https://downloads.mesosphere.io/dcos/stable/bootstrap.tar.xz -O /tmp/bootstrap.tar.xz; do echo "failed to download"; sleep 5; done'
        ExecStartPre=/usr/bin/mkdir -p /opt/mesosphere
        ExecStart=/usr/bin/tar -axf /tmp/bootstrap.tar.xz -C /opt/mesosphere
    - name: dcos-setup.service
      command: start
      enable: true
      content: |
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
    - name: cfn-signal.service
      command: start
      content: |
        [Unit]
        Description=Signal CloudFormation Success
        After=dcos.target
        Requires=dcos.target
        ConditionPathExists=!/var/lib/cfn-signal
        [Service]
        Type=simple
        Restart=on-failure
        StartLimitInterval=0
        RestartSec=15s
        ExecStartPre=/usr/bin/docker pull mbabineau/cfn-bootstrap
        ExecStartPre=/bin/ping -c1 leader.mesos
        ExecStartPre=/usr/bin/docker run --rm mbabineau/cfn-bootstrap \
          cfn-signal -e 0 \
          --resource PublicSlaveServerGroup \
          --stack dcos-ea \
          --region us-east-1
        ExecStart=/usr/bin/touch /var/lib/cfn-signal
EOF
}

    lifecycle {
        create_before_destroy = true
    }
}
