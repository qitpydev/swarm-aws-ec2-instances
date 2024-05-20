output "master_ip" {
  value = "${aws_instance.master_node.public_ip}"
}

output "ssh_user" {
  value = "swarm"
}

output "ssh_public_key_openssh" {
  value = "${tls_private_key.rsa_key.public_key_openssh}"
  sensitive = true
}

output "ssh_public_key_pem" {
  value = "${tls_private_key.rsa_key.public_key_pem}"
  sensitive = true
}

output "ssh_private_key_openssh" {
  value = "${tls_private_key.rsa_key.private_key_openssh}"
  sensitive = true
}

output "ssh_private_key_pem" {
  value = "${tls_private_key.rsa_key.private_key_pem}"
  sensitive = true
}
