resource "aws_eip" "swarm_eip" {
  instance = aws_instance.master.id
  domain   = "vpc"
}