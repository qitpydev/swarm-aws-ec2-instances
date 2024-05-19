# RSA key of size 4096 bits
resource "tls_private_key" "rsa_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "swarm_keypair" {
  key_name = "${var.app_name}-deployer-key"
  public_key = tls_private_key.rsa_key.public_key_openssh
}