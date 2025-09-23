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
