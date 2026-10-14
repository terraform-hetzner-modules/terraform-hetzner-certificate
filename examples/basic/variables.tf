variable "certificate" {
  description = "PEM certificate chain, including the leaf certificate first."
  type        = string
}

variable "private_key" {
  description = "PEM private key matching the certificate."
  type        = string
  sensitive   = true
}
