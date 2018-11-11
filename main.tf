provider "bigip" {
  address = "192.168.2.5"
  username = "terraform"
}

resource "bigip_ltm_monitor" "monitor" {
  name = "/Common/http_monitor"
  parent = "/Common/http"
  send = "GET /status.html\r\n"
  timeout = "46"
  interval = "15"
  destination = "*:80"
}
