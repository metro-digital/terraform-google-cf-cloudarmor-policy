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

  # The threat_intelligence_rules_overwrites input variables will be merged with the defaults provided by this module
  # to allow the user to overwrite any value given by the module.
  # As any value in this objects given by the user is null if not specified, this would overwrite
  # all defaults, therefore we filter out any null value before sending the data to the merge() function
  threat_intelligence_rules_overwrites = {
    for rule_name, rule_config in var.threat_intelligence_rules_overwrites : rule_name => {
      for k, v in rule_config : k => v if v != null
    }
  }

  # Merge the default configurations with any user-provided filtered overrides.
  threat_intelligence_rules_merged = { for key, _ in merge(local.threat_intelligence_rules_defaults, local.threat_intelligence_rules_overwrites) :
    key => merge(
      can(local.threat_intelligence_rules_defaults[key]) ? local.threat_intelligence_rules_defaults[key] : null,
      can(local.threat_intelligence_rules_overwrites[key]) ? local.threat_intelligence_rules_overwrites[key] : null
    )
  }

  # Ensure we only include enabled rules
  threat_intelligence_rules = {
    for rule_name, rule_config in local.threat_intelligence_rules_merged :
    rule_name => rule_config
    if lookup(rule_config, "enable", true) # Only include rules that are enabled
  }
}
