$classgroup = "Class_Group"
$avdgroup = "AVD_Group"

$classgroupaccounts = Get-ADGroupMember -Identity $classgroup -Server auburn.edu | select SamAccountName

foreach ($classgroupaccount in $classgroupaccounts)
{

Add-ADGroupMember -Identity $avdgroup -Server auburn.edu -Members $classgroupaccount

}
