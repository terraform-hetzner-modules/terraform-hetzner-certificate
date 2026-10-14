output "managed" {
  description = "Complete managed certificate attributes indexed by caller keys."
  value       = hcloud_managed_certificate.current
}

output "uploaded" {
  description = "Uploaded certificate metadata without private keys, indexed by caller keys. Sensitive because configuration values may be sensitive."
  sensitive   = true
  value = {
    for key, certificate in hcloud_uploaded_certificate.current : key => {
      id               = certificate.id
      name             = certificate.name
      type             = certificate.type
      certificate      = certificate.certificate
      domain_names     = certificate.domain_names
      fingerprint      = certificate.fingerprint
      created          = certificate.created
      not_valid_before = certificate.not_valid_before
      not_valid_after  = certificate.not_valid_after
      labels           = certificate.labels
    }
  }
}

output "managed_ids" {
  description = "Managed certificate IDs indexed by caller keys, suitable for load balancer services."
  value       = { for key, certificate in hcloud_managed_certificate.current : key => certificate.id }
}

output "uploaded_ids" {
  description = "Uploaded certificate IDs indexed by caller keys, suitable for load balancer services."
  value       = { for key, certificate in hcloud_uploaded_certificate.current : key => certificate.id }
}
