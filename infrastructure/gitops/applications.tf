# Bootstrap application
resource "argocd_application" "bootstrap" {
  metadata {
    name      = "bootstrap"
    namespace = var.argocd_namespace
  }

  spec {
    project = "argocd"

    source {
      repo_url        = "https://github.com/CameronXie/eks-explorer.git"
      path            = "bootstrap/chart"
      target_revision = "HEAD"

      helm {
        values = yamlencode({
          environment = var.environment
          s3 = {
            loki  = local.loki_s3_buckets
            mimir = local.mimir_s3_buckets
            tempo = {
              trace = local.tempo_s3_bucket
            }
          }
        })
      }
    }

    destination {
      server    = "https://kubernetes.default.svc"
      namespace = var.argocd_namespace
    }

    sync_policy {
      automated {
        prune     = true
        self_heal = true
      }
      sync_options = [
        "CreateNamespace=true",
        "ServerSideApply=true",
      ]
      retry {
        limit = 10
        backoff {
          duration     = "15s"
          factor       = 2
          max_duration = "2m"
        }
      }
    }
  }

  depends_on = [
    argocd_project.argocd,
    argocd_project.cluster_addons,
  ]
}
