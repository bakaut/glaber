source "docker" "glaber-server" {
  image  = "debian:bullseye"
  commit = true
  changes = [
    "ENV DEBIAN_FRONTEND noninteractive",
    "CMD /root/docker-entrypoint.sh",
    "ENTRYPOINT /bin/bash"
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
      "apt-get install -y nmap wget gnupg2 lsb-release apt-transport-https",
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
      "chmod +s /usr/sbin/glbmap"
    ]
  }
  provisioner "file" {
  source = "../../../../glaber-server/etc/zabbix/zabbix_server.conf"
  destination = "/etc/zabbix/zabbix_server.conf"
  }
  provisioner "file" {
  source = "../../../../glaber-server/docker-entrypoint.sh"
  destination = "/root/docker-entrypoint.sh"
  }
  post-processors {
    post-processor "docker-tag" {
      repository =  "${var.registry}/${var.github_repository}/${var.glaber_server_name}" 
      tags = ["${var.glaber_build_version}-pkr"]
    }
    post-processor "docker-push" {
      login_server = "${var.registry}"
      login_username = "${var.registry_user}"
      login_password = "${var.registry_password}"
      login_email = "${var.registry_email}"
    }
  }
  post-processors {
    post-processor "docker-tag" {
      repository =  "${var.registry}/${var.github_repository}/${var.glaber_server_name}"
      tags = ["latest-pkr"]
    }
    post-processor "docker-push" {
        login_server = "${var.registry}"
        login_username = "${var.registry_user}"
        login_password = "${var.registry_password}"
        login_email = "${var.registry_email}"
    }
  }
}



