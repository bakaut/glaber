variable "glaber_build_version" {
  type    = string
  default = "${env("GLABER_BUILD_VERSION")}"
}

variable "registry" {
  type    = string
  default = "docker.pkg.github.com"
}

variable "registry_user" {
  type    = string
  default = "${env("GITHUB_ACTOR")}"
}

variable "registry_email" {
  type    = string
  default = "fifo.mail@gmail.com"
}

variable "registry_password" {
  type    = string
  default = "${env("GITHUB_PASSWORD")}"
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
