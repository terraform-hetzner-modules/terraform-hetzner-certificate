# Hetzner Certificate Terraform module

Manage multiple managed and uploaded TLS certificates with shared labels and replacement-aware naming.

## Usage

Copy this configuration into `main.tf`.

```hcl
module "certificates" {
  source = "terraform-hetzner-modules/certificate/hetzner"

  uploaded = {
    web = {
      certificate = file("${path.module}/fullchain.pem")
      private_key = file("${path.module}/privkey.pem")
    }
  }
}
```

Place your certificate chain in `fullchain.pem` and its matching private key in `privkey.pem` beside
`main.tf`. These files must exist before planning. Keep private keys out of version control.

## Examples

- [Basic](examples/basic): an uploaded certificate.
- [Full](examples/full): both certificate types, every input, and HTTPS service integration.

## Certificate collections

`managed` and `uploaded` are independent maps keyed by stable, non-secret identifiers. Empty maps create
no certificates. Keys must be known during planning; domains, certificate contents, and private keys may
be computed. Shared `labels` apply to both collections, with per-certificate labels taking precedence.
All supported inputs of `hcloud_managed_certificate` and `hcloud_uploaded_certificate` are exposed.
The deprecated `hcloud_certificate` alias is intentionally excluded.

Managed certificates use `domain_names` and are renewed by Hetzner. They require Hetzner DNS or ACME
challenge delegation to a Hetzner DNS zone. Uploaded certificates work with external issuance and renewal.
See [Hetzner's certificate requirements](https://docs.hetzner.com/networking/certificates/faq/).
This module creates no DNS resources.

Use `managed_ids.<key>` and `uploaded_ids.<key>` in load balancer service certificate lists. For example:
`http = { certificates = [module.certificates.uploaded_ids.web] }` in our load balancer module.
The `managed` and `uploaded` outputs expose certificate metadata by caller key. Uploaded metadata stays
sensitive; private keys are deliberately excluded. Private keys still reside in Terraform state because
of the provider's resource schema. Protect state and saved plans.

## Replacement behavior

Both resources use `create_before_destroy`. Default names combine certificate kind, caller key, and a
12-character SHA-256 suffix derived from sorted managed domains or uploaded public certificate content,
plus `revision`. No private key is included in that digest. New domain sets and renewed uploaded
certificates therefore get different names, allowing the old and new resources to coexist while consumers
switch IDs. Connect consumers using module outputs so Terraform can order those updates.

Changing `revision` changes the generated name. Use it together with a forced replacement or a key-only
change that retains the same public certificate, since those replacements cannot be distinguished by
public content alone. A revision change by itself only renames a resource; it does not force reissuance.

An optional `name` is an exact override and disables generated names. When replacing such a certificate,
supply a new unique name yourself. Using the same name with `create_before_destroy` can fail Hetzner's
uniqueness constraint. Replacements of default-named certificates with unchanged material also need a new
revision. Removal of a map entry deletes its certificate; remove it from consumers first.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| terraform | >= 1.7 |
| hcloud | ~> 1.70 |

## Providers

| Name | Version |
| ---- | ------- |
| hcloud | ~> 1.70 |

## Resources

| Name | Type |
| ---- | ---- |
| [hcloud_managed_certificate.current](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/managed_certificate) | resource |
| [hcloud_uploaded_certificate.current](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/uploaded_certificate) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| labels | Shared labels. Per-certificate labels take precedence. | `map(string)` | `{}` | no |
| managed | Managed certificates keyed by stable identifiers. Default names include a digest of the domain set and revision for replacement. Name overrides are exact and require caller-managed uniqueness during replacement. | ```map(object({ name = optional(string) domain_names = set(string) labels = optional(map(string), {}) revision = optional(string, "") }))``` | `{}` | no |
| uploaded | Uploaded certificates keyed by stable, non-secret identifiers. PEM values may be computed. Private keys are sensitive and stored in state. Default names hash the public certificate and revision; only map keys are declassified for resource addresses. | ```map(object({ name = optional(string) certificate = string private_key = string labels = optional(map(string), {}) revision = optional(string, "") }))``` | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| managed | Complete managed certificate attributes indexed by caller keys. |
| managed\_ids | Managed certificate IDs indexed by caller keys, suitable for load balancer services. |
| uploaded | Uploaded certificate metadata without private keys, indexed by caller keys. Sensitive because configuration values may be sensitive. |
| uploaded\_ids | Uploaded certificate IDs indexed by caller keys, suitable for load balancer services. |
<!-- END_TF_DOCS -->

## Contributing

See [CONTRIBUTING.md](docs/CONTRIBUTING.md) for local checks and contribution guidelines, and
[UPGRADING.md](docs/UPGRADING.md) for compatibility and live acceptance checks. The generated
[schema report](docs/SCHEMA.md) documents provider coverage and intentional omissions.

## Authors

Maintained by [Terraform Hetzner Modules](https://github.com/terraform-hetzner-modules).
See [AUTHORS](.github/AUTHORS) and [CODEOWNERS](.github/CODEOWNERS).

## License

MIT. See [LICENSE](LICENSE).
