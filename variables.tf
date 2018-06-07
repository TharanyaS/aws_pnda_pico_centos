variable "access_key" {}

variable "secret_key" {}

variable "region" {}

variable "ssh_key_name" {
  "default" = "ubuntu_key"
}

variable "mirror_server_ip" {
  "type" = "string"
}

variable "cluster_name" {
  "type"        = "string"
  "default"     = "pnda-centos"
  "description" = "Name for the cluster"
}

variable "console_image_id" {
  "type"        = "string"
  "default"     = "ami-b6ca76d6"
  "description" = "Image to use for instances"
}

variable "image_id" {
  "type"        = "string"
  "default"     = "ami-4543be3d"
  "description" = "Image to use for instances"
}

variable "logvolumesize" {
  "type"        = "string"
  "default"     = "20"
  "description" = "Size in GB for the log volume"
}

variable "BastionFlavor" {
  "type"        = "string"
  "default"     = "m4.large"
  "description" = "Instance type for the access bastion"
}

variable "ConsoleFlavor" {
  "type"        = "string"
  "default"     = "m4.large"
  "description" = "Instance type for databus combined instance"
}

variable "KafkaFlavor" {
  "type"        = "string"
  "default"     = "m4.large"
  "description" = "Instance type for databus combined instance"
}

variable "Manager1Flavor" {
  "type"        = "string"
  "default"     = "m4.xlarge"
  "description" = "Instance type for CDH management"
}

variable "DatanodeFlavor" {
  "type"        = "string"
  "default"     = "c4.xlarge"
  "description" = "Instance type for CDH datanode"
}

variable "EdgeFlavor" {
  "type"        = "string"
  "default"     = "m4.2xlarge"
  "description" = "Instance type for cluster edge node"
}

variable "number_of_datanodes" {
  "default" = 1
}

variable "number_of_kafkanodes" {
  "default" = 1
}

variable "whitelistSshAccess" {
  "type"        = "string"
  "default"     = "0.0.0.0/0"
  "description" = "Whitelist for external access to ssh"
}

variable "whitelistKafkaAccess" {
  "type"        = "string"
  "default"     = "0.0.0.0/0"
  "description" = "Whitelist for external access to Kafka"
}

variable "dhcpDomain" {
  "type"        = "string"
  "default"     = "eu-west-1.compute.internal"
  "description" = "Domain name for instances"
}

variable "ssh_user" {
  "type"        = "string"
  "default"     = "centos"
  "description" = "user name to login to the instance"
}

variable "branch" {
  "default" = "develop"
}

variable "console_user" {
  "default" = "ubuntu"
}

variable "playbookpath" {
  "default" = "./ansible"
}

variable "playbookname" {
  "default" = "playbook.yml"
}

variable "ssh_key_path" {
  "default" = "./keys"
}

#availability zones: us-east-1a, us-east-1b, us-east-1c, us-east-1d, us-east-1e, us-east-1f.

