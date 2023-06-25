terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
}

provider "yandex" {
  token     = "${var.token_ya}"
  cloud_id  = "${var.cloud_id_ya}"
  folder_id = "${var.folder_id_ya}"
}

resource "yandex_mdb_postgresql_cluster" "foo" {
  name        = "ha_mdb_postgresql_cluster_netology"
  environment = "PRODUCTION"
  network_id  = yandex_vpc_network.foo.id

  config {
    version = 14
    resources {
      resource_preset_id = "s2.micro"
      disk_type_id       = "network-ssd"
      disk_size          = 10
    }
  }

  host {
    assign_public_ip = true
	zone             = "ru-central1-a"
    subnet_id        = yandex_vpc_subnet.foo.id
  }

  host {
    assign_public_ip = true
	zone             = "ru-central1-b"
    subnet_id        = yandex_vpc_subnet.bar.id
  }
}

resource "yandex_mdb_postgresql_database" "db1" {
  cluster_id = yandex_mdb_postgresql_cluster.foo.id
  name       = "db1"
  owner      = "mashkov"
  depends_on = [
    yandex_mdb_postgresql_user.mashkov
  ]
}

resource "yandex_mdb_postgresql_user" "user1" {
  cluster_id = yandex_mdb_postgresql_cluster.foo.id
  name       = "mashkov"
  password   = "${var.pass_userdb_mashkov}"
}

resource "yandex_vpc_network" "foo" {}

resource "yandex_vpc_subnet" "foo" {
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.foo.id
  v4_cidr_blocks = ["10.1.0.0/24"]
}

resource "yandex_vpc_subnet" "bar" {
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.foo.id
  v4_cidr_blocks = ["10.2.0.0/24"]
}