# Full certificate example

Provide `domain_names` backed by Hetzner DNS or delegated ACME challenges, a real PEM certificate
chain in `certificate`, and its matching sensitive `private_key`. The example connects both kinds of
certificate to an HTTPS Load Balancer service.

The managed certificate uses an automatically generated name (`name = null`); the uploaded certificate
shows an exact name derived from `revision`. Change the revision when replacing the exact-named
certificate so old and new certificates can coexist. Changing revision alone does not force reissuance.

## Running the example

Export `HCLOUD_TOKEN`, supply the inputs described in `variables.tf`, then run:

```shell
terraform init
terraform plan
terraform apply
```

This creates real infrastructure. Review the plan and any deletion protection before cleanup.
See the [module README](../../README.md) for usage and input descriptions.
