locals {
  alzlib_root_path           = "./.alzlib/203131bcdde628814403ec6ebba3702ef596305d47c3429973459a31"
  alzlib_definition_path     = "${local.alzlib_root_path}/policy_definitions"
  alzlib_set_definition_path = "${local.alzlib_root_path}/policy_set_definitions"

  #Policy Definitions
  all_policy_files      = fileset(local.alzlib_definition_path, "*.json")
  all_policy_names      = [for f in local.all_policy_files : replace(f, ".alz_policy_definition.json", "")]
  filtered_policy_names = [for f in local.all_policy_names : f if !contains(var.excluded_policy_definitions, f)]
  policy_definition_files = {
    for policy in local.filtered_policy_names :
    policy => file("${local.alzlib_definition_path}/${policy}.alz_policy_definition.json")
  }

  #Policy Set Definitions
  all_policy_set_files      = fileset(local.alzlib_set_definition_path, "*.json")
  all_policy_set_names      = [for f in local.all_policy_set_files : replace(f, ".alz_policy_set_definition.json", "")]
  filtered_policy_set_names = [for f in local.all_policy_set_names : f if !contains(var.excluded_policy_set_definitions, f)]
  policy_set_definition_files = {
    for policy in local.filtered_policy_set_names :
    policy => file("${local.alzlib_set_definition_path}/${policy}.alz_policy_set_definition.json")
  }
  #Changing to the correct defintion scope
  policy_set_bodies = {
    for name, raw_json in local.policy_set_definition_files : name => {
      name = name
      properties = merge(
        jsondecode(raw_json).properties,
        {
          policyDefinitions = [
            for pd in jsondecode(raw_json).properties.policyDefinitions : merge(
              pd,
              {
                policyDefinitionId = (
                  startswith(pd.policyDefinitionId, "/") ?
                  pd.policyDefinitionId :
                  (
                    substr(pd.policyDefinitionId, 0, 5) == "Deny-" ?
                    "/providers/Microsoft.Authorization/policyDefinitions/${pd.policyDefinitionId}" :
                    "/providers/Microsoft.Management/managementGroups/${var.root_management_group_id}/providers/Microsoft.Authorization/policyDefinitions/${pd.policyDefinitionId}"
                  )
                )
              }
            )
          ]
        }
      )
    }
  }




  #Custom Policy Definitions
  custom_policy_files = {
    for file in fileset("./custom_definitions", "*.json") :
    trimsuffix(file, ".json") => file("./custom_definitions/${file}")
  }

  #Merge definition sources
  all_policy_definitions = merge(
    local.policy_definition_files,
    local.custom_policy_files,
    #local.policy_set_definition_files
  )

  #Logic for Policy Assignments
  assignment_tuples = flatten([
    for scope, policies in var.policy_assignments_by_scope : [
      for policy_name, effect in policies : {
        scope  = scope
        policy = policy_name
        effect = effect
      }
    ]
  ])

  assignment_map = {
    for item in local.assignment_tuples :
    "${item.scope}--${item.policy}" => item
  }

  #Logic for Policy Set Assignments
  policy_set_assignment_tuples = flatten([
    for scope, policy_sets in var.policy_set_assignments_by_scope : [
      for policy_set_name, effect in policy_sets : {
        scope      = scope
        policy_set = policy_set_name
        effect     = effect
      }
    ]
  ])

  policy_set_assignment_map = {
    for item in local.policy_set_assignment_tuples :
    "${item.scope}--${item.policy_set}" => item
  }

  # Exclusion logic
  exclusion_tuples = flatten([
    for scope, policies in var.policy_exclusions_by_scope : [
      for policy_name, excluded_scopes in policies : {
        assignment_key  = "${scope}--${policy_name}"
        excluded_scopes = excluded_scopes
      }
    ]
  ])

  exclusion_map = {
    for item in local.exclusion_tuples :
    item.assignment_key => item.excluded_scopes
  }
}
