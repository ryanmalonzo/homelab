##### DNS

locals {
  root_domain = "chaldea.dev"

  internal_subdomains = [
    "argocd",
    "dns",
    "jellyfin",
    "navidrome",
    "profilarr",
    "prowlarr",
    "radarr-anime",
    "radarr-regular",
    "sabnzbd",
    "seerr",
    "sonarr-anime",
    "sonarr-regular",
  ]

  internal_dns_records = [
    for subdomain in local.internal_subdomains : {
      name    = "${subdomain}.internal.${local.root_domain}"
      type    = "A"
      content = var.tailscale_ip
      proxied = false
    }
  ]

  public_services = {
    # pdf = { service = "http://bentopdf.default.svc.cluster.local:80" }
  }

  public_dns_records = [
    for sub, svc in local.public_services : {
      name    = "${sub}.${local.root_domain}"
      type    = "CNAME"
      content = "${cloudflare_zero_trust_tunnel_cloudflared.chaldea.id}.cfargotunnel.com"
      proxied = true
    }
  ]

  dns_records = concat(
    local.internal_dns_records,
    local.public_dns_records,
  )
}

resource "cloudflare_dns_record" "dns_records" {
  for_each = { for rec in local.dns_records : rec.name => rec }

  zone_id = var.cloudflare_zone_id
  name    = each.value.name
  type    = each.value.type
  content = each.value.content
  ttl     = 1
  proxied = each.value.proxied
}

##### Cloudflare Zero Trust

resource "random_bytes" "tunnel_secret" {
  length = 32
}

resource "cloudflare_zero_trust_tunnel_cloudflared" "chaldea" {
  account_id    = var.cloudflare_account_id
  name          = "chaldea"
  config_src    = "cloudflare"
  tunnel_secret = random_bytes.tunnel_secret.base64
}

resource "cloudflare_zero_trust_tunnel_cloudflared_config" "chaldea" {
  account_id = var.cloudflare_account_id
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.chaldea.id
  config = {
    ingress = concat(
      [
        for sub, svc in local.public_services : {
          hostname = "${sub}.${local.root_domain}"
          service  = svc.service
        }
      ],
      [{ service = "http_status:404" }],
    )
  }
}

data "cloudflare_zero_trust_tunnel_cloudflared_token" "chaldea" {
  account_id = var.cloudflare_account_id
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.chaldea.id
}

output "cloudflared_token" {
  value     = data.cloudflare_zero_trust_tunnel_cloudflared_token.chaldea.token
  sensitive = true
}
