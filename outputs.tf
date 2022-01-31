output "consul-servers-public-ip" {
  value = formatlist("%v", aws_instance.consul-servers.*.public_ip)
}

output "consul-clients-public-ip" {
  value = formatlist("%v", aws_instance.consul-clients.*.public_ip)
}