# Maintenance and upgrade guide

This module starts with Terraform >= 1.7 and `hetznercloud/hcloud ~> 1.70`.
The test matrix covers Terraform 1.7.5/1.16.6 and OpenTofu 1.8.8/1.13.1.
These are module compatibility tests; older engines are not necessarily in the provider's own supported test matrix.

## Before upgrading

Back up your root configuration's state and commit its dependency lock file. Update the module version,
run `terraform init -upgrade` (or `tofu init -upgrade`), and review the plan before applying it.
Child module lock files do not constrain a consuming root configuration.
Keep caller-supplied map keys stable to retain resource addresses.
Unknown object properties may be discarded by Terraform's object conversion; check input property names.

## Checks

Run `terraform init -backend=false`, `terraform validate`, and `terraform test` (or equivalent `tofu`
commands). Initialize and validate each example and submodule separately. Tests use mock providers;
no cloud credentials are needed and no real infrastructure is created.
Before release, check creation, a second no-change plan, updates, and teardown in a disposable Hetzner
project. Mocks do not verify live API behavior, quotas, or capacity.

## Provider coverage maintenance

Formr generates the [schema report](SCHEMA.md). With the module initialized,
run `formr schema . -o docs/SCHEMA.md` and `formr check . --report docs/SCHEMA.md`.
Use the same engine and provider selections recorded in the report's provenance.
The default policy checks inventory completeness and unresolved analysis. Strict interface coverage
and exception annotations are not yet implemented, so a passing check does not approve omitted fields.
Provider configuration belongs in the consuming root configuration; IDs and other computed attributes
are provider-managed rather than creation inputs.

Regenerate README inputs/outputs with `terraform-docs -c .github/linters/.terraform-docs.yml .`.

## Certificate lifecycle

Preserve caller map keys to retain resource addresses. Default names depend on domains or public
certificate content plus revision. This supports create-before-destroy replacement without adding
another provider. Exact name overrides require unique names when replacing resources.
For forced replacement or private-key-only changes with identical public content, change revision as well.
The module does not generate keys, issue uploaded certificates, or manage DNS.

Private keys are inputs only and are excluded from outputs. Their provider state remains sensitive.
Formr may conservatively mark a private key as exported when tracing the collection through an output
comprehension; the explicit output projection excludes it, and a native test checks that exclusion.
SDK resource IDs are provider-managed rather than creation inputs. The deprecated certificate alias
adds no capabilities and is intentionally omitted.

Live tests should verify issuance, a second no-change plan, certificate/domain rotation while referenced
by a load balancer, consumer updates before old-certificate removal, and final teardown.
Mock tests cannot validate PEM chains, key matching, DNS challenges, or certificate issuance/renewal.
