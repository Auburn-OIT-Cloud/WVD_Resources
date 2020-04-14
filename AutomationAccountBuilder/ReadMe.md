 # Automation Account Builder
 This will create an automation account with two runbooks for WVD scaling and groupSync.
 ### Prerequisites 
    1. Azure powershell module installed
 ### How to deploy    
  1. Log into azure powershell. 
     * `Login-Azaccount`
  2. Run the following script to download the the automation account builder script
     * `Set-Location -Path "c:\temp"`
     * `$uri = "https://raw.githubusercontent.com/Auburn-OIT-      Cloud/WVD_Resources/master/AutomationAccountBuilder/createazureautomationaccount.ps1"` 
     * `Invoke-WebRequest -Uri $uri -OutFile ".\createazureautomationaccount.ps1"`
  3. Run the automation account script to create the automation account. 
     * `.\createazureautomationaccount.ps1 -SubscriptionID <azuresubscriptionid> -ResourceGroupName <resourcegroupname> -AutomationAccountName <name of automation account> -Location "Azure region for deployment"`
  4. When this script complete's it will print out two Webhook URI's copy these down you will need them when creating the logic apps for scaling and groupsync. 
