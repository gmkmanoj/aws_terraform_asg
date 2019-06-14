output "ELB DNS Name" {
  value = "${aws_lb.gogoelb.dns_name}"
}
