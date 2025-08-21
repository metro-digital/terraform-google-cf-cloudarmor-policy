# Frequently Asked Questions

<!-- mdformat-toc start --slug=github --no-anchors --maxlevel=6 --minlevel=2 -->

- [Versioning](#versioning)
- [Resources](#resources)

<!-- mdformat-toc end -->

## Versioning

The module implements [Semantic Versioning], meaning non-breaking features may
be added within a minor release. Breaking changes will always be introduced in a
new major version.

> [!TIP]
> We clearly recommend to limit potential automatic updates of the module to the
> current major version you are using.

Assuming you are using the `v1` major version, you should limit the version like
this:

```hcl
module "cloudarmor_policy" {
  source  = "metro-digital/cf-cloudarmor-policy/google"
  version = "~> 1.0"
  # ...
}
```

Assuming a new, non-breaking feature was added in `v1.1.0` which you want to
use, your constraint should like this:

```hcl
module "cloudarmor_policy" {
  source  = "metro-digital/cf-cloudarmor-policy/google"
  version = "~> 1.1"
  # ...
}
```

## Resources

**Q:** In my project there is already a policy, how can I import it?

**A:** Please have a look at [Terraform documentation].

1. Find the correct address of your resource

   ```bash
   gcloud compute security-policies describe <policy> --project="<project>" | grep selfLink

   selfLink: https://www.googleapis.com/compute/v1/projects/<project>/global/securityPolicies/<policy>
   ```

   The address is the
   `compute/v1/projects/<project>/global/securityPolicies/<policy>` part

1. If `<policy>` is not the module default `metro-baseline`, make sure to update
   the `name` variable, for example in `terraform.tfvars` file:

   ```hcl
   name = "my-policy"
   ```

1. Import the resource in Terraform state:

   ```bash
   terraform import module.cloudarmor_policy.module.cloud_armor_policy.google_compute_security_policy.policy compute/v1/projects/<project>/global/securityPolicies/<policy>
   ```

[semantic versioning]: https://semver.org/
[terraform documentation]: https://developer.hashicorp.com/terraform/cli/commands/import
