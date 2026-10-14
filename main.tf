resource "hcloud_managed_certificate" "current" {
  for_each = var.managed

  name         = coalesce(each.value.name, "managed-${each.key}-${substr(sha256(jsonencode([sort(tolist(each.value.domain_names)), each.value.revision])), 0, 12)}")
  domain_names = each.value.domain_names
  labels       = merge(var.labels, each.value.labels)

  lifecycle {
    create_before_destroy = true
  }
}

resource "hcloud_uploaded_certificate" "current" {
  # Only map keys become public resource addresses; all values stay sensitive.
  for_each = nonsensitive(toset(keys(var.uploaded)))

  name        = coalesce(var.uploaded[each.key].name, "uploaded-${each.key}-${substr(sha256(jsonencode([trimspace(var.uploaded[each.key].certificate), var.uploaded[each.key].revision])), 0, 12)}")
  certificate = var.uploaded[each.key].certificate
  private_key = var.uploaded[each.key].private_key
  labels      = merge(var.labels, var.uploaded[each.key].labels)

  lifecycle {
    create_before_destroy = true
  }
}
