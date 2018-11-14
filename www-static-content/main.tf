#----- template for intranet VIPs -----#
provider "bigip" {
  address = "${var.f5_host}"
  username = "${var.f5_user}"
  password = "${var.f5_pass}"
}

resource "bigip_ltm_monitor" "www-static-content" {
  name = "/Common/http_monitor_8080"
  parent = "/Common/http"
  send = "GET /serverstatus.html\r\n"
  timeout = "46"
  interval = "15"
  destination = "*:8080"
}

#node creation
resource "bigip_ltm_node" "intra1" {
  name = "/Common/wwwStatic1"
  address = "10.32.11.64"
}
resource "bigip_ltm_node" "intra2" {
  name = "/Common/wwwStatic2"
  address = "10.32.11.65"
}
resource "bigip_ltm_node" "intra3" {
  name = "/Common/wwwStatic3"
  address = "10.32.11.66"
}

resource "bigip_ltm_pool" "wwwStaticPool" {
  name = "/Common/wwwStaticPool"
  load_balancing_mode = "round-robin"
  monitors = ["/Common/http_monitor_8080"]
  allow_snat = "yes"
  allow_nat = "yes"
}

resource "bigip_ltm_pool_attachment" "wwwStatic1" {
        pool = "/Common/wwwStaticPool"
	node = "/Common/wwwStatic1:8080"
	depends_on = ["bigip_ltm_pool.wwwStaticPool"]
}
resource "bigip_ltm_pool_attachment" "wwwStatic2" {
        pool = "/Common/wwwStaticPool"
	node = "/Common/wwwStatic2:8080"
	depends_on = ["bigip_ltm_pool.wwwStaticPool"]
}
resource "bigip_ltm_pool_attachment" "wwwStatic3" {
        pool = "/Common/wwwStaticPool"
	node = "/Common/wwwStatic3:8080"
	depends_on = ["bigip_ltm_pool.wwwStaticPool"]
}

resource "bigip_ltm_virtual_server" "https" {
  depends_on = ["bigip_ltm_pool.wwwStaticPool"]
  name = "/Common/wwwStatic_https"
  destination = "10.33.8.23"
  port = 443
  pool = "/Common/wwwStaticPool"
  profiles = ["/Common/http"]
  client_profiles = ["/Common/clientssl"]
  source_address_translation = "automap"
  translate_address = "enabled"
  translate_port = "enabled"
}

resource "bigip_ltm_virtual_server" "http" {
  depends_on = ["bigip_ltm_pool.wwwStaticPool"]
  name = "/Common/wwwStatic_http"
  destination = "10.33.8.23"
  port = 80
  pool = "/Common/wwwStaticPool"
  profiles = ["/Common/http"]
  source_address_translation = "automap"
  translate_address = "enabled"
  translate_port = "enabled"
}
