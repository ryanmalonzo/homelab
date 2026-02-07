locals {
  root_domain = "chaldea.dev"
  cname_subdomains = [
    "pangolin",
    "jellyfin",
    "vaultwarden",
    "jellyseerr",
    "papra",
    "pdf"
  ]

  internal_subdomains = [
    "sonarr",
    "prowlarr",
    "sabnzbd",
    "profilarr",
    "radarr"
  ]

  internal_dns_records = [
    for sub in local.internal_subdomains : {
      name    = "${sub}.internal.${local.root_domain}"
      type    = "A"
      content = var.tailscale_ip
    }
  ]

  dns_records = concat(
    [
      {
        name    = local.root_domain
        type    = "A"
        content = var.pangolin_ip
      }
    ],
    [
      for sub in local.cname_subdomains : {
        name    = "${sub}.${local.root_domain}"
        type    = "CNAME"
        content = local.root_domain
      }
    ],
    local.internal_dns_records
  )
}

resource "cloudflare_dns_record" "dns_records" {
  for_each = { for rec in local.dns_records : rec.name => rec }

  zone_id = var.cloudflare_zone_id
  name    = each.value.name
  type    = each.value.type
  content = each.value.content
  ttl     = 1
  proxied = false
}

