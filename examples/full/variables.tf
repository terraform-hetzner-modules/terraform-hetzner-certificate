variable "domain_names" {
  description = "Domains with Hetzner DNS or ACME challenge delegation configured."
  type        = set(string)
}

variable "certificate" {
  description = "PEM certificate chain for the uploaded certificate."
  type        = string
}

variable "private_key" {
  description = "Matching PEM private key."
  type        = string
  sensitive   = true
}

variable "revision" {
  description = "Change with a forced or key-only replacement that retains the same certificate."
  type        = string
  default     = ""
}
