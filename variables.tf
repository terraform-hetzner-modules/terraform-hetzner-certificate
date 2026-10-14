variable "managed" {
  description = "Managed certificates keyed by stable identifiers. Default names include a digest of the domain set and revision for replacement. Name overrides are exact and require caller-managed uniqueness during replacement."
  type = map(object({
    name         = optional(string)
    domain_names = set(string)
    labels       = optional(map(string), {})
    revision     = optional(string, "")
  }))
  default  = {}
  nullable = false

  validation {
    condition     = alltrue([for certificate in values(var.managed) : try(length(certificate.domain_names) > 0, false)])
    error_message = "Managed certificates require at least one domain name."
  }
}

variable "uploaded" {
  description = "Uploaded certificates keyed by stable, non-secret identifiers. PEM values may be computed. Private keys are sensitive and stored in state. Default names hash the public certificate and revision; only map keys are declassified for resource addresses."
  type = map(object({
    name        = optional(string)
    certificate = string
    private_key = string
    labels      = optional(map(string), {})
    revision    = optional(string, "")
  }))
  default   = {}
  nullable  = false
  sensitive = true

  validation {
    condition     = alltrue([for certificate in values(var.uploaded) : try(length(trimspace(certificate.certificate)) > 0 && length(trimspace(certificate.private_key)) > 0, false)])
    error_message = "Uploaded certificates require non-empty certificate and private_key PEM values."
  }
}

variable "labels" {
  description = "Shared labels. Per-certificate labels take precedence."
  type        = map(string)
  default     = {}
  nullable    = false
}
