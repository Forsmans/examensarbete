
resource "azapi_resource" "policy_definitions" {
  for_each                  = local.all_policy_definitions
  type                      = "Microsoft.Authorization/policyDefinitions@2021-06-01"
  name                      = each.key
  parent_id                 = "/providers/Microsoft.Management/managementGroups/${var.root_management_group_id}"
  body                      = jsondecode(each.value)
  schema_validation_enabled = false

  depends_on = [data.alz_architecture.this]
}

resource "azapi_resource" "policy_set_definitions" {
  for_each = local.policy_set_bodies

  type      = "Microsoft.Authorization/policySetDefinitions@2021-06-01"
  name      = each.key
  parent_id = "/providers/Microsoft.Management/managementGroups/${var.root_management_group_id}"

  body = jsondecode(
    replace(
      jsonencode(each.value),
      "managementGroups/contoso",
      "managementGroups/${var.root_management_group_id}"
    )
  )

  schema_validation_enabled = false
  ignore_missing_property   = true
}

