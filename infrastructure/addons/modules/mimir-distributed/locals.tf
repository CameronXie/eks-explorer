locals {
  # Module identifier for tagging
  module_name = "mimir-distributed"
  module_path = "infrastructure/addons/modules/mimir-distributed"

  # S3 bucket suffixes for different Mimir storage types
  bucket_suffixes = {
    blocks = "mimir-blocks"
    ruler  = "mimir-ruler"
  }

  # Generate full S3 bucket names
  bucket_names = {
    for k, v in local.bucket_suffixes :
    k => lower(format("%s-%s-%s", var.environment, var.project_name, v))
  }

  # Module default tags that cannot be overridden
  module_tags = {
    TerraformModule     = local.module_name
    TerraformModulePath = local.module_path
  }

  # Merge module tags with user-provided tags (module tags take precedence)
  tags = merge(var.tags, local.module_tags)
}
