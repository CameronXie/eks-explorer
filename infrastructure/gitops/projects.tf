# ArgoCD project for ArgoCD self-management and bootstrap
resource "argocd_project" "argocd" {
  metadata {
    name      = "argocd"
    namespace = var.argocd_namespace
  }

  spec {
    description = "ArgoCD self-management and bootstrap"
    source_repos = [
      "https://github.com/CameronXie/eks-explorer.git",
      "https://argoproj.github.io/argo-helm",
    ]

    destination {
      server    = "https://kubernetes.default.svc"
      namespace = "*"
    }

    # Allow all cluster-scoped resources for ArgoCD management
    cluster_resource_whitelist {
      group = "*"
      kind  = "*"
    }

    # Allow all namespace-scoped resources
    namespace_resource_whitelist {
      group = "*"
      kind  = "*"
    }

    # Orphaned resources handling
    orphaned_resources {
      warn = true
    }
  }
}

# ArgoCD project for cluster addons and platform services
resource "argocd_project" "cluster_addons" {
  metadata {
    name      = "cluster-addons"
    namespace = var.argocd_namespace
  }

  spec {
    description = "Cluster-level infrastructure and platform components"
    source_repos = [
      "https://github.com/CameronXie/eks-explorer.git",
      "https://charts.jetstack.io",
      "https://kubernetes-sigs.github.io/metrics-server",
      "https://prometheus-community.github.io/helm-charts",
      "https://grafana.github.io/helm-charts",
      "https://open-telemetry.github.io/opentelemetry-helm-charts",
    ]

    # Allow deployments to specific namespaces
    destination {
      server    = "https://kubernetes.default.svc"
      namespace = "cert-manager"
    }

    destination {
      server    = "https://kubernetes.default.svc"
      namespace = "kube-system"
    }

    destination {
      server    = "https://kubernetes.default.svc"
      namespace = "observability"
    }

    destination {
      server    = "https://kubernetes.default.svc"
      namespace = "monitoring"
    }

    # Allow all cluster-scoped resources (needed for CRDs, ClusterRoles, etc.)
    cluster_resource_whitelist {
      group = "*"
      kind  = "*"
    }

    # Allow all namespace-scoped resources
    namespace_resource_whitelist {
      group = "*"
      kind  = "*"
    }

    # Orphaned resources handling
    orphaned_resources {
      warn = true
    }
  }
}
