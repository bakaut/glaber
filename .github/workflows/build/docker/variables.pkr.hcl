variable "glaber_build_version" {
  type    = string
  default = "${env("GLABER_BUILD_VERSION")}"
}

variable "registry" {
  type    = string
  default = "${env("REGISTRY")}"
}

variable "short_sha" {
  type    = string
  default = "${env("SHORT_SHA")}"
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

locals {
  glaber_server_repo = "${var.registry}/${var.github_repository}/${var.glaber_server_name}"
  glaber_web_repo    = "${var.registry}/${var.github_repository}/${var.glaber_web_name}"
  tmp_tag            = "${var.glaber_build_version}-pkr-${var.short_sha}"
}
