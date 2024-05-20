resource "aws_eip" "swarm_eip" {
  instance = aws_instance.master_node.id
  domain   = "vpc"
}