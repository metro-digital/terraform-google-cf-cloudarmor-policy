# Copyright 2025 METRO Digital GmbH
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

variable "project_id" {
  description = "Google Cloud project ID."
  type        = string
  nullable    = false

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,30}[a-z0-9]", var.project_id))
    error_message = <<-EOM
      It must be 6 to 30 lowercase letters, digits, or hyphens. It must start with a letter.
      Trailing hyphens are prohibited.
    EOM
  }
}

variable "name" {
  description = "Name of the Cloud Armor policy created"
  type        = string
  nullable    = false
  default     = "metro-baseline"
}

variable "description" {
  description = "Name of the Cloud Armor policy created"
  type        = string
  nullable    = true
  default     = "Metro Baseline Security Policy"
}

variable "log_level" {
  description = "Cloud Armor policy log level, can be NORMAL or VERBOSE"
  type        = string
  nullable    = false
  default     = "NORMAL"

  validation {
    condition     = contains(["NORMAL", "VERBOSE"], var.log_level)
    error_message = <<-EOE
      Invalid log level given: '${var.log_level}'

      Supported values are:
        - NORMAL
        - VERBOSE
    EOE
  }
}

variable "layer_7_ddos_defense_rule_visibility" {
  description = "If set to PREMIUM more detailed insights to generated DDoS protection rules are provided"
  type        = string
  nullable    = false
  default     = "PREMIUM"

  validation {
    condition     = contains(["PREMIUM", "STANDARD"], var.layer_7_ddos_defense_rule_visibility)
    error_message = <<-EOE
      Invalid value given: '${var.layer_7_ddos_defense_rule_visibility}'

      Supported values are:
        - STANDARD
        - PREMIUM
    EOE
  }
}

variable "pre_configured_rules_overwrites" {
  description = <<-EOD
    Values to overwrite the default pre configured rules provided by the baseline.
    Be aware that deviating from the baseline could reduce the effectiveness of the security policy
    and lead to security violation findings.
    The description of this object can be found in the upstream cloud armor module documentation
    https://registry.terraform.io/modules/GoogleCloudPlatform/cloud-armor/google/latest
  EOD
  type = map(object({
    enable                  = optional(bool)
    action                  = optional(string)
    priority                = optional(number)
    description             = optional(string)
    preview                 = optional(bool)
    redirect_type           = optional(string)
    redirect_target         = optional(string)
    target_rule_set         = optional(string)
    sensitivity_level       = optional(number)
    include_target_rule_ids = optional(list(string), [])
    exclude_target_rule_ids = optional(list(string), [])
    rate_limit_options = optional(object({
      enforce_on_key      = optional(string)
      enforce_on_key_name = optional(string)
      enforce_on_key_configs = optional(list(object({
        enforce_on_key_name = optional(string)
        enforce_on_key_type = optional(string)
      })))
      exceed_action                        = optional(string)
      rate_limit_http_request_count        = optional(number)
      rate_limit_http_request_interval_sec = optional(number)
      ban_duration_sec                     = optional(number)
      ban_http_request_count               = optional(number)
      ban_http_request_interval_sec        = optional(number)
    }), {})

    header_action = optional(list(object({
      header_name  = optional(string)
      header_value = optional(string)
    })), [])

    preconfigured_waf_config_exclusions = optional(map(object({
      target_rule_set = string
      target_rule_ids = optional(list(string), [])
      request_header = optional(list(object({
        operator = string
        value    = optional(string)
      })))
      request_cookie = optional(list(object({
        operator = string
        value    = optional(string)
      })))
      request_uri = optional(list(object({
        operator = string
        value    = optional(string)
      })))
      request_query_param = optional(list(object({
        operator = string
        value    = optional(string)
      })))
    })), null)

  }))
  default = {}
}

variable "threat_intelligence_rules_overwrites" {
  description = <<-EOD
    Values to overwrite the default threat intellingence rules provided by the baseline.
    Be aware that deviating from the baseline could reduce the effectiveness of the security policy
    and lead to security violation findings.
    The description of this object can be found in the upstream cloud armor module documentation
    https://registry.terraform.io/modules/GoogleCloudPlatform/cloud-armor/google/latest
  EOD
  type = map(object({
    enable      = optional(bool)
    action      = optional(string)
    priority    = optional(number)
    description = optional(string)
    preview     = optional(bool)
    feed        = optional(string)
    exclude_ip  = optional(string)
    rate_limit_options = optional(object({
      enforce_on_key      = optional(string)
      enforce_on_key_name = optional(string)
      enforce_on_key_configs = optional(list(object({
        enforce_on_key_name = optional(string)
        enforce_on_key_type = optional(string)
      })))
      exceed_action                        = optional(string)
      rate_limit_http_request_count        = optional(number)
      rate_limit_http_request_interval_sec = optional(number)
      ban_duration_sec                     = optional(number)
      ban_http_request_count               = optional(number)
      ban_http_request_interval_sec        = optional(number)
    }), {})
    header_action = optional(list(object({
      header_name  = optional(string)
      header_value = optional(string)
    })), [])
  }))
  default = {}
}

variable "adaptive_protection_auto_deploy_overwrites" {
  description = <<-EOD
    Values to overwrite the default auto deploy confivuration provided by the baseline.
    Be aware that deviating from the baseline could reduce the effectiveness of the security policy
    and lead to security violation findings.
    The description of this object can be found in the upstream cloud armor module documentation
    https://registry.terraform.io/modules/GoogleCloudPlatform/cloud-armor/google/latest
  EOD
  type = object({
    enable      = optional(bool)
    priority    = optional(number)
    action      = optional(string)
    preview     = optional(bool)
    description = optional(string)

    load_threshold              = optional(number)
    confidence_threshold        = optional(number)
    impacted_baseline_threshold = optional(number)
    expiration_sec              = optional(number)

    redirect_type   = optional(string)
    redirect_target = optional(string)

    rate_limit_options = optional(object({
      enforce_on_key      = optional(string)
      enforce_on_key_name = optional(string)

      enforce_on_key_configs = optional(list(object({
        enforce_on_key_name = optional(string)
        enforce_on_key_type = optional(string)
      })))

      exceed_action                        = optional(string)
      rate_limit_http_request_count        = optional(number)
      rate_limit_http_request_interval_sec = optional(number)
      ban_duration_sec                     = optional(number)
      ban_http_request_count               = optional(number)
      ban_http_request_interval_sec        = optional(number)
      exceed_redirect_options = optional(object({
        type   = string
        target = optional(string)
      }))
    }), {})
  })
  default = {}
}

variable "custom_rules" {
  description = <<-EOD
    Map of custom rules.
    No defaults are provided for this configuration. Details about the object can be found in
    upstream cloud armor module documentation.
    https://registry.terraform.io/modules/GoogleCloudPlatform/cloud-armor/google/latest
  EOD
  type = map(object({
    action                            = string
    priority                          = number
    description                       = optional(string)
    preview                           = optional(bool, false)
    expression                        = string
    recaptcha_action_token_site_keys  = optional(list(string))
    recaptcha_session_token_site_keys = optional(list(string))
    redirect_type                     = optional(string, null)
    redirect_target                   = optional(string, null)
    rate_limit_options = optional(object({
      enforce_on_key      = optional(string)
      enforce_on_key_name = optional(string)
      enforce_on_key_configs = optional(list(object({
        enforce_on_key_name = optional(string)
        enforce_on_key_type = optional(string)
      })))
      exceed_action                        = optional(string)
      rate_limit_http_request_count        = optional(number)
      rate_limit_http_request_interval_sec = optional(number)
      ban_duration_sec                     = optional(number)
      ban_http_request_count               = optional(number)
      ban_http_request_interval_sec        = optional(number)
      }),
    {})
    header_action = optional(list(object({
      header_name  = optional(string)
      header_value = optional(string)
    })), [])

    preconfigured_waf_config_exclusions = optional(map(object({
      target_rule_set = string
      target_rule_ids = optional(list(string), [])
      request_header = optional(list(object({
        operator = string
        value    = optional(string)
      })))
      request_cookie = optional(list(object({
        operator = string
        value    = optional(string)
      })))
      request_uri = optional(list(object({
        operator = string
        value    = optional(string)
      })))
      request_query_param = optional(list(object({
        operator = string
        value    = optional(string)
      })))
    })), null)

  }))
  default = {}
}

variable "security_rules" {
  description = <<-EOD
    Map of security rules.
    No defaults are provided for this configuration. Details about the object can be found in
    upstream cloud armor module documentation.
    https://registry.terraform.io/modules/GoogleCloudPlatform/cloud-armor/google/latest
  EOD
  type = map(object({
    action          = string
    priority        = number
    description     = optional(string)
    preview         = optional(bool, false)
    redirect_type   = optional(string, null)
    redirect_target = optional(string, null)
    src_ip_ranges   = list(string)
    rate_limit_options = optional(object({
      enforce_on_key      = optional(string)
      enforce_on_key_name = optional(string)
      enforce_on_key_configs = optional(list(object({
        enforce_on_key_name = optional(string)
        enforce_on_key_type = optional(string)
      })))
      exceed_action                        = optional(string)
      rate_limit_http_request_count        = optional(number)
      rate_limit_http_request_interval_sec = optional(number)
      ban_duration_sec                     = optional(number)
      ban_http_request_count               = optional(number)
      ban_http_request_interval_sec        = optional(number)
    }), {})
    header_action = optional(list(object({
      header_name  = optional(string)
      header_value = optional(string)
    })), [])
  }))
  default = {}
}
