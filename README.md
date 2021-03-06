# Terraform - Kitchen Extensive Suite

This example shows how Terraform driver hooks up with Kitchen framework where the same Terraform provision scripts are tested against multiple AWS regions.

## Terraform

The core Terraform scripts consist of:

- 00-variable.tf

All variable declaration is located in this file

- 01-main.tf

The file is primarily for resources creation. It expects to run on a latest version of Terraform from 0.11.4 onward and below 0.12.0 by using the `terraform` block syntax below.

```
terraform {
  # The configuration is restricted to Terraform versions supported by
  # Kitchen-Terraform
  required_version = ">= 0.11.4, < 0.12.0"
}
```

The script creates a VPC network using AWS provider with subnet and internet gateway that is associated with a route table that allowing traffic from the outside VPC forwarded to the associated subnet inside. The EC2 instances are created with minimum security control under a relaxed ingress and egress rules that allows traffic with any source and destination IP address and ports.

The EC2 instances are defined in 2 different groups. The groups of instances are created using `aws_instance`. The control `operating_system` is used to demonstrate ssh connection between 2 groups that are setup with the security group with bare minimum ingress and egress rules.

```
resource "aws_instance" "reachable_other_host" {
  ami                         = "${var.instances_ami}"
  associate_public_ip_address = true
  instance_type               = "t2.micro"
  key_name                    = "${aws_key_pair.extensive_tutorial.key_name}"
  subnet_id                   = "${aws_subnet.extensive_tutorial.id}"

  tags {
    Name      = "kitchen-terraform-reachable-other-host"
    Terraform = "true"
  }
}
```

The `random` provider gives us a range of random value generators, in this case, the `random_string` resource which is used to generate alphanumeric characters with optionally includes special characters where set to `false`.

```
resource "random_string" "key_name" {
  length  = 9
  special = false
}
```

- 02-output.tf

The `output.tf` declares output variables to external interface of Terraform where they are made available to verifiers which can utilise the output values to validate the result via each control.

## Root Module

Terraform driver provides `root_module_directory` to encapsulate test wrapper and leave the core scripts intact.

## Run Test

Running test can be done via `run.sh` where it wraps the necessary command to set up AWS variables and to execute each step of kitchen life-cycle.

> ./run.sh "\<**AWS ACCESS KEY**\>" "\<**AWS SECRET KEY**\>" "\<**AWS REGION**\>"

- AWS ACCESS KEY = your AWS access key
- AWS SECRET KEY = your AWS secret key
- AWS REGION = `ap-southeast-1` or `ap-southeast-2` where the difference is the platform being used in each region, RedHat and Ubuntu respectively.