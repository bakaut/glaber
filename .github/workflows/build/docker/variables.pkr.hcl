variable "GLABER_VERSION" {
  type    = string
  default = "${env("GLABER_VERSION")}"
}

variable "registry" {
  type    = string
  default = "${env("REGISTRY")}"
}

variable "registry_user" {
  type    = string
  default = "${env("GITHUB_ACTOR")}"
}

variable "registry_password" {
  type      = string
  default   = "${env("DOCKER_PASSWORD")}"
  sensitive = true
}

variable "github_repository" {
  type    = string
  default = "${env("GITHUB_REPOSITORY")}"
}

variable "glaber_server_name" {
  type    = string
  default = "glaber-server"
}

variable "glaber_web_name" {
  type    = string
  default = "glaber-nginx"
}

variable "tag_version" {
  type    = string
  default = "-pkr"
}

locals {
  glaber_server_repo = "${var.registry}/${var.github_repository}/${var.glaber_server_name}"
  glaber_web_repo    = "${var.registry}/${var.github_repository}/${var.glaber_web_name}"
  tag                = "${var.GLABER_VERSION}${var.tag_version}"
}
