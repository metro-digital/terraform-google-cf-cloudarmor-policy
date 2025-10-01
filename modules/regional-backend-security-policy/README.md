# Cloud Foundation Cloud Armor Regional Policy Module

[FAQ] | [CONTRIBUTING] | [CHANGELOG]

Similar to the [global policy module][root-module], this submodule is an
opinionated wrapper around the
[`GoogleCloudPlatform/cloud-armor` module][upstream-module] provided by Google.
It allows you to create a regional Cloud Armor policy that is compliant with
METRO's requirements while also enabling you to fine-tune your policy for
application-specific needs.

> [!WARNING]
> Not all features of the upstream module are supported yet. Regional Cloud
> Armor policies do not support the same features as global policies. **If
> possible, the usage of a Global Load Balancer is recommended.**

<!-- mdformat-toc start --slug=github --no-anchors --maxlevel=6 --minlevel=2 -->

- [Getting Started](#getting-started)
- [Usage](#usage)

<!-- mdformat-toc end -->

## Getting Started

[See root modules README file][root-module-readme].

## Usage

```hcl
module "cloudarmor_policy" {
  source  = "metro-digital/cf-cloudarmor-policy/google//modules/regional-backend-security-policy"
  version = "~> 0.2"

  project_id = "cf-example-project"
}
```

Every instance of the module manages one Cloud Armor regional security policy.
If you want to define multiple policies, create a multiple instance of the
module.

This module allows you to configure security policy rules in four primary
categories, each configured using a different input variable:

- **Security rules (`security_rules`):** Rules blocking of traffic matching
  specific IP addresses in CIDR notation. By default, no such rules are
  deployed.
- **Custom rules (`custom_rules`):** Rules blocking of traffic matching specific
  [CEL expressions][cel-documentation]. These rules can act e.g. based on the
  requests origin IP address, headers, path or region. By default, no such rules
  are deployed.
- **Pre-configured rules (`pre_configured_rules_overwrites`):** Pre-defined
  rules by Google detecting and preventing e.g. vulnerabilities of specific
  programming languages, cross-site scripting or SQL injections. These rules are
  effectively a set of Google-maintained custom CEL-based rules. The module
  deploys a baseline of such rules if not otherwise specified.

For more information on the baseline of rules deployed by this module and how to
tweak it, see the section on the _default policy_ in the
[root modules README file][root-module-readme].

[cel-documentation]: https://cloud.google.com/armor/docs/rules-language-reference
[changelog]: ./../../docs/CHANGELOG.md
[contributing]: ./../../docs/CONTRIBUTING.md
[faq]: ./../../docs/FAQ.md
[root-module]: ./../../
[root-module-readme]: ./../../README.md
[upstream-module]: https://registry.terraform.io/modules/GoogleCloudPlatform/cloud-armor/google/latest
