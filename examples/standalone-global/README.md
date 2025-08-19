# Standalone Example: Global Security Policy

> [!WARNING]
> If you are a Cloud Foundation customer within METRO, you should use the `cf-*`
> examples instead. This example is designed to be used in existing, non-Cloud
> Foundation projects.

This code shows how to use the module to setup Cloud Armor security policies in
your project. It only requires the `project_id` as input. When run as-is, it
will apply the module's default matching METRO's baseline. A `terraform.tfvars`
is included with some random examples. Please be aware that those examples are
not really meaningful, you need to put your real stuff there.

> [!TIP]
> More detailed examples of Cloud Armor fine-tuning options and how to use the
> generated security policy can be found [here][detailed-examples].

[detailed-examples]: https://github.com/GoogleCloudPlatform/terraform-google-cloud-armor/tree/main/examples
