module "xvm_policy" {
  source = "../policy-module"

  root_management_group_id = "00000000-0000-0000-0000-000000000000"

  #Policies

  excluded_policy_definitions = [
    "Append-Redis-sslEnforcement",
    "Audit-AzureHybridBenefit"
  ]

  policy_assignments_by_scope = {
    "/subscriptions/00000000-0000-0000-0000-000000000000" = {
      "Append-AppService-httpsonly" = "Append"
      "Append-AppService-latestTLS" = "Disabled"
      "Deny-AppServiceApiApp-http"  = "Audit"
    }
    "/providers/Microsoft.Management/managementGroups/corp" = {
      "Append-AppService-httpsonly" = "Disabled"
      "Append-KV-SoftDelete-Magnus" = "Audit"
    }
    "/providers/Microsoft.Management/managementGroups/online" = {
      "Deny-StorageAccount-Magnus"     = "Deny"
      "Audit-PublicIpAddresses-Magnus" = "Audit"
    }
  }

  policy_exclusions_by_scope = {
    "/subscriptions/00000000-0000-0000-0000-000000000000" = {
      "Append-AppService-httpsonly" = [
        "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-we-core",
      ]
    }
  }

  #Initiatives
  excluded_policy_set_definitions = [
    "Enforce-Encryption-CMK",
  ]

  policy_set_assignments_by_scope = {
    "/subscriptions/00000000-0000-0000-0000-000000000000" = {
      "Audit-TrustedLaunch" = "Audit"
    }
    "/providers/Microsoft.Management/managementGroups/corp" = {
      "Deploy-Sql-Security" = "DeployIfNotExists"
    }
  }


}
