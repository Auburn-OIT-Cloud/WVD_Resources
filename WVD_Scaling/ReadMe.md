 # Automation Account Builder
 This will create an automation account with a runbook for WVD scaling.
 ### Prerequisites 
    1. Azure powershell module installed
 ### How to deploy    
  1. Log into azure powershell. 
     * `Login-Azaccount`
  2. Run the following script to download the the automation account builder script
     * `Set-Location -Path "c:\temp"`
     * `$uri = "https://raw.githubusercontent.com/Auburn-OIT-Cloud/WVD_Resources/master/WVD_Scaling/CreateOrUpdateAzAutoAccount.ps1"` 
     * `Invoke-WebRequest -Uri $uri -OutFile ".\CreateOrUpdateAzAutoAccount.ps1"`
  3. Run the automation account script to create the automation account 
     * `$Params = @{
     "AADTenantId"           = "<Azure_Active_Directory_tenant_ID>"   # Optional. If not specified, it will use the current Azure context
     "SubscriptionId"        = "<Azure_subscription_ID>"              # Optional. If not specified, it will use the current Azure context
     "UseARMAPI"             = $true
     "ResourceGroupName"     = "<Resource_group_name>"                # Optional. Default: "WVDAutoScaleResourceGroup"
     "AutomationAccountName" = "<Automation_account_name>"            # Optional. Default: "WVDAutoScaleAutomationAccount"
     "Location"              = "<Azure_region_for_deployment>"
     "WorkspaceName"         = "<Log_analytics_workspace_name>"       # Optional. If specified, Log Analytics will be used to configure the custom log table that the runbook PowerShell script can send logs to
   }
   .\CreateOrUpdateAzAutoAccount.ps1 @Params`
   