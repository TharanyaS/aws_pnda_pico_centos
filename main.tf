resource "aws_instance" "vnc_instance" {
  ami                                  = "${var.console_image_id}"
  instance_type                        = "${var.ConsoleFlavor}"
  key_name                             = "${var.aws_ssh_key_name}"
  disable_api_termination              = "false"
  instance_initiated_shutdown_behavior = "stop"
  monitoring                           = "false"
  security_groups                      = ["${aws_security_group.consoleSg_security_group.name}"]

  ebs_block_device {
    device_name = "/dev/sda1"
    volume_size = 30
  }

  associate_public_ip_address = "false"

  tags {
    Name         = "${var.cluster_name}-console"
    node_type    = "vnc"
    pnda_cluster = "${var.cluster_name}"
    node_idx     = ""
  }
}

resource "aws_instance" "gateway_instance" {
  ami                                  = "${var.image_id}"
  instance_type                        = "${var.BastionFlavor}"
  key_name                             = "${var.aws_ssh_key_name}"
  disable_api_termination              = "false"
  instance_initiated_shutdown_behavior = "stop"
  monitoring                           = "false"
  security_groups                      = ["${aws_security_group.sshSg_security_group.name}", "${aws_security_group.UISg_security_group.name}"]

  ebs_block_device = [{
    device_name = "/dev/sda1"
    volume_size = 30
  },
    {
      device_name = "/dev/sdc"
      volume_size = "${var.logvolumesize}"
    },
  ]

  associate_public_ip_address = "false"

  tags {
    Name         = "${var.cluster_name}-gateway"
    node_type    = "gateway"
    pnda_cluster = "${var.cluster_name}"
    node_idx     = ""
  }
}

resource "aws_instance" "edge_instance" {
  ami                                  = "${var.image_id}"
  instance_type                        = "${var.EdgeFlavor}"
  key_name                             = "${var.aws_ssh_key_name}"
  disable_api_termination              = "false"
  instance_initiated_shutdown_behavior = "stop"
  monitoring                           = "false"
  security_groups                      = ["${aws_security_group.sshSg_security_group.name}", "${aws_security_group.UISg_security_group.name}"]

  root_block_device {
    volume_size           = 30
    delete_on_termination = "true"
  }

  ebs_block_device = [{
    device_name = "/dev/sdc"
    volume_size = "${var.logvolumesize}"
  }]

  associate_public_ip_address = "false"

  tags {
    Name         = "${var.cluster_name}-hadoop-edge"
    node_type    = "hadoop-edge"
    pnda_cluster = "${var.cluster_name}"
    node_idx     = ""
  }
}

resource "aws_instance" "mgr1_instance" {
  ami                                  = "${var.image_id}"
  instance_type                        = "${var.Manager1Flavor}"
  key_name                             = "${var.aws_ssh_key_name}"
  disable_api_termination              = "false"
  instance_initiated_shutdown_behavior = "stop"
  monitoring                           = "false"
  security_groups                      = ["${aws_security_group.sshSg_security_group.name}", "${aws_security_group.UISg_security_group.name}"]

  ebs_block_device = [{
    device_name = "/dev/sda1"
    volume_size = 30
  },
    {
      device_name = "/dev/sdc"
      volume_size = "${var.logvolumesize}"
    },
  ]

  associate_public_ip_address = "false"

  tags {
    Name         = "${var.cluster_name}-hadoop-mgr-1"
    node_type    = "hadoop-mgr"
    pnda_cluster = "${var.cluster_name}"
    node_idx     = ""
  }
}

resource "aws_instance" "kafka_instance" {
  ami                                  = "${var.image_id}"
  instance_type                        = "${var.KafkaFlavor}"
  key_name                             = "${var.aws_ssh_key_name}"
  disable_api_termination              = "false"
  instance_initiated_shutdown_behavior = "stop"
  monitoring                           = "false"
  security_groups                      = ["${aws_security_group.sshSg_security_group.name}", "${aws_security_group.UISg_security_group.name}"]
  count                                = "${var.number_of_kafkanodes}"

  ebs_block_device = [{
    device_name = "/dev/sda1"
    volume_size = 30
  },
    {
      device_name = "/dev/sdc"
      volume_size = "${var.logvolumesize}"
    },
  ]

  associate_public_ip_address = "false"

  tags {
    Name         = "${var.cluster_name}-kafka-${count.index}"
    node_type    = "kafka"
    pnda_cluster = "${var.cluster_name}"
    node_idx     = "${count.index}"
  }
}

resource "aws_instance" "dn_instance" {
  ami                                  = "${var.image_id}"
  instance_type                        = "${var.DatanodeFlavor}"
  key_name                             = "${var.aws_ssh_key_name}"
  disable_api_termination              = "false"
  instance_initiated_shutdown_behavior = "stop"
  monitoring                           = "false"
  security_groups                      = ["${aws_security_group.sshSg_security_group.name}", "${aws_security_group.UISg_security_group.name}"]
  count                                = "${var.number_of_datanodes}"

  root_block_device {
    volume_size           = 30
    delete_on_termination = "true"
  }

  ebs_block_device = [{
    device_name = "/dev/sdc"
    volume_size = "${var.logvolumesize}"
  },
    {
      device_name = "/dev/sdd"
      volume_size = 35
    },
  ]

  associate_public_ip_address = "false"

  tags {
    Name         = "${var.cluster_name}-hadoop-dn-${count.index}"
    node_type    = "hadoop-dn"
    pnda_cluster = "${var.cluster_name}"
    node_idx     = "${count.index}"
  }
}

resource "aws_eip" "vnc_eip" {
  instance = "${aws_instance.vnc_instance.id}"
}

resource "aws_eip" "gateway_eip" {
  instance = "${aws_instance.gateway_instance.id}"
}

resource "aws_eip" "edge_eip" {
  instance = "${aws_instance.edge_instance.id}"
}

resource "aws_eip" "mgr1_eip" {
  instance = "${aws_instance.mgr1_instance.id}"
}

resource "aws_eip" "kafka_eip" {
  count    = "${var.number_of_kafkanodes}"
  instance = "${element(aws_instance.kafka_instance.*.id, count.index)}"
}

resource "aws_eip" "dn_eip" {
  count    = "${var.number_of_datanodes}"
  instance = "${element(aws_instance.dn_instance.*.id, count.index)}"
}

resource "aws_security_group" "sshSg_security_group" {
  depends_on  = ["null_resource.keypermission"]
  description = "Access to pnda instances"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.whitelistSshAccess}"]
  }

  ingress {
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = "true"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "consoleSg_security_group" {
  description = "Console access"

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = "true"
  }
}

resource "aws_security_group" "UISg_security_group" {
  description = "Access to pnda via public IP"

  ingress {
    from_port   = 25
    to_port     = 25
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 123
    to_port     = 123
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 2181
    to_port     = 2181
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3000
    to_port     = 3001
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3123
    to_port     = 3123
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 4242
    to_port     = 4242
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5601
    to_port     = 5601
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8020
    to_port     = 8020
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8082
    to_port     = 8082
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8088
    to_port     = 8088
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8888
    to_port     = 8888
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9092
    to_port     = 9092
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9090
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = ["${var.whitelistKafkaAccess}"]
  }

  ingress {
    from_port   = 10000
    to_port     = 10000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 10900
    to_port     = 10900
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 11000
    to_port     = 11000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 14000
    to_port     = 14000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 16010
    to_port     = 16010
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 18080
    to_port     = 18080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 19888
    to_port     = 19888
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 20550
    to_port     = 20550
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 50070
    to_port     = 50070
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "null_resource" "keypermission" {
  provisioner "local-exec" {
    command = "chmod 400 ${var.ssh_key_name}.pem"
  }
}

resource "local_file" "cluster_ip_file" {
  depends_on = ["aws_instance.gateway_instance", "aws_instance.edge_instance", "aws_instance.mgr1_instance", "aws_instance.kafka_instance", "aws_instance.dn_instance"]
  content    = "gateway_private_ip: ${ aws_instance.gateway_instance.private_ip } \npublic_ip: ${ aws_eip.gateway_eip.public_ip } \nhadoop-edge_private_ip: ${ aws_instance.edge_instance.private_ip } \nhadoop-mgr-1_private_ip: ${ aws_instance.mgr1_instance.private_ip }\nhadoop-dn_private_ip: [${join(",",aws_instance.dn_instance.*.private_ip)}] \nkafka_private_ip: [${join(",", aws_instance.kafka_instance.*.private_ip)}]"
  filename   = "${path.cwd}/output.yaml"
}

resource "null_resource" "deploy_PNDA" {
  depends_on = [
    "local_file.cluster_ip_file",
    "null_resource.install_requirement",
    "null_resource.keypermission",
  ]

  provisioner "local-exec" {
    command = "python create_pico.py create -b ${var.branch} -u ${var.ssh_user} -s ${var.ssh_key_name} -f pico -i ${var.mirror_server_ip} -e ${var.cluster_name} -a ${var.access_key} -r ${var.region} -k ${var.secret_key}"
  }
}

resource "null_resource" "install_requirement" {
  depends_on = ["local_file.cluster_ip_file"]

  provisioner "local-exec" {
    command = "chmod +x requirements.sh && ./requirements.sh"
  }
}

resource "local_file" "hosts_file" {
  depends_on = ["aws_instance.vnc_instance"]
  content    = "mirror ansible_host=${aws_eip.vnc_eip.public_ip} kafka_ip=${aws_instance.kafka_instance.0.private_ip} edge_ip=${aws_instance.edge_instance.private_ip} mgr1_ip=${aws_instance.mgr1_instance.private_ip} kafka=${aws_instance.kafka_instance.0.tags.Name} edge=${aws_instance.edge_instance.tags.Name} mgr1=${aws_instance.mgr1_instance.tags.Name} mgr1domain=${aws_instance.mgr1_instance.tags.Name}.node.dc1.pnda.local"
  filename   = "${path.cwd}/hosts"
}

resource "null_resource" "keypermisions" {
  depends_on = ["local_file.hosts_file"]

  provisioner "local-exec" {
    command = "chmod 400 ${var.aws_ssh_key_name}.pem"
  }
}

resource "null_resource" "ansiblerun" {
  depends_on = ["local_file.hosts_file", "null_resource.keypermisions"]

  provisioner "local-exec" {
    command = "export ANSIBLE_CONFIG=./ansible/ansible.cfg && export ANSIBLE_HOST_KEY_CHECKING=False && ansible-playbook --user=${var.console_user} -i hosts --key-file=${var.aws_ssh_key_name}.pem ${var.playbookpath}/${var.playbookname}"
  }
}

resource "local_file" "externalurl" {
  depends_on = ["null_resource.deploy_PNDA"]
  content    = "{ \"dashboard\": \"http://${aws_eip.vnc_eip.public_ip}\" }"
  filename   = "${path.cwd}/externalURL.json"
}
