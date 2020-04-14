param(
	[Parameter(mandatory = $false)]
	[object]$WebHookData
)
# If runbook was called from Webhook, WebhookData will not be null.
if ($WebHookData) {

	# Collect properties of WebhookData
	$WebhookName = $WebHookData.WebhookName
	$WebhookHeaders = $WebHookData.RequestHeader
	$WebhookBody = $WebHookData.RequestBody

	# Collect individual headers. Input converted from JSON.
	$From = $WebhookHeaders.From
	$Input = (ConvertFrom-Json -InputObject $WebhookBody)
}
else
{
	Write-Error -Message 'Runbook was not started from Webhook' -ErrorAction stop
}

$adGroupName = $input.adGroupName
$wvdTenantName = $Input.wvdTenantName
$wvdHostPoolName = $Input.wvdHostPoolName
$wvdAppGroupName = $Input.wvdAppGroupName

import-module -name azuread
$RDBrokerURL = "https://rdbroker.wvd.microsoft.com"
$AadTenantId = "Tenant Id here"
$connectionName = "AzureRunAsConnection"
$servicePrincipalConnection = Get-AutomationConnection -Name $connectionName         
Connect-AzureAD -TenantId $servicePrincipalConnection.TenantId `
    -ApplicationId $servicePrincipalConnection.ApplicationId `
    -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint
Add-RdsAccount -DeploymentUrl $RDBrokerURL -ApplicationId $ServicePrincipalConnection.ApplicationId -CertificateThumbprint $ServicePrincipalConnection.CertificateThumbprint -AADTenantId $AadTenantId
# Create user list and target list array
$adGroupUsers = @()
$appGroupUsers = @()

#Gets the object id of the azure ad group
$obid = (get-azureadgroup -filter "displayname eq '$adgroupname'").objectid


# Get the list of AD Group and WVD App Group users
$adgroupusers = (Get-AzureADGroupMember -objectid $obid -all | select-object userprincipalname).userPrincipalName
$appGroupUsers = (Get-RdsAppGroupUser -TenantName $wvdTenantName -HostPoolName $wvdHostPoolName -AppGroupName $wvdAppGroupName).UserPrincipalName
# Logic to check if source users are part of the target group, add them if not
foreach ($adGroupUser in $adGroupUsers) {
    # If user is in the AD Group and the App group, do nothing
    if ($appGroupUsers -contains $adGroupUser) {
        Write-Host ("$adGroupUser was found in the targetUsers list")
    }
    # If user is in the AD Group and not in the WVD App Group, add them
    elseif ($appGroupUsers -notcontains $adGroupUser) {
        try {
            Add-RdsAppGroupUser -ErrorAction Stop -TenantName $wvdTenantName -HostPoolName $wvdHostPoolName -AppGroupName $wvdAppGroupName -UserPrincipalName $adGroupUser
            Write-Host ("$adGroupUser not found in $wvdAppGroupName, adding to App Group $wvdAppGroupName")
        }
        Catch {
            $ErrorMessage = $_.Exception.message
            Write-Host ("Error adding user $adGroupUser to the target group. Message:" + $ErrorMessage)
        }
    }
}
