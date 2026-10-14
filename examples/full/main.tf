module "certificates" {
  source = "../.."
  labels = { environment = "example", managed_by = "terraform" }
  managed = {
    web = { domain_names = var.domain_names, labels = { purpose = "public" } }
  }
  uploaded = {
    internal = { certificate = var.certificate, private_key = var.private_key, revision = var.revision }
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
