# SPDX-FileCopyrightText: Copyright (c) 2023 NVIDIA CORPORATION & AFFILIATES. All rights reserved.
# SPDX-License-Identifier: Apache-2.0

/*******************************************
GKE Workload Identity
*******************************************/
module "managed-prometheus-workload-identity" {
  count               = var.gke_managed_prometheus_enabled ? 1 : 0
  source              = "terraform-google-modules/kubernetes-engine/google//modules/workload-identity"
  use_existing_gcp_sa = true
  name                = google_service_account.prometheus_service_account[count.index].account_id
  project_id          = var.project_id
  depends_on          = [google_service_account.prometheus_service_account]
}

/*******************************************
Prometheus Service Account Config
*******************************************/
resource "random_string" "gke" {
  count   = var.gke_managed_prometheus_enabled ? 1 : 0
  length  = 3
  special = false
  upper   = false
}

resource "google_service_account" "prometheus_service_account" {
  count        = var.gke_managed_prometheus_enabled ? 1 : 0
  account_id   = "nvidia-prometheus-${random_string.gke[count.index].result}"
  display_name = "Prometheus Service Account"
  project      = var.project_id
}

resource "google_project_iam_binding" "prometheus_service_account" {
  count   = var.gke_managed_prometheus_enabled ? 1 : 0
  project = var.project_id
  role    = "roles/monitoring.metricWriter"
  members = ["serviceAccount:${module.managed-prometheus-workload-identity[count.index].gcp_service_account_email}"]
}

resource "google_service_account_iam_binding" "prometheus_service_account" {
  count              = var.gke_managed_prometheus_enabled ? 1 : 0
  service_account_id = google_service_account.prometheus_service_account[count.index].name
  role               = "roles/iam.workloadIdentityUser"
  members            = ["serviceAccount:${var.project_id}.svc.id.goog[nvidia-monitoring/nvidia-prometheus-prometheus]"]
}
