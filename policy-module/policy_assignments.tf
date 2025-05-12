resource "azapi_resource" "policy_assignments" {
  for_each = local.assignment_map

  type      = "Microsoft.Authorization/policyAssignments@2021-06-01"
  name      = substr("${each.value.policy}-${substr(md5(each.value.scope), 0, 6)}", 0, 24)
  parent_id = each.value.scope

  body = {
    properties = {
      displayName        = "Assignment of ${each.value.policy} to ${each.value.scope}"
      policyDefinitionId = "/providers/Microsoft.Management/managementGroups/${var.root_management_group_id}/providers/Microsoft.Authorization/policyDefinitions/${each.value.policy}"


      notScopes = lookup(local.exclusion_map, each.key, [])

      parameters = {
        effect = {
          value = each.value.effect
        }
      }
    }
  }

  depends_on = [azapi_resource.policy_definitions]
}

resource "azapi_resource" "policy_set_assignments" {
  for_each = local.policy_set_assignment_map

  type      = "Microsoft.Authorization/policyAssignments@2021-06-01"
  name      = substr("${each.value.policy_set}-${substr(md5(each.value.scope), 0, 6)}", 0, 24)
  parent_id = each.value.scope

  body = {
    properties = {
      displayName        = "Assignment of ${each.value.policy_set} to ${each.value.scope}"
      policyDefinitionId = "/providers/Microsoft.Management/managementGroups/${var.root_management_group_id}/providers/Microsoft.Authorization/policySetDefinitions/${each.value.policy_set}"

      parameters = {
        effect = {
          value = each.value.effect
        }
      }
    }
  }

  depends_on = [azapi_resource.policy_set_definitions]
}
