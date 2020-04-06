 # Automation Account Builder
 This will create an automation account for both WVD scaling and groupSync

  1. Log into azure
    ```PowerShell
     Login-Azaccount
     ```
  1. Run the following script to download the the automation account builder script
    ```powershell
    Set-Location -Path "c:\temp"
    $uri = "https://raw.githubusercontent.com/Auburn-OIT-Cloud/WVD_Resources/master/AutomationAccountBuilder/createazureautomationaccount.ps1"
    Invoke-WebRequest -Uri $uri -OutFile ".\createazureautomationaccount.ps1"
    ```
  1. 
