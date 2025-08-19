# Cloud Foundation Customer Example: Global Security Policy

This code shows how to combine this module with
[Cloud Foundation's `projectcfg` module][projectcfg-module]. The `projectcfg`
module is used to configure the underlying permissions and overall settings of
the projects. The Cloud Armor module only manages the Cloud Armor security
policy.

> [!TIP]
> More detailed examples of Cloud Armor fine-tuning options and how to use the
> generated security policy can be found [here][detailed-examples].

[detailed-examples]: https://github.com/GoogleCloudPlatform/terraform-google-cloud-armor/tree/main/examples
[projectcfg-module]: https://github.com/metro-digital/terraform-google-cf-projectcfg
