source "docker" "glaber-server" {
  image  = "debian:bullseye"
  commit = true
  changes = [
    "ENV DEBIAN_FRONTEND noninteractive",
    "ENV LANG en_US.UTF-8",
    "ENV LANGUAGE en_US:en",
    "ENV LC_ALL en_US.UTF-8",
    "ENTRYPOINT [\"/bin/bash\", \"-c\", \"/root/docker-entrypoint.sh\"]"
  ]
}

build {
  name = "Build glaber server mysql"
  sources = [
    "source.docker.glaber-server"
  ]
  provisioner "shell" {
    inline = [
      "apt-get update",
      "apt-get install -y nmap wget gnupg2 lsb-release apt-transport-https locales",
      "wget -qO - https://glaber.io/repo/key/repo.gpg | apt-key add -",
      "echo \"deb [arch=amd64] https://glaber.io/repo/debian $(lsb_release -sc) main\" >> /etc/apt/sources.list.d/glaber.list",
      "apt-get update",
      "apt-get install -y glaber-server-mysql=1:${var.glaber_build_version}*",
      "rm -rf /var/lib/{apt,dpkg,cache,log}/",
      "apt-get autoremove --yes",
      "apt-get clean autoclean",
      "mkdir -p /var/lib/mysql/vcdump/ /run/zabbix",
      "chown zabbix:zabbix /run/zabbix /var/lib/mysql/vcdump/",
      "chmod +s /usr/bin/nmap",
      "chmod +s /usr/sbin/glbmap",
      "sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen",
      "sed -i '/ru_RU.UTF-8/s/^# //g' /etc/locale.gen",
      "locale-gen"
    ]
  }
  provisioner "file" {
    source      = "../../../../glaber-server/etc/zabbix/zabbix_server.conf"
    destination = "/etc/zabbix/zabbix_server.conf"
  }
  provisioner "file" {
    source      = "../../../../glaber-server/docker-entrypoint.sh"
    destination = "/root/docker-entrypoint.sh"
  }
  post-processors {
    post-processor "docker-tag" {
      repository = "${local.glaber_server_repo}"
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



