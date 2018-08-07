output "instance_ids" {
    value = ["${aws_instance.airflow-web.*.public_ip}"]
}

output "elb_dns_name" {
  value = "${aws_elb.airflow-elb.dns_name}"
}
