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
  # Security rules are under full user control, there are currently no requirements
  security_rules = var.security_rules
  # Same applies to custom rules, those are also just forwarded to Google's module.
  custom_rules = var.custom_rules

  # The *_overwrites input variables will be merged with the defaults provided by this module
  # to allow the user to overwrite any value given by the module.
  # As any value in this objects given by the user is null if not specified, this would overwrite
  # all defaults, therefore we filter out any null value before sending the data to the merge() function
  pre_configured_rules_overwrites = {
    for rule_name, rule_config in var.pre_configured_rules_overwrites : rule_name => {
      for k, v in rule_config : k => v if v != null
    }
  }
  threat_intelligence_rules_overwrites = {
    for rule_name, rule_config in var.threat_intelligence_rules_overwrites : rule_name => {
      for k, v in rule_config : k => v if v != null
    }
  }

  # Filter out null values from adaptive_protection_auto_deploy_overwrites
  # We need to take some care to preserve the rate_limit_options structure
  filtered_overwrites_auto_deploy_lev_1 = {
    for k, v in var.adaptive_protection_auto_deploy_overwrites :
    k => v if v != null
  }
  filtered_overwrites_rate_limit_options = {
    for k, v in var.adaptive_protection_auto_deploy_overwrites.rate_limit_options :
    k => v if v != null
  }
  filtered_overwrites_exceed_redirect_options = try({
    for k, v in var.adaptive_protection_auto_deploy_overwrites.rate_limit_options.exceed_redirect_options :
    k => v if v != null
  }, null)
  # filtered_overwrites_exceed_redirect_options = {}


  # Default configurations for pre-configured rules and threat intelligence rules

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

  threat_intelligence_rules_defaults = {
    "TI-malicious-ips" = {
      description = "Traffic from known malicious IPs"
      priority    = 10100
      action      = "deny(403)"
      feed        = "iplist-known-malicious-ips"
    },
    "TI-crypto-miners" = {
      description = "Traffic from known crypto miners"
      priority    = 10200
      action      = "deny(403)"
      feed        = "iplist-crypto-miners"
    },
    # In some countries, VPN providers are used quite often.
    # Enable this rule only after careful consideration.
    "TI-VPN-providers" = {
      enable      = false
      description = "Traffic from low-reputation VPN providers"
      priority    = 10300
      action      = "deny(403)"
      feed        = "iplist-vpn-providers"
    },
    "TI-anon-proxies" = {
      description = "Traffic from known open anonymous proxies"
      priority    = 10400
      action      = "deny(403)"
      feed        = "iplist-anon-proxies"
    },
    "TI-tor-exit-nodes" = {
      description = "Traffic from Tor nodes"
      priority    = 10500
      action      = "deny(403)"
      feed        = "iplist-tor-exit-nodes"
    },
    "TI-allow-search-engines" = {
      description = "Allow traffic from search engine crawlers"
      priority    = 10600
      action      = "allow"
      feed        = "iplist-search-engines-crawlers"
    },
  }

  adaptive_protection_auto_deploy_defaults = {
    enable      = true
    priority    = 10000
    action      = "redirect"
    preview     = false
    description = "Adaptive Protection auto-deploy"

    ##########################################################################
    # Can be activated only if layer_7_ddos_defense_threshold_configs is null
    ##########################################################################
    load_threshold              = 0.8
    confidence_threshold        = 0.8
    impacted_baseline_threshold = 0.005
    expiration_sec              = 7200
    ##########################################################################

    redirect_type   = "GOOGLE_RECAPTCHA"
    redirect_target = null

    # rate_limit_options is needed for the rules where action is set to throttle or rate_based_ban.
    # By default, it is set to redirect, so the following parameters are not actively used.
    rate_limit_options = {
      enforce_on_key                       = "IP"
      enforce_on_key_name                  = null
      enforce_on_key_configs               = []
      exceed_action                        = "redirect" # deny or redirect
      rate_limit_http_request_count        = 200        # needed only if action is rate_limit
      rate_limit_http_request_interval_sec = 60         # must be 10, 30, 60, 120, 180, 240, 300, 600, 900, 1200, 1800, 2700, or 3600
      ban_duration_sec                     = 3600       # needed only if action is rate_based_ban
      ban_http_request_count               = 400        # needed only if action is rate_based_ban
      ban_http_request_interval_sec        = 60         # must be 10, 30, 60, 120, 180, 240, 300, 600, 900, 1200, 1800, 2700, or 3600
      # The redirect options are used when the action is set to redirect.
      exceed_redirect_options = {
        type   = "GOOGLE_RECAPTCHA"
        target = null
      }

      # The numbers provided (200, 400) are generic starting points.
      # Before enforcing any rate-limiting, analyze your server logs to understand the
      # behavior of your legitimate users. Find the 99th percentile for requests per
      # minute from a single IP and set your threshold above that to avoid impacting real users.
    }
  }

  # Merge the default configurations with any user-provided overrides.
  threat_intelligence_rules_merged = { for key, _ in merge(local.threat_intelligence_rules_defaults, local.threat_intelligence_rules_overwrites) :
    key => merge(
      can(local.threat_intelligence_rules_defaults[key]) ? local.threat_intelligence_rules_defaults[key] : null,
      can(local.threat_intelligence_rules_overwrites[key]) ? local.threat_intelligence_rules_overwrites[key] : null
    )
  }

  pre_configured_rules_merged = { for key, _ in merge(local.pre_configured_rules_defaults, local.pre_configured_rules_overwrites) :
    key => merge(
      can(local.pre_configured_rules_defaults[key]) ? local.pre_configured_rules_defaults[key] : null,
      can(local.pre_configured_rules_overwrites[key]) ? local.pre_configured_rules_overwrites[key] : null
    )
  }

  threat_intelligence_rules = {
    for rule_name, rule_config in local.threat_intelligence_rules_merged :
    rule_name => rule_config
    if lookup(rule_config, "enable", true) # Only include rules that are enabled
  }

  pre_configured_rules = {
    for rule_name, rule_config in local.pre_configured_rules_merged :
    rule_name => rule_config
    if lookup(rule_config, "enable", true) # Only include rules that are enabled
  }

  # Start with the defaults
  adaptive_protection_auto_deploy = merge(
    local.adaptive_protection_auto_deploy_defaults,
    local.filtered_overwrites_auto_deploy_lev_1,
    {
      rate_limit_options = merge(
        local.adaptive_protection_auto_deploy_defaults.rate_limit_options,
        local.filtered_overwrites_rate_limit_options,
        {
          exceed_redirect_options = merge(
            local.adaptive_protection_auto_deploy_defaults.rate_limit_options.exceed_redirect_options,
            local.filtered_overwrites_exceed_redirect_options
          )
        }
      )
    }
  )
}
