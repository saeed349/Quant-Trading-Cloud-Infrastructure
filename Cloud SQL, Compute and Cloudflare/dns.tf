data "cloudflare_zones" "smd" {
  filter {
    name   = var.dns_zone_name
  }
}

resource "cloudflare_filter" "smd-only-allow-ip-address" {
  zone_id = data.cloudflare_zones.smd.zones.0.id
  description = "Only allow access from this specific ip address"
  expression = "(ip.src ne ${var.cloudflare_allowed_ip_address})"
}
resource "cloudflare_firewall_rule" "smd-only-allow-ip-address" {
  zone_id = data.cloudflare_zones.smd.zones.0.id
  description = "Only allow access from this specific ip address"
  filter_id = cloudflare_filter.smd-only-allow-ip-address.id
  action = "block"
}


resource "cloudflare_record" "smd-db" {
  zone_id = data.cloudflare_zones.smd.zones.0.id
  name    = "db"
  type    = "A"
  value   = google_sql_database_instance.smd-production.first_ip_address
}

resource "cloudflare_record" "smd-docker" {
  zone_id = data.cloudflare_zones.smd.zones.0.id
  name    = "docker"
  type    = "A"
  value   = google_compute_address.smd-docker.address
  proxied = true
}

resource "cloudflare_record" "ats" {
  zone_id = data.cloudflare_zones.smd.zones.0.id
  name    = "ats"
  type    = "CNAME"
  value   = cloudflare_record.smd-docker.hostname
  proxied = true
}
