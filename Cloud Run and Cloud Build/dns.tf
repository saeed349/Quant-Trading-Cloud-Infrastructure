data "cloudflare_zones" "smd" {
  filter {
    name   = var.dns_zone_name
  }
}
locals {
    #dash_production_domain = split("/", google_cloud_run_service.dash_analytics_production[0].status[0].url)[2]
    dash_production_domain = "ghs.googlehosted.com"
}

resource "cloudflare_record" "smd-docker" {
  zone_id = data.cloudflare_zones.smd.zones.0.id
  name    = "dash"
  type    = "CNAME"
  value   = local.dash_production_domain
  # proxied   = true # set it to true for firewall protection
}
