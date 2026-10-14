<p align="center">
    <!-- terraform-hetzner-certificate -->
<img src="https://cdn.simpleicons.org/terraform/844FBA" alt="Terraform Logo" align="center" width="128">
<img src="https://avatars.githubusercontent.com/u/30047064?s=200&v=4" alt="Hetzner Logo" align="center" width="128">
    <h1 align="center">Hetzner Cloud</h1>
    <h2 align="center"><code>certificate</code></h2>
</p>

[![License](https://img.shields.io/github/license/terraform-hetzner-modules/terraform-hetzner-certificate?label=License)](https://opensource.org/licenses/MIT)
[![Terraform](https://img.shields.io/badge/Terraform-_>=_1.7-brightgreen?logo=terraform&logoColor=623CE4)][terraform]
[![Opentofu](https://img.shields.io/badge/OpenTofu-_>=_1.8-brightgreen?logo=opentofu)][opentofu]
[![CI Status](https://github.com/terraform-hetzner-modules/terraform-hetzner-certificate/actions/workflows/testing.yaml/badge.svg)](https://github.com/terraform-hetzner-modules/terraform-hetzner-certificate/blob/main/.github/workflows/testing.yaml)
[![GitHub Release](https://img.shields.io/github/v/release/terraform-hetzner-modules/terraform-hetzner-certificate?label=Release)][github_releases]
[![GitHub Activity](https://img.shields.io/github/commit-activity/m/terraform-hetzner-modules/terraform-hetzner-certificate?label=Commits)][github_commits]
[![Renovate](https://img.shields.io/badge/Renovate-enabled-brightgreen?logo=renovate&logoColor=1A1F6C)][renovate]
[![Pre-Commit](https://img.shields.io/badge/PreCommit-enabled-brightgreen?logo=precommit&logoColor=FAB040)][pre-commit]

A [Terraform module][module] to manage collections of managed and uploaded TLS certificates in [Hetzner Cloud][hetzner].

## ✨ TL;DR

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

## Compatibility and examples

Requires Terraform >= 1.7 (OpenTofu >= 1.8 tested) and hcloud ~> 1.70.
See [basic](examples/basic) for uploads and [full](examples/full) for both kinds connected to an HTTPS service.
Supply real PEM values through variables or your secret-management system; configure `HCLOUD_TOKEN` for live use.
The generated [schema report](docs/SCHEMA.md) records provider fields and module mappings.
See the [maintenance guide](docs/UPGRADING.md) for validation and coverage checks.
Run `terraform init -backend=false`, `terraform validate`, and `terraform test` for credential-free tests.
Tests use mock-only placeholder certificate material, never real private keys.

<!-- BEGIN_TF_DOCS -->
## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_hcloud"></a> [hcloud](#provider\_hcloud) | ~> 1.70 |

## Modules

No modules.

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_labels"></a> [labels](#input\_labels) | Shared labels. Per-certificate labels take precedence. | `map(string)` | `{}` | no |
| <a name="input_managed"></a> [managed](#input\_managed) | Managed certificates keyed by stable identifiers. Default names include a digest of the domain set and revision for replacement. Name overrides are exact and require caller-managed uniqueness during replacement. | ```map(object({ name = optional(string) domain_names = set(string) labels = optional(map(string), {}) revision = optional(string, "") }))``` | `{}` | no |
| <a name="input_uploaded"></a> [uploaded](#input\_uploaded) | Uploaded certificates keyed by stable, non-secret identifiers. PEM values may be computed. Private keys are sensitive and stored in state. Default names hash the public certificate and revision; only map keys are declassified for resource addresses. | ```map(object({ name = optional(string) certificate = string private_key = string labels = optional(map(string), {}) revision = optional(string, "") }))``` | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_managed"></a> [managed](#output\_managed) | Complete managed certificate attributes indexed by caller keys. |
| <a name="output_managed_ids"></a> [managed\_ids](#output\_managed\_ids) | Managed certificate IDs indexed by caller keys, suitable for load balancer services. |
| <a name="output_uploaded"></a> [uploaded](#output\_uploaded) | Uploaded certificate metadata without private keys, indexed by caller keys. Sensitive because configuration values may be sensitive. |
| <a name="output_uploaded_ids"></a> [uploaded\_ids](#output\_uploaded\_ids) | Uploaded certificate IDs indexed by caller keys, suitable for load balancer services. |
<!-- END_TF_DOCS -->

### 🔃 Contributing

Refer to our [documentation for contributors][contributing] for contributing guidelines, commit message
formats and versioning tips.

### 📥 Maintainers

This project is owned and maintained by [Terraform Hetzner Modules][org]. Refer to the [`AUTHORS`][authors] or [`CODEOWNERS`][owners]
for more information. You may also use the linked contact details to reach out directly.

### ©️ Copyright

- _Assets provided by:_ **[HashiCorp][hashicorp]**
- _Sources provided by:_ **[Terraform Hetzner Modules][org]** under the **[MIT License][license]**

<!-- INTERNAL REFERENCES -->

<!-- Project references -->

<!-- File references -->

[license]: LICENSE
[contributing]: docs/CONTRIBUTING.md
[authors]: .github/AUTHORS
[owners]: .github/CODEOWNERS

<!-- General links -->

[org]: https://github.com/terraform-hetzner-modules
[terraform]: https://terraform.io
[opentofu]: https://opentofu.org/
[hashicorp]: https://www.hashicorp.com/
[hetzner]: https://hetzner.com
[github_releases]: https://github.com/terraform-hetzner-modules/terraform-hetzner-certificate/releases
[github_commits]: https://github.com/terraform-hetzner-modules/terraform-hetzner-certificate/commits/main/

<!-- Third-party -->

[module]: https://registry.terraform.io/modules/terraform-hetzner-modules/certificate/hetzner/latest
[renovate]: https://renovatebot.com/
[pre-commit]: https://pre-commit.com/
