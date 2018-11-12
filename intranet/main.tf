#----- template for intranet VIPs -----#
provider "bigip" {
  address = "${var.f5_host}"
  username = "${var.f5_user}"
  password = "${var.f5_pass}"
}

resource "bigip_ltm_monitor" "intranet" {
  name = "/Common/http_monitor_80"
  parent = "/Common/http"
  send = "GET /status.html\r\n"
  timeout = "46"
  interval = "15"
  destination = "*:80"
}

#node creation
resource "bigip_ltm_node" "intra1" {
  name = "/Common/intra1"
  address = "10.32.10.64"
}
resource "bigip_ltm_node" "intra2" {
  name = "/Common/intra2"
  address = "10.32.10.65"
}
resource "bigip_ltm_node" "intra3" {
  name = "/Common/intra3"
  address = "10.32.10.66"
}

resource "bigip_ltm_pool" "intraPool" {
  name = "/Common/intraPool"
  load_balancing_mode = "round-robin"
  nodes: ["intra1:80","intra2:80","intra3:80"]
  monitors = ["/Common/http_monitor_80"]
  allow_snat = "yes"
  allow_nat = "yes"
}

resource "bigip_ltm_virtual_server" "https" {
  name = "/Common/intranet_https"
  destination = "10.33.7.23"
  port = 443
  pool = "/Common/intraPool"
  profiles = ["/Common/tcp","/Common/inranetSSL","/Common/http"]
  source_address_translation = "automap"
  translate_address = "enabled"
  translate_port = "enabled"
}

resource "bigip_ltm_virtual_server" "http" {
  name = "/Common/intranet_http"
  destination = "10.33.7.23"
  port = 80
  pool = "/Common/intraPool"
  profiles = ["/Common/tcp","/Common/http"]
  source_address_translation = "automap"
  translate_address = "enabled"
  translate_port = "enabled"
}
