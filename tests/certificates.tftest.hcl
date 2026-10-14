mock_provider "hcloud" {
  mock_resource "hcloud_managed_certificate" { defaults = { id = "41", type = "managed", fingerprint = "managed-fingerprint" } }
  mock_resource "hcloud_uploaded_certificate" { defaults = { id = "42", type = "uploaded", fingerprint = "uploaded-fingerprint" } }
}

run "empty_collections" {
  command = apply
  assert {
    condition     = length(output.managed) == 0 && length(output.uploaded) == 0 && length(output.managed_ids) == 0 && length(output.uploaded_ids) == 0
    error_message = "Empty maps must create no certificates."
  }
}

run "multiple_certificates" {
  command = apply
  variables {
    labels = { environment = "shared", managed_by = "terraform" }
    managed = {
      web = { domain_names = ["www.example.com", "example.com"] }
      api = { name = "custom-api", domain_names = ["api.example.com"], labels = { environment = "production" } }
    }
    uploaded = {
      web      = { certificate = "mock-public-certificate-v1", private_key = "mock-only-private-key-v1", labels = { environment = "uploaded" } }
      internal = { name = "custom-internal", certificate = "mock-public-internal", private_key = "mock-only-private-internal" }
    }
  }
  assert {
    condition     = keys(output.managed_ids) == ["api", "web"] && keys(output.uploaded_ids) == ["internal", "web"] && output.managed_ids.web == "41" && output.uploaded_ids.web == "42"
    error_message = "Managed and uploaded collections must have independent caller keys and usable IDs."
  }
  assert {
    condition     = output.managed.web.name == "managed-web-${substr(sha256(jsonencode([["example.com", "www.example.com"], ""])), 0, 12)}" && output.managed.api.name == "custom-api" && output.uploaded.internal.name == "custom-internal"
    error_message = "Default names must incorporate sorted domains, while exact name overrides are preserved."
  }
  assert {
    condition     = output.managed.api.labels.environment == "production" && output.managed.api.labels.managed_by == "terraform" && output.uploaded.web.labels.environment == "uploaded" && output.uploaded.web.labels.managed_by == "terraform"
    error_message = "Per-certificate labels must override shared defaults."
  }
  assert {
    condition     = alltrue([for certificate in values(output.uploaded) : !contains(keys(certificate), "private_key")]) && output.uploaded.web.fingerprint == "uploaded-fingerprint" && output.managed.web.fingerprint == "managed-fingerprint"
    error_message = "Outputs must include metadata without returning private keys."
  }
}

run "rotate_material" {
  command = apply
  variables {
    managed  = { web = { domain_names = ["new.example.com", "example.com"] } }
    uploaded = { web = { certificate = "mock-public-certificate-v2", private_key = "mock-only-private-key-v2" } }
  }
  assert {
    condition     = output.managed.web.name != "managed-web-${substr(sha256(jsonencode([["example.com", "www.example.com"], ""])), 0, 12)}" && output.uploaded.web.name != "uploaded-web-${substr(sha256(jsonencode(["mock-public-certificate-v1", ""])), 0, 12)}" && keys(output.managed_ids) == ["web"] && keys(output.uploaded_ids) == ["web"]
    error_message = "Domain and certificate changes must yield new default names without changing caller keys."
  }
}

run "revision_and_domain_order" {
  command = apply
  variables {
    managed  = { web = { domain_names = ["example.com", "new.example.com"], revision = "reissue-2" } }
    uploaded = { web = { certificate = "mock-public-certificate-v2", private_key = "mock-only-private-key-v2", revision = "reissue-2" } }
  }
  assert {
    condition     = output.managed.web.name == "managed-web-${substr(sha256(jsonencode([["example.com", "new.example.com"], "reissue-2"])), 0, 12)}" && output.uploaded.web.name == "uploaded-web-${substr(sha256(jsonencode(["mock-public-certificate-v2", "reissue-2"])), 0, 12)}"
    error_message = "Revision must distinguish same-content replacements and domain ordering must be deterministic."
  }
}

run "reject_empty_domains" {
  command = plan
  variables { managed = { invalid = { domain_names = [] } } }
  expect_failures = [var.managed]
}

run "reject_empty_upload" {
  command = plan
  variables { uploaded = { invalid = { certificate = " ", private_key = " " } } }
  expect_failures = [var.uploaded]
}
