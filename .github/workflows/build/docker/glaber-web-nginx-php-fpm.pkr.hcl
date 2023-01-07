source "docker" "glaber-web-nginx" {
  image  = "debian:bullseye"
  commit = true
  changes = [
    "ENV DEBIAN_FRONTEND noninteractive",
    "VOLUME /etc/ssl/nginx",
    "WORKDIR /usr/share/zabbix",
    "EXPOSE 80",
    "ENTRYPOINT [\"docker-entrypoint.sh\"]"
  ]
}

build {
  name = "Build glaber web nginx php-fpm"
  sources = [
    "source.docker.glaber-web-nginx"
  ]
  provisioner "shell" {
    inline = [
      "apt-get update",
      "apt-get install -y wget software-properties-common nmap gnupg2 openssl",
      "apt-get install -y ca-certificates supervisor default-mysql-client",
      "apt-get install -y lsb-release apt-transport-https",
      "wget -qO - https://glaber.io/repo/key/repo.gpg | apt-key add -",
      "wget -qO - https://nginx.org/keys/nginx_signing.key | apt-key add -",
      "echo \"deb [arch=amd64] https://glaber.io/repo/debian $(lsb_release -sc) main\" >> /etc/apt/sources.list.d/glaber.list",
      "apt-get update",
      "apt-get install -y glaber-nginx-conf=1:${var.glaber_build_version}*",
      "rm -rf /var/lib/{apt,dpkg,cache,log}",
      "apt-get autoremove --yes",
      "apt-get clean autoclean"
    ]
  }
  provisioner "file" {
    source      = "../../../../glaber-nginx/etc/"
    destination = "/etc/"
  }
  provisioner "shell" {
    inline = [
      "mkdir /run/php && chown www-data:www-data /run/php",
      "chown www-data:www-data /etc/zabbix/web/zabbix.conf.php",
      "mv /etc/docker-entrypoint.sh /usr/bin",
      "sed -i \"s/#        listen          80;/    listen          80;/g\" /etc/nginx/conf.d/zabbix.conf",
      "sed -i \"s/#        server_name     example.com;/    server_name     _;/g\" /etc/nginx/conf.d/zabbix.conf"
    ]
  }
  post-processors {
    post-processor "docker-tag" {
      repository = "${local.glaber_web_repo}"
      tags       = ["${var.glaber_build_version}-pkr", "latest-pkr"]
    }
    post-processor "docker-push" {
      login          = true
      login_server   = "${var.registry}"
      login_username = "${var.registry_user}"
      login_password = "${var.registry_password}"
    }
  }
}



