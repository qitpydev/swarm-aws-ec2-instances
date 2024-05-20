resource "aws_instance" "master_node" {
  ami           = var.node_ami
  instance_type = var.node_instance_type
  subnet_id = module.swarm_vpc.public_subnets[0]
  vpc_security_group_ids = [aws_security_group.swarm_default_sg.id]
  key_name = aws_key_pair.swarm_keypair.key_name

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

  tags = merge(var.tags, {
    Name = "${var.app_name}-swarm-master"
  })
}

resource "aws_instance" "slave_node" {
  count         = "${var.worker_instance_number}"
  ami           = var.node_ami
  instance_type = var.node_instance_type
  subnet_id = module.swarm_vpc.public_subnets[0]
  vpc_security_group_ids = [aws_security_group.swarm_default_sg.id]
  key_name = aws_key_pair.swarm_keypair.key_name
  associate_public_ip_address = true

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
              echo "${tls_private_key.rsa_key.private_key_openssh}" > swarm_keypair.pem
              sudo chmod 600 swarm_keypair.pem
              sudo scp -o StrictHostKeyChecking=no -i swarm_keypair.pem swarm@${aws_instance.master_node.private_ip}:/home/swarm/join_token .
              docker swarm join --token $(cat join_token) ${aws_instance.master_node.private_ip}:2377
              EOF
  depends_on = [ aws_instance.master_node ]

  tags = merge(var.tags, {
    Name = "${var.app_name}-swarm-worker-${count.index}"
  })
}