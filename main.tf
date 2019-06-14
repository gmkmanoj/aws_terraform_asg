provider "aws" {
  region        = "${var.region}"
  access_key    ="${var.access_key}"
  secret_key    ="${var.secret_key}"
}

resource "aws_key_pair" "gogoec2" {
  key_name      = "gogoec2"
  public_key    = "${file(var.public_key)}"
}

resource "aws_instance" "gogoec2" {
  connection {
    user        = "${var.aws_default_user}"
    private_key = "${file(var.private_key)}"
  }
  ami           = "ami-0eacc5b7915ba9921"
  instance_type = "${var.instancetype}"
  key_name      = "gogoec2"
  instance_initiated_shutdown_behavior = "terminate"
  tags {
    Name        = "gogoBase"
    ENV         = "${var.environment_tag}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum -y install epel-release",
      "sudo yum -y install nginx",
      "sudo yum -y install git",
      "sudo yum -y install gcc-c++ make",
      "sudo curl -sL https://rpm.nodesource.com/setup_11.x | sudo -E bash -",
      "sudo yum -y install nodejs",
      "sudo yum -y install python-setuptools",
      "sudo easy_install supervisor",
    ]
  }
  provisioner "file" {
    source      = "./scripts"
    destination = "/tmp/"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/scripts/*.sh",
      "sudo /tmp/scripts/nginx_conf.sh",
      "sudo /tmp/scripts/startnodejs.sh",
      "sudo service nginx start",
    ]
  }
}

resource "aws_ami_from_instance" "gogouiami" {
  name               = "gogouiami"
  source_instance_id = "${aws_instance.gogoec2.id}"
  tags {
    ENV         = "${var.environment_tag}"
  }
}

resource "aws_launch_template" "gogolt" {
  name_prefix   = "gogolt"
  image_id      = "${aws_ami_from_instance.gogouiami.id}"
  instance_type = "${var.instancetype}"
  key_name      = "gogoec2"
  tags {
    Name        = "gogoUI"
    ENV         = "${var.environment_tag}"
  }
}

resource "aws_placement_group" "gogoplacement" {
  name          = "gogoplacement"
  strategy      = "spread"
}

resource "aws_autoscaling_group" "gogoasg" {
  name                      = "gogo-ASG"
  max_size                  = 2
  min_size                  = 1
  health_check_grace_period = 300
  health_check_type         = "ELB"
  placement_group           = "${aws_placement_group.gogoplacement.id}"
  availability_zones        = ["${aws_instance.gogoec2.availability_zone}"]
  target_group_arns         = ["${aws_lb_target_group.gogotargetgroup.arn}"]

  launch_template {
    id          = "${aws_launch_template.gogolt.id}"
    version     = "$Default"
  }
}

resource "aws_lb_target_group" "gogotargetgroup" {
  name          = "gogotargetgroup"
  port          = "80"
  protocol      = "HTTP"
  vpc_id        = "${aws_default_vpc.default.id}"
  target_type   = "instance"
  tags {
    name        = "gogoUItarget"
    ENV         = "${var.environment_tag}"
  }
  health_check {
    healthy_threshold   = 3
    unhealthy_threshold = 10
    timeout             = 5
    interval            = 10
    path                = "/"
    port                = "80"
  }
}

resource "aws_default_vpc" "default" {
  tags  {
    Name        = "Default VPC"
  }
}

resource "aws_default_subnet" "defaultsubnet1" {
  availability_zone = "${var.availability_zone1}"
  tags  {
    Name        = "Default subnet1"
  }
}

resource "aws_default_subnet" "defaultsubnet2" {
  availability_zone = "${var.availability_zone2}"
  tags  {
    Name        = "Default subnet2"
  }
}

resource "aws_lb" "gogoelb" {
  name               = "gogoelb"
  subnets            = ["${aws_default_subnet.defaultsubnet1.id}","${aws_default_subnet.defaultsubnet2.id}"]
  internal           = false
  load_balancer_type = "application"
 # security_groups    = ["${aws_security_group.CF2TF-SG-Web.id}"]

  tags {
    Name        = "UIWeb-FrontEnd"
    ENV         = "${var.environment_tag}"
  }
}

resource "aws_lb_listener" "gogolistener" {
  load_balancer_arn = "${aws_lb.gogoelb.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn    = "${aws_lb_target_group.gogotargetgroup.arn}"
    type                = "forward"
  }
}

resource "null_resource" "postexecution" {
  depends_on    = ["aws_ami_from_instance.gogouiami"]
  connection {
    host        = "${aws_instance.gogoec2.public_ip}"
    user        = "${var.aws_default_user}"
    private_key = "${file(var.private_key)}"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo init 0"
    ]
  }
}
