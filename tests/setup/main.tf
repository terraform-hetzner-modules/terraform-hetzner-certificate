terraform {
  required_version = ">= 1.7"
  required_providers {
    hcloud = { source = "hetznercloud/hcloud", version = "~> 1.70" }
  }
}

resource "terraform_data" "material" {
  input = { certificate = "mock-computed-certificate", private_key = "mock-only-computed-key", domain = "example.com" }
}

module "subject" {
  source  = "../.."
  managed = { web = { domain_names = [terraform_data.material.output.domain] } }
  uploaded = {
    web = {
      certificate = terraform_data.material.output.certificate
      private_key = sensitive(terraform_data.material.output.private_key)
    }
  }
}

output "managed_keys" {
  description = "Managed addresses remain known with computed domains."
  value       = keys(module.subject.managed_ids)
}

output "uploaded_keys" {
  description = "Uploaded addresses remain known with computed sensitive material."
  value       = keys(module.subject.uploaded_ids)
}
