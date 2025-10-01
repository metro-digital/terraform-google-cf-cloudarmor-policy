# Cloud Foundation Cloud Armor Policy Module

[FAQ] | [CONTRIBUTING] | [CHANGELOG]

This module is an opinionated wrapper around the
[`GoogleCloudPlatform/cloud-armor` module][upstream-module] provided by Google.
It allows you to create a Cloud Armor policy that is compliant with METRO's
requirements while also enabling you to fine-tune your policy for
application-specific needs.

To create global Cloud Armor policies, use this module. For regional load
balancers setups, use this [submodule][regional-backend-security-policy].

> [!WARNING]
> Not all features of the upstream module are supported yet.

| Module Version  | Upstream Module Version | terraform provider version |
| --------------- | ----------------------- | -------------------------- |
| v0.1.0 - v0.1.1 | `~> 5.1`                | `~> 6.0`                   |
| v0.2.0 - latest | `~> 6.0`                | `>= 6.14, < 8`             |

<!-- mdformat-toc start --slug=github --no-anchors --maxlevel=6 --minlevel=2 -->

- [Getting Started](#getting-started)
- [Usage](#usage)
  - [Requirements](#requirements)
- [Features](#features)
  - [Default Policy](#default-policy)
  - [Enablement of Required Services](#enablement-of-required-services)
- [License](#license)

<!-- mdformat-toc end -->

## Getting Started

To get started, make sure to fulfil the requirements outlined below. If you use
METRO's [`projectcfg` Terraform module][projectcfg-module], the requirements can
be easily fulfilled. An example can be found [here][example-projectcfg]. Most
internal Cloud Foundation customers should use this example to get started.

If you don't rely on METRO's `projectcfg` module, you can also find a standalone
example [here][example-standalone].

This module does not require any input variable besides the project ID. It only
creates a Cloud Armor security policy and doesn't attach it to any load
balancer. To attach it to a load balancer, use the details of the generated
policy provided via the [module's output](./docs/TERRAFORM.md#outputs).

## Usage

```hcl
module "cloudarmor_policy" {
  source  = "metro-digital/cf-cloudarmor-policy/google"
  version = "~> 0.2"

  project_id = "cf-example-project"
}
```

Every instance of the module manages one Cloud Armor security policy. If you
want to define multiple policies, create a multiple instance of the module.

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
- **Threat intelligence rules (`threat_intelligence_rules_overwrites`):**
  Pre-defined rules by Google based on their global threat intelligence insights
  detecting and preventing e.g. traffic from known malicious IP addresses. This
  module deploys a baseline of such rules if not otherwise specified.

For more information on the baseline of rules deployed by this module and how to
tweak it, see the section on the _default policy_ below.

> [!TIP]
> A detailed description of input variables and output values can be found
> [here](./docs/TERRAFORM.md#inputs).
>
> Most input variables mirror the structure defined by the
> [upstream Terraform module][upstream-module]. The upstream documentation
> provides information on the details that you need to provide.

### Requirements

The user executing the Terraform code needs the following permissions on project
level:

- Enable APIs in the project (`roles/serviceusage.serviceUsageAdmin`)
- Configure the Cloud Armor tier and policies (`roles/compute.admin`)

Make sure that the principal used by Terraform has the required permissions on
GCP to create Cloud Armor resources. This includes the permissions to set the
Cloud Armor tier. If you encounter errors when running Terraform, check for
missing permissions and grant them to the principal executing the Terraform
code. The process is idempotent so you can re-run it if something goes wrong.

> [!NOTE]
> The above-mentioned role `roles/compute.admin` is very powerful but needed as
> this is the only role bundling the `compute.projects.setCloudArmorTier`
> permission. If you want to use a less powerful role like
> `roles/compute.securityAdmin`, you may need to create a custom role with the
> previously mentioned privileged to configure the Cloud Armor tier.

## Features

### Default Policy

This module creates a Cloud Armor security policy that you can use right away to
protect any resource supported by Cloud Armor.

Cloud Armor Adaptive Protection is enabled by default, allowing Cloud Armor to
automatically react to emerging threats. If detected, it redirects users to a
Google reCAPTCHA page to verify that they are a human user.

> [!WARNING]
> Adaptive Protection automatically deploys rules to your Cloud Armor security
> policy if it detects an emerging threat. This can have an impact on legitimate
> traffic if the automatically deployed rule is too sensitive. By default,
> Adaptive Protection always takes precedence over any other rule. You can tweak
> the behaviour of Adaptive Protection via the
> `adaptive_protection_auto_deploy_overwrites` input variable. If you get
> started, it might be sensible to set the `preview` property of this input
> variable to `true` to observe how Adaptive Protection evaluates your normal
> traffic.
>
> The default action is designed for user-initiated, human traffic. You will
> need to tweak the configurations of auto-deployed rules if your load balancer
> e.g. handles non-interactive, RESTful API requests which are not compatible
> with reCAPTCHA redirects.

The module also allows you to fine-tune the policy if needed. Be aware that
those fine-tuning capability may not automatically comply with METRO's policies
and can cause security findings and may require an exception.

Currently, only global Cloud Armor security policies are supported. Cloud Armor
network edge security policies are not supported yet.

By default, the security policy bundles the following rules:

- **Security rules:** None. Specify IP-based blocking of requests using the
  `security_rules` input variable following the structure outlined
  [here](./docs/TERRAFORM.md#inputs). Full examples can be found
  [here][upstream-module-security-rules].

- **Custom rules:** None. Specify CEL expression-based rules using the
  `custom_rules` input variable following the structure outlined
  [here](./docs/TERRAFORM.md#inputs). Full examples can be found
  [here][upstream-module-custom-rules].

- **Pre-configured rules:**

  Pre-configured rules for known threats are configured using the
  `pre_configured_rules_overwrites` input variable following the structure
  outlined [here](./docs/TERRAFORM.md#inputs). Rules are by default enabled by
  with a [sensitivity level][paranoia-explainer] (also referred to as _paranoia
  level_) of `2` which is a good starting point for production systems. Google
  outlines how to fine tune the pre-configured rules in
  [this blog post][sensitivity-post].

  The following rules are enabled by default:

  - OWASP CRS: SQL Injection Protection (v33-stable) (`WAF-SQL-injection`)
  - OWASP CRS: Cross-Site Scripting Protection (v33-stable) (`WAF-XSS`)
  - OWASP CRS: Local File Inclusion Protection (v33-stable) (`WAF-LFI`)
  - OWASP CRS: Remote Code Execution Protection (v33-stable) (`WAF-RCE`)
  - OWASP CRS: Remote File Inclusion Protection (v33-stable) (`WAF-RFI`)
  - OWASP CRS: HTTP Method Protection (v33-stable) (`WAF-HTTP-method`)
  - OWASP CRS: Scanner Detection (v33-stable) (`WAF-scanner-detection`)
  - OWASP CRS: Protocol Attack Protection (v33-stable) (`WAF-protocol-attack`)
  - OWASP CRS: Session Fixation Protection (v33-stable) (`WAF-session-fixation`)

  The following language-specific rules can be enabled with a default
  sensitivity level of `2`:

  - OWASP CRS: PHP Injection Protection (v33-stable) (`WAF-php`)
  - OWASP CRS: Java Injection Protection (v33-stable) (`WAF-java`)
  - OWASP CRS: Node.js Injection Protection (v33-stable) (`WAF-nodejs`)

  To enable a rule that is disabled by default, use the following syntax:

  ```hcl
  module "cloudarmor_policy" {
    source     = "metro-digital/cf-cloudarmor-policy/google"
    version    = "~> 0.1"
    # [...]

    pre_configured_rules_overwrites = {
      "WAF-java" = {
        enable = true
      }
    }
  }
  ```

- **Threat intelligence rules:** Threat intelligence rules are configured using
  the `threat_intelligence_rules_overwrites` input variable following the
  structure outlined [here](./docs/TERRAFORM.md#inputs). The following rules are
  enabled by default:

  - Traffic from known malicious IPs (`TI-malicious-ips`)
  - Traffic from known crypto miners (`TI-crypto-minders`)
  - Traffic from known open anonymous proxies (`TI-anon-proxies`)
  - Traffic from Tor nodes (`TI-tor-exit-nodes`)
  - **Allow** traffic from search engine crawlers (`TI-allow-search-engines`)

  The following rules can be enabled:

  - Traffic from VPN providers (`TI-VPN-providers`): In some countries, VPN
    providers route a significant amount of customer traffic. If you do not need
    to serve traffic to low-reputation VPN providers, you can enable blocking
    this traffic.

  To enable a rule that is disabled by default, use the following syntax:

  ```hcl
  module "cloudarmor_policy" {
    source     = "metro-digital/cf-cloudarmor-policy/google"
    version    = "~> 0.1"
    # [...]

    # Enable the blocking of low-reputation VPN provider-originating traffic.
    threat_intelligence_rules_overwrites = {
      "TI-VPN-providers" = {
        enable = true
      }
    }
  }
  ```

> [!CAUTION]
> This module creates at least 15 rules with CEL expressions. If you enable all
> rules, you will get 19 CEL expressions. Google by default has a quota of 20
> CEL-enabled rules per project, so you may
> [want to increase this quota][quota-management] to have some buffer for
> CEL-enabled rules, or if you need more than one policy. Example of the error
> you may get if you go beyond quota:
>
> ```
> ╷
> │ Error: Error waiting for Creating SecurityPolicy "my-policy-name": Quota
> │      'SECURITY_POLICY_CEVAL_RULES' exceeded.  Limit: 20.0 globally.
> │       metric name = compute.googleapis.com/security_policy_ceval_rules
> │       limit name = SECURITY-POLICY-CEVAL-RULES-per-project
> │       limit = 20
> │       dimensions = map[global:global]
> ```

### Enablement of Required Services

This module requires the following Google Cloud services to function:

- `compute.googleapis.com`
- `recaptchaenterprise.googleapis.com`

The module will enable all the required services automatically. This feature is
turned on by default. To disable this behavior, see the
[`automatic_service_enablement` input variable](./docs/TERRAFORM.md#inputs).

If you use the [`projectcfg` module][projectcfg-module] in combination with this
module and want to centrally manage all enabled APIs, you can disable the
automatic enabling by setting `automatic_service_enablement` to `false` and
configure the needed services via the `projectcfg` module's `enabled_services`
input variable.

When deleting an instance of this module, the enabled services are not disabled.

## License

This project is licensed under the terms of the [Apache License 2.0](LICENSE)

This [terraform] module depends on providers from HashiCorp, Inc. which are
licensed under MPL-2.0. You can obtain the respective source code for these
provider here:

- [`hashicorp/google`](https://github.com/hashicorp/terraform-provider-google)
- [`hashicorp/external`](https://github.com/hashicorp/terraform-provider-external)

This [terraform] module uses pre-commit hooks which are licensed under MPL-2.0.
You can obtain the respective source code here:

- [`terraform-linters/tflint`](https://github.com/terraform-linters/tflint)
- [`terraform-linters/tflint-ruleset-google`](https://github.com/terraform-linters/tflint-ruleset-google)

[cel-documentation]: https://cloud.google.com/armor/docs/rules-language-reference
[changelog]: ./docs/CHANGELOG.md
[contributing]: ./docs/CONTRIBUTING.md
[example-projectcfg]: https://github.com/metro-digital/terraform-google-cf-cloudarmor-policy/tree/main/examples/cf-projectcfg-global
[example-standalone]: https://github.com/metro-digital/terraform-google-cf-cloudarmor-policy/tree/main/examples/standalone-global
[faq]: ./docs/FAQ.md
[paranoia-explainer]: https://coreruleset.org/20211028/working-with-paranoia-levels/
[projectcfg-module]: https://github.com/metro-digital/terraform-google-cf-projectcfg
[quota-management]: https://cloud.google.com/docs/quotas/view-manage
[regional-backend-security-policy]: ./modules/regional-backend-security-policy
[sensitivity-post]: https://cloud.google.com/blog/products/identity-security/introducing-cloud-armor-features-to-help-improve-efficacy
[terraform]: https://terraform.io/
[upstream-module]: https://registry.terraform.io/modules/GoogleCloudPlatform/cloud-armor/google/latest
[upstream-module-custom-rules]: https://registry.terraform.io/modules/GoogleCloudPlatform/cloud-armor/google/latest#custom_rules
[upstream-module-security-rules]: https://registry.terraform.io/modules/GoogleCloudPlatform/cloud-armor/google/latest#security_rules
