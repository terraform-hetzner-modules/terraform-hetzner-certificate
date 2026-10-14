mock_provider "hcloud" {
  mock_resource "hcloud_managed_certificate" { defaults = { id = "41", type = "managed", fingerprint = "managed-fingerprint" } }
  mock_resource "hcloud_uploaded_certificate" { defaults = { id = "42", type = "uploaded", fingerprint = "uploaded-fingerprint" } }
}

run "computed_values_are_plannable" {
  command = plan
  module { source = "./tests/setup" }
  assert {
    condition     = output.managed_keys == ["web"] && output.uploaded_keys == ["web"]
    error_message = "Computed domains and private keys must not determine resource addresses."
  }
}
