provider "bigip" {
  address = "192.168.2.5"
  username = "terraform"
}

resource "bigip_ltm_monitor" "monitor80" {
  name = "/Common/http_monitor_80"
  parent = "/Common/http"
  send = "GET /status.html\r\n"
  timeout = "46"
  interval = "15"
  destination = "*:80"
}

resource "bigip_ltm_monitor" "monitor8080" {
  name = "/Common/http_monitor_8080"
  parent = "/Common/http"
  send = "GET /status.html\r\n"
  timeout = "46"
  interval = "15"
  destination = "*:8080"
}