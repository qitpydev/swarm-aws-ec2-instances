output "master_ip" {
  value = "${module.docker_swarm.master_ip}"
}

output "ssh_user" {
  value = "${module.docker_swarm.ssh_user}"
}

output "ssh_public_key_openssh" {
  value = "${module.docker_swarm.ssh_public_key_openssh}"
  sensitive = true
}

output "ssh_public_key_pem" {
  value = "${module.docker_swarm.ssh_public_key_pem}"
  sensitive = true
}

output "ssh_private_key_openssh" {
  value = "${module.docker_swarm.ssh_private_key_openssh}"
  sensitive = true
}

output "ssh_private_key_pem" {
  value = "${module.docker_swarm.ssh_private_key_pem}"
  sensitive = true
}

output "ssh_ip" {
  value = "${module.docker_swarm.ssh_ip}"
}