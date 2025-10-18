locals {
  # Module identifier for tagging
  module_name = "tempo-distributed"
  module_path = "infrastructure/addons/modules/tempo-distributed"

  # S3 bucket name for Tempo traces
  tempo_bucket_name = lower(format("%s-%s-tempo-traces", var.environment, var.project_name))

  # Module default tags that cannot be overridden
  module_tags = {
    TerraformModule     = local.module_name
    TerraformModulePath = local.module_path
  }

  # Merge module tags with user-provided tags (module tags take precedence)
  final_tags = merge(var.tags, local.module_tags)
}
