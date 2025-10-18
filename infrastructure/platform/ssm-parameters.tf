resource "aws_ssm_parameter" "platform_info" {
  for_each = local.platform_parameters

  name        = "${local.ssm_prefix}/${each.key}"
  type        = "String"
  value       = each.value
  description = "Platform infrastructure parameter: ${each.key}"

  tags = merge(local.common_tags, {
    Component = "ssm-parameters"
  })
}
