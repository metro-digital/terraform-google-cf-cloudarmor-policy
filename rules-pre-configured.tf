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

locals {
  pre_configured_rules_defaults = {
    "WAF-SQL-injection" = {
      description       = "OWASP CRS: SQL Injection Protection (v33-stable)"
      priority          = 30000
      action            = "deny(403)"
      target_rule_set   = "sqli-v33-stable"
      sensitivity_level = 2
    },
    "WAF-XSS" = {
      description       = "OWASP CRS: Cross-Site Scripting Protection (v33-stable)"
      priority          = 30100
      action            = "deny(403)"
      target_rule_set   = "xss-v33-stable"
      sensitivity_level = 2
    },
    "WAF-LFI" = {
      description       = "OWASP CRS: Local File Inclusion Protection (v33-stable)"
      priority          = 30200
      action            = "deny(403)"
      target_rule_set   = "lfi-v33-stable"
      sensitivity_level = 2
    },
    "WAF-RCE" = {
      description       = "OWASP CRS: Remote Code Execution Protection (v33-stable)"
      priority          = 30300
      action            = "deny(403)"
      target_rule_set   = "rce-v33-stable"
      sensitivity_level = 2
    },
    "WAF-RFI" = {
      description       = "OWASP CRS: Remote File Inclusion Protection (v33-stable)"
      priority          = 30400
      action            = "deny(403)"
      target_rule_set   = "rfi-v33-stable"
      sensitivity_level = 2
    },
    "WAF-HTTP-method" = {
      description       = "OWASP CRS: HTTP Method Protection (v33-stable)"
      priority          = 30500
      action            = "deny(403)"
      target_rule_set   = "methodenforcement-v33-stable"
      sensitivity_level = 2
    },
    "WAF-scanner-detection" = {
      description       = "OWASP CRS: Scanner Detection (v33-stable)"
      priority          = 30600
      action            = "deny(403)"
      target_rule_set   = "scannerdetection-v33-stable"
      sensitivity_level = 2
    },
    "WAF-protocol-attack" = {
      description       = "OWASP CRS: Protocol Attack Protection (v33-stable)"
      action            = "deny(403)"
      priority          = 30700
      target_rule_set   = "protocolattack-v33-stable"
      sensitivity_level = 2
    },
    "WAF-session-fixation" = {
      description       = "OWASP CRS: Session Fixation Protection (v33-stable)"
      action            = "deny(403)"
      priority          = 30800
      target_rule_set   = "sessionfixation-v33-stable"
      sensitivity_level = 2
    },
    # Disabled rules for specific languages, can be enabled as needed.
    # We have a limited number of CEL expressions available in the policy,
    # so do not enable these unless necessary.
    "WAF-php" = {
      enable            = false
      description       = "OWASP CRS: PHP Injection Protection (v33-stable)"
      priority          = 30900
      action            = "deny(403)"
      target_rule_set   = "php-v33-stable"
      sensitivity_level = 2
    },
    "WAF-java" = {
      enable            = false
      description       = "OWASP CRS: Java Injection Protection (v33-stable)"
      priority          = 31000
      action            = "deny(403)"
      target_rule_set   = "java-v33-stable"
      sensitivity_level = 2
    },
    "WAF-nodejs" = {
      enable            = false
      description       = "OWASP CRS: Node.js Injection Protection (v33-stable)"
      priority          = 31100
      action            = "deny(403)"
      target_rule_set   = "nodejs-v33-stable"
      sensitivity_level = 2
    }
  }

  # The pre_configured_rules_overwrites input variables will be merged with the defaults provided by this module
  # to allow the user to overwrite any value given by the module.
  # As any value in this objects given by the user is null if not specified, this would overwrite
  # all defaults, therefore we filter out any null value before sending the data to the merge() function
  pre_configured_rules_overwrites = {
    for rule_name, rule_config in var.pre_configured_rules_overwrites : rule_name => {
      for k, v in rule_config : k => v if v != null
    }
  }

  # Merge the default configurations with any user-provided filtered overrides.
  pre_configured_rules_merged = { for key, _ in merge(local.pre_configured_rules_defaults, local.pre_configured_rules_overwrites) :
    key => merge(
      can(local.pre_configured_rules_defaults[key]) ? local.pre_configured_rules_defaults[key] : null,
      can(local.pre_configured_rules_overwrites[key]) ? local.pre_configured_rules_overwrites[key] : null
    )
  }

  # Ensure we only include enabled rules
  pre_configured_rules = {
    for rule_name, rule_config in local.pre_configured_rules_merged :
    rule_name => rule_config
    if lookup(rule_config, "enable", true) # Only include rules that are enabled
  }
}
