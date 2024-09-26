#Start of script.

Param (
    # Required parameters for the script.
    [Parameter (Mandatory = $true, HelpMessage = 'Provide vCenter FQDN')] [ValidateNotNullOrEmpty()] [String]$vc_fqdn,
    [Parameter (Mandatory = $true, HelpMessage = 'Provide vCenter SSO User')] [ValidateNotNullOrEmpty()] [String]$vc_username,
    [Parameter (Mandatory = $true, HelpMessage = 'Provide vCenter SSO Password')] [ValidateNotNullOrEmpty()] [String]$vc_password,
    [Parameter (Mandatory = $true, HelpMessage = 'Provide Virtual Machine Name')] [ValidateNotNullOrEmpty()] [String]$vmname,
    [Parameter (Mandatory = $true, HelpMessage = 'Provide Portgroup Name')] [ValidateNotNullOrEmpty()] [String]$portgroupname,
    [Parameter (Mandatory = $true, HelpMessage = 'Provide Datastore Name')] [ValidateNotNullOrEmpty()] [String]$datastorename,
    [Parameter (Mandatory = $true, HelpMessage = 'Provide Resource Pools Name')] [ValidateNotNullOrEmpty()] [String]$resourcepoolname,
    [Parameter (Mandatory = $true, HelpMessage = 'Provider Number of Virtual Machines to be created')] [ValidateNotNullOrEmpty()] [String]$numberofVMs
)

Write-Host "Connecting to vCenter Server"
Write-Host "connect-viserver -Server $vc_fqdn -User $vc_username -Password $vc_password"
connect-viserver -Server $vc_fqdn -User $vc_username -Password $vc_password

$numberofVM=1..$numberofVMs
$numberofVM | foreach {

Write-Host "New-VM -Name $vmname-$_  -Datastore $datastorename  -ResourcePool $resourcepoolname"
New-VM -Name $vmname-$_  -Datastore $datastorename  -ResourcePool $resourcepoolname
Start-VM $vmname-$_

}
#End of script.