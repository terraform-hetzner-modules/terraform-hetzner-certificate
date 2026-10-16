module "certificates" {
  source = "../.."
  labels = { environment = "example", managed_by = "terraform" }
  managed = {
    web = {
      name         = null # Use generated names so replacements can coexist.
      domain_names = var.domain_names
      labels       = { purpose = "public" }
      revision     = var.revision
    }
  }
  uploaded = {
    internal = {
      # Change the exact name when replacing this certificate.
      name        = "internal-${var.revision}"
      certificate = var.certificate
      private_key = var.private_key
      labels      = { purpose = "internal" }
      revision    = var.revision
    }
  }
}

resource "hcloud_load_balancer" "example" {
  name               = "certificate-example"
  load_balancer_type = "lb11"
  location           = "fsn1"
}

resource "hcloud_load_balancer_service" "https" {
  load_balancer_id = hcloud_load_balancer.example.id
  protocol         = "https"
  http {
    certificates = [module.certificates.managed_ids.web, module.certificates.uploaded_ids.internal]
  }
}
