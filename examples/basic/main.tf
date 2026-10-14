module "certificates" {
  source = "../.."
  uploaded = {
    web = { certificate = var.certificate, private_key = var.private_key }
  }
}
