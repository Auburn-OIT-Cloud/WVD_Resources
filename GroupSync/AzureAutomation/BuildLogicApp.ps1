<#
.SYNOPSIS
	This is a sample script for to deploy the required resources for to schedule basic scale in Microsoft Azure.
.DESCRIPTION
	This sample script will create the scale script execution trigger required resources in Microsoft Azure. Resources are azure logic app for each hostpool.
    Run this PowerShell script in adminstrator mode
    This script depends on Az PowerShell module. To install Az module execute the following command. Use "-AllowClobber" parameter if you have more than one version of PowerShell modules installed.
	
    PS C:\>Install-Module Az  -AllowClobber
    
.PARAMETER adGroupName
 Required
.PARAMETER wvdTenantName
 Required
.PARAMETER wvdHostPoolName
 Required
.PARAMETER wvdAppGroupName
 Required
.PARAMETER SubscriptionId
 Required
.PARAMETER ResourcegroupName
 Required
 .PARAMETER RecurrenceInterval
 Required
.PARAMETER WebhookURI
 Required
 Provide URI of the azure automation account webhook
#>
param(
	[Parameter(mandatory = $True)]
	[string]$adGroupName,

	[Parameter(mandatory = $True)]
	[string]$wvdTenantName,

	[Parameter(mandatory = $True)]
	[string]$wvdHostPoolName,

	[Parameter(mandatory = $True)]
    [string]$wvdAppGroupName,
    
    [Parameter(mandatory = $True)]
	[string]$SubscriptionId,

    [Parameter(mandatory = $True)]
	[string]$ResourcegroupName,

    [Parameter(mandatory = $True)]
    [string]$WebhookURI,
    
    [Parameter(mandatory = $True)]
	[int]$RecurrenceInterval



)

#Initializing variables
$RDBrokerURL = "https://rdbroker.wvd.microsoft.com"
$ScriptRepoLocation = "https://raw.githubusercontent.com/Auburn-OIT-Cloud/RDS-Templates/master/GroupSync/AzureAutomation/"
$Location = "East Us"
# Setting ErrorActionPreference to stop script execution when error occurs
$ErrorActionPreference = "Stop"

# Set the ExecutionPolicy
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser -Force -Confirm:$false

# Import Az and AzureAD modules
Import-Module Az.LogicApp
Import-Module Az.Resources
Import-Module Az.Accounts

# Get the context
$Context = Get-AzContext
if ($Context -eq $null)
{
	Write-Error "Please authenticate to Azure using Login-AzAccount cmdlet and then run this script"
	exit
}


#Get the WVD context
$WVDContext = Get-RdsContext -DeploymentUrl $RDBrokerURL
if ($Context -eq $null)
{
	Write-Error "Please authenticate to WVD using Add-RDSAccount -DeploymentURL 'https://rdbroker.wvd.microsoft.com' cmdlet and then run this script"
	exit
}

# Select the subscription
$Subscription = Select-azSubscription -SubscriptionId $SubscriptionId
Set-AzContext -SubscriptionObject $Subscription.ExtendedProperties

# Get the Role Assignment of the authenticated user
$RoleAssignment = (Get-AzRoleAssignment -SignInName $Context.Account)

if ($RoleAssignment.RoleDefinitionName -eq "Owner" -or $RoleAssignment.RoleDefinitionName -eq "Contributor")
{

	# Check if the automation account exist in your Azure subscription
	$CheckRG = Get-AzResourceGroup -Name $ResourcegroupName -Location $Location -ErrorAction SilentlyContinue
	if (!$CheckRG) {
		Write-Output "The specified resourcegroup does not exist, creating the resourcegroup $ResourcegroupName"
		New-AzResourceGroup -Name $ResourcegroupName -Location $Location -Force
		Write-Output "ResourceGroup $ResourcegroupName created suceessfully"
	}

	#Creating Azure logic app to schedule job

		$RequestBody = @{
			"adGroupName" = $adGroupName;
			"wvdAppGroupName" = $wvdAppGroupName;
			"wvdHostPoolName" = $wvdHostPoolName;
            "wvdTenantName" = $wvdTenantName;
                    }
		$RequestBodyJson = $RequestBody | ConvertTo-Json
		$LogicAppName = ($wvdAppGroupName + "_" + "Group" + "_" + "Sync").Replace(" ","")
		$SchedulerDeployment = New-AzResourceGroupDeployment -ResourceGroupName $ResourceGroupName -TemplateUri "$ScriptRepoLocation/GroupSyncLogicAppTemplate.json" -logicappname $LogicAppName -webhookURI $WebhookURI.Replace("`n","").Replace("`r","") -actionSettingsBody $RequestBodyJson -recurrenceInterval $RecurrenceInterval -Verbose
		if ($SchedulerDeployment.ProvisioningState -eq "Succeeded") {
			Write-Output "$wvdAppGroupName Group Sync has been created"
		}

}
else
{
	Write-Output "Authenticated user should have the Owner/Contributor permissions"
}
