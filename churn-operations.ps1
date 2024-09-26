#Start of script.

Param (
    # Required parameters for the script.
    [Parameter (Mandatory = $true, HelpMessage = 'Provide vCenter FQDN')] [ValidateNotNullOrEmpty()] [String]$vc_fqdn,
    [Parameter (Mandatory = $true, HelpMessage = 'Provide vCenter SSO User')] [ValidateNotNullOrEmpty()] [String]$vc_username,
    [Parameter (Mandatory = $true, HelpMessage = 'Provide vCenter SSO Password')] [ValidateNotNullOrEmpty()] [String]$vc_password,
    [Parameter (Mandatory = $true, HelpMessage = 'Provide Portgroup Name')] [ValidateNotNullOrEmpty()] [String]$portgroupname,
    [Parameter (Mandatory = $true, HelpMessage = 'Provide vLAN for Portgroup')] [ValidateNotNullOrEmpty()] [String]$vlan,
    [Parameter (Mandatory = $true, HelpMessage = 'Provide Distributed Switch Name')] [ValidateNotNullOrEmpty()] [String]$dvswitchname,
    [Parameter (Mandatory = $true, HelpMessage = 'Provide Datastore Name')] [ValidateNotNullOrEmpty()] [String]$datastorename,
    [Parameter (Mandatory = $true, HelpMessage = 'Provide Resource Pools Name')] [ValidateNotNullOrEmpty()] [String]$resourcepoolname,
    [Parameter (Mandatory = $true, HelpMessage = 'Provide Number of Churn Operations')] [ValidateNotNullOrEmpty()] [String]$numberofchurn,
    [Parameter (Mandatory = $true, HelpMessage = 'Provide Template Name')] [ValidateNotNullOrEmpty()] [String]$vmtemplate,
    [Parameter (Mandatory = $true, HelpMessage = 'Provider OS Customization Spec Name')] [ValidateNotNullOrEmpty()] [String]$customizationspec
)

Write-Host "Connecting to vCenter Server"
Write-Host "connect-viserver -Server $vc_fqdn -User $vc_username -Password $vc_password"
connect-viserver -Server $vc_fqdn -User $vc_username -Password $vc_password

$churn=1..$numberofchurn
$churn | foreach {

Write-Host "Create New Portgroup"
Write-Host "Get-VDSwitch -Name $dvswitchname | New-VDPortgroup -Name $portgroupname$_ -VlanId $vlan -RunAsync:$true" 
Get-VDSwitch -Name $dvswitchname | New-VDPortgroup -Name $portgroupname$_ -VlanId $vlan -RunAsync:$true

Write-Host "Create New VM with Portgroup created Earlier"
Write-Host "New-VM -Name $vmnameprefix$_  -Datastore $datastorename -NetworkName $portgroupname$_ -ResourcePool $resourcepoolname"
New-VM -Name $vmnameprefix$_  -Datastore $datastorename -NetworkName $portgroupname$_ -ResourcePool $resourcepoolname

Write-Host "Power On VM"
Write-Host "Start-VM $vmnameprefix$_"
Start-VM $vmnameprefix$_

Write-Host "Create New Snapshot from VM"
Write-Host "Get-VM  $vmnameprefix$_ | new-snapshot -Name "churn" -Description "Sample snapshot" -Quiesce -Memory"
Get-VM  $vmnameprefix$_ | new-snapshot -Name "churn" -Description "Sample snapshot" -Quiesce -Memory

Write-Host "Revert VM to existing Snapshot"
Write-Host "set-vm $vmnameprefix$_ -Snapshot churn -Confirm:$false"
set-vm $vmnameprefix$_ -Snapshot churn -Confirm:$false

Write-Host "Delete Snapshot from VM"
Write-Host "get-snapshot -name churn -VM $vmnameprefix$_  | Remove-Snapshot -Confirm:$false"
get-snapshot -name churn -VM $vmnameprefix$_  | Remove-Snapshot -Confirm:$false

Write-Host "Power off VM"
Write-Host "Stop-VM $vmnameprefix$_ -Confirm:$false"
Stop-VM $vmnameprefix$_ -Confirm:$false

Write-Host "Power On VM"
Write-Host "Start-VM $vmnameprefix$_"
Start-VM $vmnameprefix$_

Write-Host "Power off VM"
Write-Host "Stop-VM $vmnameprefix$_ -Confirm:$false"
Stop-VM $vmnameprefix$_ -Confirm:$false

Write-Host "Delete VM"
Write-Host "remove-vm $vmnameprefix$_ -Confirm:$false"
remove-vm $vmnameprefix$_ -Confirm:$false

Write-Host "Create New Portgroup"
Write-Host "Get-VDPortGroup -Name $portgroupname$_ | Remove-VDPortGroup -RunAsync:$true" 
Get-VDPortGroup -Name $portgroupname$_ | Remove-VDPortGroup -RunAsync:$true -Confirm:$false

}

#End of script.