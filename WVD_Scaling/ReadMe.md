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
  3. Run the automation account script to create the automation account. 
     * `.\createazureautomationaccount.ps1`