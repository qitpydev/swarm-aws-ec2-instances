module "docker_swarm" {
  source = "../../modules/docker-swarm"

  app_name = "${var.app_name}-${local.environment}"
  region = local.region

  tags = local.tags
}