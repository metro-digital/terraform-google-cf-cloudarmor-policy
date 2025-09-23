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

resource "google_compute_project_cloud_armor_tier" "enterprise" {
  project          = var.project_id
  cloud_armor_tier = "CA_ENTERPRISE_ANNUAL"

  depends_on = [
    google_project_service.compute
  ]
}

module "cloud_armor_policy" {
  source  = "GoogleCloudPlatform/cloud-armor/google//modules/regional-backend-security-policy"
  version = "~> 6.0"

  project_id           = var.project_id
  name                 = var.name
  description          = var.description
  region               = var.region
  type                 = "CLOUD_ARMOR"
  security_rules       = var.security_rules
  pre_configured_rules = local.pre_configured_rules
  custom_rules         = var.custom_rules

  depends_on = [
    google_project_service.compute,
    google_project_service.recaptchaenterprise
  ]
}
