data "aws_availability_zones" "all" {}

# terraform state file setup
# create an S3 bucket to store the state file in
resource "aws_s3_bucket" "terraform-state-storage-s3" {
    bucket = "terraform-remote-state-storage-s3"

    versioning {
      enabled = true
    }

    lifecycle {
      prevent_destroy = true
    }

    tags {
      Name = "S3 Remote Terraform State Store"
    }
}

### Creating EC2 instance
resource "aws_instance" "airflow-web" {
  ami               = "${lookup(var.amis,var.region)}"
  count             = "${var.count}"
  key_name               = "${var.key_name}"
  vpc_security_group_ids = ["${aws_security_group.instance.id}"]
  source_dest_check = false
  instance_type = "t2.micro"

tags {
    Name = "${format("web-%03d", count.index + 1)}"
  }
}

### Creating Security Group for EC2
resource "aws_security_group" "instance" {
  name = "airflow-web-instance"
  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

## Creating Launch Configuration
resource "aws_launch_configuration" "airflow-web" {
  image_id               = "${lookup(var.amis,var.region)}"
  instance_type          = "t2.micro"
  security_groups        = ["${aws_security_group.instance.id}"]
  key_name               = "${var.key_name}"
  provisioner "local-exec" {
    command = "sleep 120; ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u ubuntu --private-key ./deployer.pem -i '${aws_instance.airflow-web.public_ip},' scripts/ci/ansible/roles/docker"
  }
  lifecycle {
    create_before_destroy = true
  }
}

## Creating AutoScaling Group
resource "aws_autoscaling_group" "example" {
  launch_configuration = "${aws_launch_configuration.airflow-web.id}"
  availability_zones = ["${data.aws_availability_zones.all.names}"]
  min_size = 1
  max_size = 10
  load_balancers = ["${aws_elb.airflow-elb.name}"]
  health_check_type = "ELB"
  tag {
    key = "Name"
    value = "airflow-asg-example"
    propagate_at_launch = true
  }
}

## Security Group for ELB
resource "aws_security_group" "elb" {
  name = "airflow-example-elb"
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

### Creating ELB
resource "aws_elb" "airflow-elb" {
  name = "airflow-asg-example"
  security_groups = ["${aws_security_group.elb.id}"]
  availability_zones = ["${data.aws_availability_zones.all.names}"]
  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    interval = 30
    target = "HTTP:8080/"
  }
  listener {
    lb_port = 80
    lb_protocol = "http"
    instance_port = "8080"
    instance_protocol = "http"
  }
}
