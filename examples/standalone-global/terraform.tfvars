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

# Examples on how to change default rules provided by the baseline.
# DO NOT use those parameters in production, they are only for demonstration purposes.

# For more examples, see the upstream module documentation:
# https://registry.terraform.io/modules/GoogleCloudPlatform/cloud-armor/google/latest

# name = "my-example-stuff"

# pre_configured_rules_overwrites = {
#   # We have a nodejs app, so activate the corresponding rule
#   "WAF-nodejs" = {
#     enable = true
#   },
#
#   # SQL Injection could be nasty, increaase sensitivity
#   "WAF-SQL-injection" = {
#     sensitivity_level = 4
#   },
# }

# threat_intelligence_rules_overwrites = {
#   # We don't want untrusted VPN traffic, so we enable the rule
#   # and modify the description
#   TI-VPN-providers = {
#     enable      = true
#     description = "Traffic from known VPN providers"
#   }
# }

######################################################################################
# This is not an override, as baseline does not provide any security rule.
# That means that there is no preconfigured parameters.
# Taken from upstream module:
# https://registry.terraform.io/modules/GoogleCloudPlatform/cloud-armor/google/latest
######################################################################################
# security_rules = {
#   "deny_project_bad_actor1" = {
#     action        = "deny(502)"
#     priority      = 11
#     description   = "Deny Malicious IP address from project bad_actor1"
#     src_ip_ranges = ["190.217.68.211/32", "45.116.227.68/32", "103.43.141.122", "123.11.215.36", "123.11.215.37", ]
#     preview       = true
#   }
# }


######################################################################################
# Adaption Protection Auto Deploy
######################################################################################

# adaptive_protection_auto_deploy_overwrites = {
#    enable      = true
#    priority    = 1000
#    action      = "redirect"
#    preview     = false
#    description = "Adaptive Protection auto-deploy"
#
#    load_threshold              = 9
#    confidence_threshold        = 0.8
#    impacted_baseline_threshold = 0.005
#    expiration_sec              = 7200
#
#    redirect_type   = "GOOGLE_RECAPTCHA"
#    redirect_target = null
#
#    rate_limit_options = {
#      enforce_on_key                       = "ALL"
#      enforce_on_key_name                  = null
#      enforce_on_key_configs               = []
#      exceed_action                        = "redirect"
#      rate_limit_http_request_count        = 50000
#      rate_limit_http_request_interval_sec = 50
#      ban_duration_sec                     = 7777
#      ban_http_request_count               = 10000
#      ban_http_request_interval_sec        = 60
#      exceed_redirect_options = {
#        type   = "GOOGLE_RECAPTCHA"
#        target = null
#      }
#    }
# }
