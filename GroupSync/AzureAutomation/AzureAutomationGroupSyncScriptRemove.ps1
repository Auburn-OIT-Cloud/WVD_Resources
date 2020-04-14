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
$AadTenantId = "Enter Tenant ID"
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
$adgroupusers = (Get-AzureADGroupMember -objectid $obid -All | select-object userprincipalname).userPrincipalName
$appGroupUsers = (Get-RdsAppGroupUser -TenantName $wvdTenantName -HostPoolName $wvdHostPoolName -AppGroupName $wvdAppGroupName).UserPrincipalName
# Logic to check if source users are part of the target group, add them if not
foreach ($adGroupUser in $adGroupUsers) {
    # If user is in the AD Group and the App group, do nothing
    if ($appGroupUsers -contains $adGroupUsers) {
        Write-Host ("$adGroupUsers was found in the targetUsers list")
    }
    # If user is in the AD Group and not in the WVD App Group, add them
    elseif ($appGroupUsers -notcontains $adGroupUsers) {
        try {
            Add-RdsAppGroupUser -ErrorAction Stop -TenantName $wvdTenantName -HostPoolName $wvdHostPoolName -AppGroupName $wvdAppGroupName -UserPrincipalName $adGroupUsers
            Write-Host ("$adGroupUsers not found in $wvdAppGroupName, adding to App Group $wvdAppGroupName")
        }
        Catch {
            $ErrorMessage = $_.Exception.message
            Write-Host ("Error adding user $adGroupUsers to the target group. Message:" + $ErrorMessage)
        }
    }
}
foreach ($appGroupUsers in $appGroupUsers) {

    # If ths users are in the WVD App Group, but not in the AD Group, remove them from the App Group

    if (($adGroupUsers) -notcontains $appGroupUsers) {
        try {
            Remove-RdsAppGroupUser -ErrorAction Stop -TenantName $wvdTenantName -HostPoolName $wvdHostPoolName -AppGroupName $wvdAppGroupName -UserPrincipalName $appGroupUsers
            Write-Host ("$appGroupUsers was not found in AD Group $adGroupName, removed from $wvdAppGroupName")
        }
        catch {
            $ErrorMessage = $_.Exception.message
            Write-Host ("Error removing $appGroupUsers from $targetGroup Message:" + $ErrorMessage)
        }

    }

} 
