Begin {
    $DeploymentURL = "https://rdbroker.wvd.microsoft.com" 
    $tenantselection = ""
    $global:FileBrowser = "no worky"
    $global:csv = "No CSV"
    $global:appselection = "NoApp"
    $global:SelectedTenant = "None"
    $global:SelectedHostPool = "None"
    $global:SelectedAppPool = "None"
  
$rdsContext = get-rdscontext -ErrorAction SilentlyContinue
if ($rdsContext -eq $null) {
    try {
        Write-host "Use the login window to connect to WVD" -ForegroundColor Red
        Add-RdsAccount -ErrorAction Stop -DeploymentUrl "https://rdbroker.wvd.microsoft.com"
    }
    catch {
        $ErrorMessage = $_.Exception.message
        write-host ('Error logging into the WVD account ' + $ErrorMessage)
        exit
    }
}

    #Check if there is a valid connection to Azure RDS service
    function checkconnection {  
        Try {
            $RDSContext = Get-RdsContext -ErrorAction Stop

        }
        
        Catch  
        {        
                
            Update-Log "You must add your rds account to the powershell session before you can use this app"
            
        }
    }
#Log function 
    function Update-Log {
        param(
            [string] $Message,

            [string] $Color = 'orange',

            [switch] $NoNewLine
        )

        $LogTextBox.SelectionColor = $Color
        $LogTextBox.AppendText("$Message")
        if (-not $NoNewLine) { $LogTextBox.AppendText("`n") }
        $LogTextBox.Update()
        $LogTextBox.ScrollToCaret()
    }
    #Add the rds user that is in the username text box 
    function addrdsuser {
        $user = $NewUserNamebox_UsersTabPage.text
        Add-RdsAppGroupUser -TenantName $global:SelectedTenant -HostPoolName $global:SelectedHostPool -AppGroupName $global:SelectedAppPool -UserPrincipalName $NewUserNamebox_UsersTabPage.text       
        Update-Log "$user Has been added to the user group for $global:SelectedAppPool"
        Update-Log "------------------------------------------------"
    }
    #list the informaiton in the selected csv
    function listcsvusers {
        if ($global:csv = "NO CSV") {
            Update-Log "No CSV is selected.... Please select a CSV...." -Color "Red"
            
        }
        else {
            foreach ($line in $global:csv) {
                $Username = $line.name
                Update-Log "$username has been added to the app group"    
            }
        
        }
    }
    function addcsvusers {
        
        if ($global:FileBrowser -eq "no worky") {
            Update-Log "There is no CSV file selected...Please Select one...." -Color 'red'
        }
        else {
            foreach ($line in $global:csv) {
                $Username = $line.name
                Add-RdsAppGroupUser -TenantName $TenantNamebox.text -HostPoolName $HostNamebox.text -AppGroupName $AppGroupNamebox.text -UserPrincipalName $Username  
                Update-Log "'$username' Has been added to the user group for '$AppGroupNamebox.text'"
    
            }     
        
        }
        
    }
    function listappgroupusers {
        if ($AppGroupNamebox.text -eq "AppPool Name") {
            Update-Log "No App Group Selected...please Select an App Group..." -Color 'red'
        }
        elseif ($OutViewcheckbox.Checked -eq $true) { 
        Get-RdsAppGroupUser -TenantName $global:SelectedTenant -HostPoolName $global:SelectedHostPool -AppGroupName $global:SelectedAppPool | select UserPrincipalName, AppGroupName | Out-GridView -Title "App Group Users" -OutputMode Single
        }
        elseif ($CSVoutputcheckbox.Checked -eq $true) {
            $Csvoutputlocation = $CsvOutputTextBox.text
            Get-RdsAppGroupUser -TenantName $global:SelectedTenant -HostPoolName $global:SelectedHostPool -AppGroupName $global:SelectedAppPool | select UserPrincipalName, AppGroupName | Export-Csv "$Csvoutputlocation\AppGroupUsers.csv"
            Update-Log "A copy of the user have been saved to $csvOutputTextBox.text\AppGroupUsers.csv"

        }
        else {
            $testpeoeple = Get-RdsAppGroupUser -TenantName $global:SelectedTenant -HostPoolName $global:SelectedHostPool -AppGroupName $global:SelectedAppPool | select UserPrincipalName, AppGroupName
            $testpeoeple | ForEach-Object {
                Update-Log $_.UserPrincipalName
                Update-Log "------------------------------------------------"

            }
        }
    }
    function SelectApps {
        if ($AppGroupNamebox.text -eq "AppPool Name") {
            Update-Log "No App Group Selected...please Select an App Group..." -Color 'red'
        }
        else {
            $global:appselection = Get-RdsStartMenuApp -TenantName $global:SelectedTenant -HostPoolName $global:SelectedHostPool -AppGroupName $global:SelectedAppPool | select FriendlyName, AppAlias, AppGroupName | Out-GridView -Title "Please choose an app to publish..." -OutputMode Single
        }
    }
    function publishapp {
        if ($AppSelectionBox_AddTabPage.text -eq "App Name") {
            Update-Log "No app selected...Please Select an app...."
            
        }
        else {
            New-RdsRemoteApp -TenantName $global:SelectedTenant -HostPoolName $global:SelectedHostPool -AppGroupName $global:SelectedAppPool -Name $global:appselection.Friendlyname -AppAlias $global:appselection.AppAlias
            Update-Log "$global:appselection.FriendlyName Has been published to your App Group"
        }
    }
    function AddAppGroup {
        $NewRdsAppGroup = $NewAppGroupBox_AddTabPage.text
        New-RdsAppGroup -TenantName $global:SelectedTenant -HostPoolName $global:SelectedHostPool -Name $NewRdsAppGroup -ResourceType RemoteApp
        Update-Log "$NewRdsAppGroup Has been created as an RemoteApp group"
        Update-Log "------------------------------------------------"
        
    }
    function GetPublishedApps {
        if ($HostNamebox.text -eq "Host Pool") {
            Update-Log "No Host Pool selected....Please Select a Host Pool..." -Color "Red"
        }
        elseif ($global:SelectedAppPool -eq "Desktop Application Group") {
            Update-Log "This is a desktop app pool...There are no published apps in this pool"
            Update-Log "------------------------------------------------"

        }
        elseif ($outviewcheckbox.checkeboxd -eq $true) {
            Get-RdsRemoteApp -TenantName $global:SelectedTenant -HostPoolName $global:SelectedHostPool -AppGroupName $global:SelectedAppPool | Out-GridView -OutputMode Single           
        }
        elseif ($csvoutputcheckbox.checked -eq $true) {
            $Csvoutputlocation = $CsvOutputTextBox.text
            Get-RdsRemoteApp -TenantName $global:SelectedTenant -HostPoolName $global:SelectedHostPool -AppGroupName $global:SelectedAppPool | select RemoteAppName,FriendlyName,FilePath,ShowInWebFeed | Export-Csv "$Csvoutputlocation\PublishedApps.csv"           
        }        
        else {
            Update-Log "No output methood slected...Please Select an output methood..." -Color "Red"
        }
    }
    function ChangeHostPool {
        if ($global:SelectedTenant -eq "none") {
            Update-Log "No tenant Selected...Please Select a tenant"
            
        }
        elseif ($global:SelectedHostPool -eq "none") {
            Update-Log "No HostPool Selected...Please Select a hostpool"
            
        }
        else {
            $global:SelectedAppPool = Get-RdsAppGroup -TenantName $global:SelectedTenant -HostPoolName $global:SelectedHostPool | Select-Object FriendlyName,AppGroupName,ResourceType | Out-GridView -Title "Please choose your AppGroup..." -OutputMode Single
            $AppGroupNamebox.text = $global:SelectedAppPool.appgroupname


        }
        
    }
    function RemoveAppGroupUser {
        $RemoveUser = Get-RdsAppGroupUser -TenantName $global:SelectedTenant -HostPoolName $global:SelectedHostPool -AppGroupName $global:SelectedAppPool | select UserPrincipalName, AppGroupName | Out-GridView -Title "App Group Users" -OutputMode Single
        Remove-RdsAppGroupUser -TenantName $global:SelectedTenant -HostPoolName $global:SelectedHostPool -AppGroupName $global:SelectedAppPool -UserPrincipalName $RemoveUser.UserPrincipalName
        $RemoveUserusername = $RemoveUser.userprincipalname
        Update-Log "$removeuserusername Has been removed from $global:SelectedAppPool"
        Update-Log "------------------------------------------------"
        
    }
    function viewsessionhosts {
        get-rdssessionhost -TenantName $global:selectedTenant -HostPoolName $global:selectedhostpool | select SessionHostName,AllowNewSession,sessions,status | Out-GridView
    }
    function viewusersessions {
        get-rdsusersession -TenantName $global:SelectedTenant -HostPoolName $global:SelectedHostPool | select UserPrincipalName,SessionHostName,sessionstate | Out-GridView
    }
} 
process {



    Add-Type -Assembly System.Windows.Forms
    $main_form = New-Object System.Windows.Forms.Form
    $main_form.text = 'WVD Manager'
    $main_form.Width = 1000
    $main_form.Height = 800
    $main_form.Autosize = 800
    $main_form.Font = New-Object System.Drawing.Font("Segoe UI",13,[System.Drawing.FontStyle]::Regular,[System.Drawing.GraphicsUnit]::Pixel)


    $TabControl = New-object System.Windows.Forms.TabControl
    $TabControl.DataBindings.DefaultDataSourceUpdateMode = 0
    $TabControl.Location = New-Object System.Drawing.Size(10, 230)
    $TabControl.Size = New-Object System.Drawing.Size(550, 530)
    $main_Form.Controls.Add($TabControl)

    $TenantNameLable = New-Object System.Windows.Forms.Label
    $TenantNameLable.Text = "Tenant Name"
    $TenantNameLable.AutoSize = $true
    $TenantNameLable.Location = New-Object System.Drawing.Point(15, 45)
    $main_form.Controls.Add($TenantNameLable)

    $TenantNamebox = New-Object System.Windows.Forms.textbox 
    $TenantNamebox.text = $tenantselection.tenantname
    $TenantNamebox.Enabled = $false
    $TenantNameBox.Size = New-Object System.Drawing.Size(150, 15)
    $TenantNamebox.Location = New-Object System.Drawing.Point(15, 70)
    $main_form.Controls.Add($TenantNamebox)

    $HostPoolNameLable = New-Object System.Windows.Forms.Label
    $HostPoolNameLable.Text = "HostPool Name"
    $HostPoolNameLable.AutoSize = $true
    $HostPoolNameLable.Location = New-Object System.Drawing.Point(185, 45)
    $main_form.Controls.Add($HostPoolNameLable)

    $HostNamebox = New-Object System.Windows.Forms.textbox 
    $HostNamebox.text = "Host Pool"
    $HostNamebox.Enabled = $false
    $HostNameBox.Size = New-Object System.Drawing.Size(150, 15)
    $HostNamebox.Location = New-Object System.Drawing.Point(185, 70)
    $main_form.Controls.Add($HostNamebox)

    $AppPoolNameLable = New-Object System.Windows.Forms.Label
    $AppPoolNameLable.Text = "AppPool Name"
    $AppPoolNameLable.AutoSize = $true
    $AppPoolNameLable.Location = New-Object System.Drawing.Point(345, 45)
    $main_form.Controls.Add($AppPoolNameLable)

    $AppGroupNamebox = New-Object System.Windows.Forms.textbox 
    $AppGroupNamebox.text = "AppPool Name"
    $AppGroupNamebox.Enabled = $false
    $AppGroupNameBox.Size = New-Object System.Drawing.Size(150, 15)
    $AppGroupNamebox.Location = New-Object System.Drawing.Point(345, 70)
    $main_form.Controls.Add($AppGroupNamebox)

    $AppPoolSelectButton = New-Object System.Windows.Forms.Button
    $AppPoolSelectButton.Location = New-Object System.Drawing.Size(345, 100)
    $AppPoolSelectButton.Size = New-Object System.Drawing.Size(160, 20)
    $AppPoolSelectButton.Text = 'Change App Pool'
    $AppPoolSelectButton.Add_Click({
        ChangeHostPool
        })
    $main_form.Controls.Add($AppPoolSelectButton)

    $TestConnectionButton = New-Object System.Windows.Forms.Button
    $TestConnectionButton.Location = New-Object System.Drawing.Size(15, 125)
    $TestConnectionButton.Size = New-Object System.Drawing.Size(500, 20)
    $TestConnectionButton.Text = 'Context Selection'
    $TestConnectionButton.Add_Click( {
            checkconnection
            $tenantselection = get-rdstenant | Select-Object friendlyname,TenantName,Description | Out-GridView -Title "Please choose your Tenant..." -OutputMode Single        
            $TenantNamebox.text = $tenantselection.tenantname
            $global:SelectedTenant = $tenantselection.tenantname

            $hostpoolselection = Get-Rdshostpool -TenantName $global:SelectedTenant | Select-Object FriendlyName,HostPoolName,Persistent | Out-GridView -Title "Please choose your Hostpool..." -OutputMode Single
            $HostNamebox.text = $hostpoolselection.hostpoolname 
            $global:SelectedHostPool = $hostpoolselection.hostpoolname

            $appgroupselection = Get-RdsAppGroup -TenantName $global:SelectedTenant -HostPoolName $global:SelectedHostPool | Select-Object FriendlyName,AppGroupName,ResourceType | Out-GridView -Title "Please choose your AppGroup..." -OutputMode Single
            $AppGroupNamebox.text = $appgroupselection.appgroupname
            $global:SelectedAppPool = $appgroupselection.appgroupname

        })
    $main_form.Controls.Add($TestConnectionButton)

    $SelectionInformaitonBox = New-Object System.Windows.Forms.GroupBox
    $SelectionInformaitonBox.Location = New-Object System.Drawing.Size(10, 10)
    $SelectionInformaitonBox.Size = New-Object System.Drawing.Size(550, 145)
    $SelectionInformaitonBox.Text = 'Selection Informaiton'
    $main_form.Controls.Add($SelectionInformaitonBox) 

    $OutViewcheckbox = New-Object System.Windows.Forms.CheckBox
    $OutViewcheckbox.Text = 'Grid List Output'
    $OutViewcheckbox.Enabled = $true
    $OutViewcheckbox.Location = New-Object System.Drawing.Size(15, 165)
    $OutViewcheckbox.Size = New-Object System.Drawing.Size(200, 25)
    $OutViewcheckbox.Checked = $true
    $main_form.Controls.Add($OutViewcheckbox)

    $CSVoutputcheckbox = New-Object System.Windows.Forms.CheckBox
    $CSVoutputcheckbox.Text = 'CSV List Output'
    $CSVoutputcheckbox.Enabled = $true
    $CSVoutputcheckbox.Location = New-Object System.Drawing.Size(15, 195)
    $CSVoutputcheckbox.Size = New-Object System.Drawing.Size(150, 25)
    $CSVoutputcheckbox.Checked = $false
    $main_form.Controls.Add($CSVoutputcheckbox)

    $CsvOutputLable = New-Object System.Windows.Forms.Label
    $CsvOutputLable.Text = "Csv Output Location"
    $CsvOutputLable.AutoSize =$true
    $CsvOutputLable.Location = New-Object System.Drawing.Point(225,165)
    $main_form.Controls.Add($CsvOutputLable)

    $CsvOutputTextBox = New-Object System.Windows.Forms.textbox 
    $CsvOutputTextBox.text = "$env:USERPROFILE\desktop"
    $CsvOutputTextBox.Enabled = $true
    $CsvOutputTextBox.Size = New-Object System.Drawing.Size(265,15)
    $CsvOutputTextBox.Location = New-Object System.Drawing.Point(205,195)
    $main_form.Controls.Add($CsvOutputTextBox)

    $UsersTabPage = New-Object System.Windows.Forms.TabPage
    $UsersTabPage.UseVisualStyleBackColor = $true
    $UsersTabPage.Text = 'User Management'
    $TabControl.Controls.Add($UsersTabPage)

    $NewUserNameLable_UsersTabPage = New-Object System.Windows.Forms.Label
    $NewUserNameLable_UsersTabPage.Text = "Single Username"
    $NewUserNameLable_UsersTabPage.AutoSize = $true
    $NewUserNameLable_UsersTabPage.Location = New-Object System.Drawing.Point(15, 42)
    $UsersTabPage.Controls.Add($NewUserNameLable_UsersTabPage)

    $NewUserNamebox_UsersTabPage = New-Object System.Windows.Forms.textbox 
    $NewUserNamebox_UsersTabPage.text = "Username"
    $NewUserNamebox_UsersTabPage.Size = New-Object System.Drawing.Size(150, 15)
    $NewUserNamebox_UsersTabPage.Location = New-Object System.Drawing.Point(15, 70)
    $UsersTabPage.Controls.Add($NewUserNamebox_UsersTabPage)

    $File_UsersTabPage = New-Object System.Windows.Forms.textbox 
    $File_UsersTabPage.text = "csv info"
    $File_UsersTabPage.Enabled = $false
    $File_UsersTabPage.Size = New-Object System.Drawing.Size(300, 15)
    $File_UsersTabPage.Location = New-Object System.Drawing.Point(200, 70)
    $UsersTabPage.Controls.Add($File_UsersTabPage)

    $UserNameFileSelectButton_UsersTabPage = New-Object System.Windows.Forms.Button
    $UserNameFileSelectButton_UsersTabPage.Location = New-Object System.Drawing.Size(200, 40)
    $UserNameFileSelectButton_UsersTabPage.Size = New-Object System.Drawing.Size(200, 20)
    $UserNameFileSelectButton_UsersTabPage.Text = 'CSV Selection'
    $UserNameFileSelectButton_UsersTabPage.Add_Click( {
            $global:FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{ InitialDirectory = [Environment]::GetFolderPath('Desktop') }
            $null = $FileBrowser.ShowDialog()
            $global:csv = Import-Csv $FileBrowser.FileName -Header @("Name")
            $File_UsersTabPage.text = $FileBrowser.FileName

        })
    $UsersTabPage.Controls.Add($UserNameFileSelectButton_UsersTabPage)

    
    $AddAppGroupUserButton_UsersTabPage = New-Object System.Windows.Forms.Button
    $AddAppGroupUserButton_UsersTabPage.Location = New-Object System.Drawing.Size(10, 120)
    $AddAppGroupUserButton_UsersTabPage.Size = New-Object System.Drawing.Size(200, 20)
    $AddAppGroupUserButton_UsersTabPage.Text = 'Add App Group User'
    $AddAppGroupUserButton_UsersTabPage.Add_Click( {
        addrdsuser
        })
    $UsersTabPage.Controls.Add($AddAppGroupUserButton_UsersTabPage)

    $RemoveAppGroupUserButton_UsersTabPage = New-Object System.Windows.Forms.Button
    $RemoveAppGroupUserButton_UsersTabPage.Location = New-Object System.Drawing.Size(250, 120)
    $RemoveAppGroupUserButton_UsersTabPage.Size = New-Object System.Drawing.Size(200, 20)
    $RemoveAppGroupUserButton_UsersTabPage.Text = 'Remove App Group User'
    $RemoveAppGroupUserButton_UsersTabPage.Add_Click( {
            RemoveAppGroupUser
        })
    $UsersTabPage.Controls.Add($RemoveAppGroupUserButton_UsersTabPage)

    $UsernamesgroupBox_UsersTabPage = New-Object System.Windows.Forms.GroupBox
    $UsernamesgroupBox_UsersTabPage.Location = New-Object System.Drawing.Size(10, 7)
    $UsernamesgroupBox_UsersTabPage.Size = New-Object System.Drawing.Size(520, 90)
    $UsernamesgroupBox_UsersTabPage.Text = 'User Informaiton'
    $UsersTabPage.Controls.Add($UsernamesgroupBox_UsersTabPage) 
 
    $AddCsvUsersButton_UsersTabPage = New-Object System.Windows.Forms.Button
    $AddCsvUsersButton_UsersTabPage.Location = New-Object System.Drawing.Size(10, 155)
    $AddCsvUsersButton_UsersTabPage.Size = New-Object System.Drawing.Size(200, 20)
    $AddCsvUsersButton_UsersTabPage.Text = 'Add Csv App Group Users'
    $AddCsvUsersButton_UsersTabPage.Add_Click( {
            addcsvusers
        })
    $UsersTabPage.Controls.Add($AddCsvUsersButton_UsersTabPage)

    $Listcsvdatabutton_UsersTabPage = New-Object System.Windows.Forms.Button
    $Listcsvdatabutton_UsersTabPage.Location = New-Object System.Drawing.Size(10, 300)
    $Listcsvdatabutton_UsersTabPage.Size = New-Object System.Drawing.Size(200, 20)
    $Listcsvdatabutton_UsersTabPage.Text = 'List CSV Data'
    $Listcsvdatabutton_UsersTabPage.Add_Click( {
            listcsvusers
        })
    $UsersTabPage.Controls.Add($Listcsvdatabutton_UsersTabPage)

    $AddCsvUsersButton_UsersTabPage = New-Object System.Windows.Forms.Button

    $ListAppUsersButton_UsersTabPage = New-Object System.Windows.Forms.Button
    $ListAppUsersButton_UsersTabPage.Location = New-Object System.Drawing.Size(10, 350)
    $ListAppUsersButton_UsersTabPage.Size = New-Object System.Drawing.Size(200, 20)
    $ListAppUsersButton_UsersTabPage.Text = 'List App Group Users'
    $ListAppUsersButton_UsersTabPage.Add_Click( {
            listappgroupusers
        })
    $UsersTabPage.Controls.Add($ListAppUsersButton_UsersTabPage)

    $ListAppUsersButton_UsersTabPage = New-Object System.Windows.Forms.Button
    $ListAppUsersButton_UsersTabPage.Location = New-Object System.Drawing.Size(250, 300)
    $ListAppUsersButton_UsersTabPage.Size = New-Object System.Drawing.Size(200, 20)
    $ListAppUsersButton_UsersTabPage.Text = 'View Session Hosts'
    $ListAppUsersButton_UsersTabPage.Add_Click( {
        viewsessionhosts
        })

    $UsersTabPage.Controls.Add($ListAppUsersButton_UsersTabPage)
    $ListAppUsersButton_UsersTabPage = New-Object System.Windows.Forms.Button
    $ListAppUsersButton_UsersTabPage.Location = New-Object System.Drawing.Size(250, 350)
    $ListAppUsersButton_UsersTabPage.Size = New-Object System.Drawing.Size(200, 20)
    $ListAppUsersButton_UsersTabPage.Text = 'View User Sessions'
    $ListAppUsersButton_UsersTabPage.Add_Click( {
        viewusersessions
        })
    $UsersTabPage.Controls.Add($ListAppUsersButton_UsersTabPage)


    $AddTabPage = New-Object System.Windows.Forms.TabPage
    $AddTabPage.UseVisualStyleBackColor = $true
    $AddTabPage.Text = 'Add Resources'
    $TabControl.Controls.Add($AddTabPage)

    $AddPublishedAppsButton_AddTabPage = New-Object System.Windows.Forms.Button
    $AddPublishedAppsButton_AddTabPage.Location = New-Object System.Drawing.Size(10, 45)
    $AddPublishedAppsButton_AddTabPage.Size = New-Object System.Drawing.Size(200, 20)
    $AddPublishedAppsButton_AddTabPage.Text = 'Select Apps to Publish'
    $AddPublishedAppsButton_AddTabPage.Add_Click( {
            SelectApps
            $AppSelectionBox_AddTabPage.text = $global:appselection.FriendlyName
        })
    $AddTabPage.Controls.Add($AddPublishedAppsButton_AddTabPage)

    $PublishAppsButton_AddTabPage = New-Object System.Windows.Forms.Button
    $PublishAppsButton_AddTabPage.Location = New-Object System.Drawing.Size(10, 80)
    $PublishAppsButton_AddTabPage.Size = New-Object System.Drawing.Size(200, 20)
    $PublishAppsButton_AddTabPage.Text = 'Publish the app'
    $PublishAppsButton_AddTabPage.Add_Click( {
            publishapp
        })
    $AddTabPage.Controls.Add($PublishAppsButton_AddTabPage)
    

    $AppSelectionBox_AddTabPage = New-Object System.Windows.Forms.textbox 
    $AppSelectionBox_AddTabPage.text = "App Name"
    $AppSelectionBox_AddTabPage.Enabled = $false
    $AppSelectionBox_AddTabPage.Size = New-Object System.Drawing.Size(200, 15)
    $AppSelectionBox_AddTabPage.Location = New-Object System.Drawing.Point(10, 20)
    $AddTabPage.Controls.Add($AppSelectionBox_AddTabPage)

    $NewAppGroupBox_AddTabPage = New-Object System.Windows.Forms.textbox 
    $NewAppGroupBox_AddTabPage.text = "New App group name"
    $NewAppGroupBox_AddTabPage.Enabled = $true
    $NewAppGroupBox_AddTabPage.Size = New-Object System.Drawing.Size(200, 15)
    $NewAppGroupBox_AddTabPage.Location = New-Object System.Drawing.Point(260, 20)
    $AddTabPage.Controls.Add($NewAppGroupBox_AddTabPage)

    $AddAppGroupButton_ADDTabPage = New-Object System.Windows.Forms.Button
    $AddAppGroupButton_ADDTabPage.Location = New-Object System.Drawing.Size(260, 45)
    $AddAppGroupButton_ADDTabPage.Size = New-Object System.Drawing.Size(200, 20)
    $AddAppGroupButton_ADDTabPage.Text = 'Add App Group'
    $AddAppGroupButton_ADDTabPage.Add_Click( {
            AddAppGroup
        })
    $AddTabPage.Controls.Add($AddAppGroupButton_ADDTabPage)

    $GetPublishedAppButton_ADDTabPage = New-Object System.Windows.Forms.Button
    $GetPublishedAppButton_ADDTabPage.Location = New-Object System.Drawing.Size(10, 200)
    $GetPublishedAppButton_ADDTabPage.Size = New-Object System.Drawing.Size(200, 20)
    $GetPublishedAppButton_ADDTabPage.Text = 'Get Published Apps'
    $GetPublishedAppButton_ADDTabPage.Add_Click( {
            GetPublishedApps
        })
    $AddTabPage.Controls.Add($GetPublishedAppButton_ADDTabPage)


    # Log output text box
    $LogTextBox = New-Object System.Windows.Forms.RichTextBox
    $LogTextBox.Location = New-Object System.Drawing.Size(650, 15)
    $LogTextBox.Size = New-Object System.Drawing.Size(400, 750)
    $LogTextBox.ReadOnly = 'True'
    $LogTextBox.BackColor = 'blue'
    $LogTextBox.ForeColor = 'orange'
    $LogTextBox.Font = 'Consolas, 10'
    $LogTextBox.DetectUrls = $false
    $main_form.Controls.Add($LogTextBox)


    $main_form.ShowDialog()

}