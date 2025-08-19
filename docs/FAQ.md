# Frequently Asked Questions

<!-- mdformat-toc start --slug=github --no-anchors --maxlevel=6 --minlevel=2 -->

- [Versioning](#versioning)

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

[semantic versioning]: https://semver.org/
