This GroupSync script will create the logic app that keeps a AzureAd group and a WVD App group in sync. Prerequisites Are
- Azure Automation Account with the AzureAutomationGroupSyncScript.ps1 deployed as a runbook.
- The automation account needs a runas account that has contributor rights on your WVD Tenant. 
- Automation Account Webhook.
### Powershell Modules 
  * Azure powershell module `Install-Module -Name Az -AllowClobber`
  * Windows Virtural Desktop Powershell module installed `Install-Module -Name Microsoft.RDInfra.RDPowerShell`    
### Examples

```powershell
.\BuildLogicApp.ps1 -adGroupName "AdGroup" `
 -wvdTenantName "TenantName" `
 -wvdHostPoolName "Hostpoolname" `
 -wvdAppGroupName "AppGroupName" `
 -SubscriptionId "Subscription ID" `
 -ResourcegroupName "Resource Group Name" `
 -WebhookURI "Automation Account Webhook" `
 -RecurrenceInterval "Recurrence in minutes"
 ```
