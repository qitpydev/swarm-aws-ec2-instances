resource "aws_instance" "master" {
  ami           = var.node_ami
  instance_type = var.node_instance_type
  vpc_security_group_ids = ["${module.swarm_vpc.vpc_default_sg_id}"]
  key_name = aws_key_pair.swarm_keypair.key_name

  instance_market_options {
    market_type = "spot"
  }

  user_data = <<-EOF
              #!/bin/bash
              sudo adduser swarm
              sudo usermod -aG sudo swarm
              sudo echo "swarm ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/swarm
              sudo mkdir /home/swarm/.ssh
              sudo echo "${tls_private_key.rsa_key.public_key_openssh}" > /home/swarm/.ssh/authorized_keys
              sudo chown swarm:swarm /home/swarm/.ssh -R
              sudo chmod 700 /home/swarm/.ssh
              sudo chmod 600 /home/swarm/.ssh/authorized_keys
              sudo systemctl restart sshd

              sudo -u swarm -i
              sudo apt update
              sudo apt install apt-transport-https ca-certificates curl gnupg-agent software-properties-common -y
              curl -fsSL https://get.docker.com -o get-docker.sh
              sudo sh get-docker.sh
              sudo groupadd docker
              sudo usermod -aG docker swarm
              sudo newgrp docker
              sudo chown swarm:swarm /home/swarm/.docker -R
              sudo chmod g+rwx "$HOME/.docker" -R

              docker swarm init
              docker swarm join-token --quiet worker > /home/swarm/join_token
              EOF

  tags = var.tags
}

resource "aws_instance" "slave" {
  count         = "${var.worker_instance_number}"
  ami           = var.node_ami
  instance_type = var.node_instance_type
  vpc_security_group_ids = [aws_security_group.swarm_default_sg.id]
  key_name = aws_key_pair.swarm_keypair.key_name

  instance_market_options {
    market_type = "spot"
  }

  user_data = <<-EOF
              sudo adduser swarm
              sudo usermod -aG sudo swarm
              sudo echo "swarm ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/swarm
              sudo mkdir /home/swarm/.ssh
              sudo echo "${tls_private_key.rsa_key.public_key_openssh}" > /home/swarm/.ssh/authorized_keys
              sudo chown swarm:swarm /home/swarm/.ssh -R
              sudo chmod 700 /home/swarm/.ssh
              sudo chmod 600 /home/swarm/.ssh/authorized_keys
              sudo systemctl restart sshd
              sudo -u swarm -i
              sudo apt update
              sudo apt install apt-transport-https ca-certificates curl gnupg-agent software-properties-common -y
              curl -fsSL https://get.docker.com -o get-docker.sh
              sudo sh get-docker.sh
              sudo groupadd docker
              sudo usermod -aG docker swarm
              sudo newgrp docker
              sudo chown swarm:swarm /home/swarm/.docker -R
              sudo chmod g+rwx "$HOME/.docker" -R
              sudo apt update
              echo "${tls_private_key.rsa_key.private_key_pem}" > swarm_keypair.pem
              sudo scp -o StrictHostKeyChecking=no -o NoHostAuthenticationForLocalhost=yes -o UserKnownHostsFile=/dev/null -i swarm_keypair.pem swarm@${aws_instance.master.private_ip}:/home/swarm/join_token .
              docker swarm join --token $(cat /home/swarm/join_token) ${aws_instance.master.private_ip}:2377
              EOF

  depends_on = [ aws_instance.master ]

  tags = var.tags
}