# PowerCLI script to Create Port Group in Scale
# =============================================
#  Mandatory Inputs needed for the script are vC Sever FDQN, vC Server Username, vC Password, VDS Portgroup Name, VDS Name, VLAN ID, and Number of Portgroups to be created
#
# Author: Shanthakumar K

#Start of script.

Param (
    # Required parameters for the script.
    [Parameter (Mandatory = $true, HelpMessage = 'Provide vCenter FQDN')] [ValidateNotNullOrEmpty()] [String]$vc_fqdn,
    [Parameter (Mandatory = $true, HelpMessage = 'Provide vCenter SSO User')] [ValidateNotNullOrEmpty()] [String]$vc_username,
    [Parameter (Mandatory = $true, HelpMessage = 'Provide vCenter SSO Password')] [ValidateNotNullOrEmpty()] [String]$vc_password,
    [Parameter (Mandatory = $true, HelpMessage = 'Provide Portgroup Name')] [ValidateNotNullOrEmpty()] [String]$portgroupname,
    [Parameter (Mandatory = $true, HelpMessage = 'Provide Virtual Distributed Switch Name')] [ValidateNotNullOrEmpty()] [String]$vdsname,
    [Parameter (Mandatory = $true, HelpMessage = 'Provide vLAN for Portgroup')] [ValidateNotNullOrEmpty()] [String]$vlan,
    [Parameter (Mandatory = $true, HelpMessage = 'Provider Number of Portgroups to be created')] [ValidateNotNullOrEmpty()] [String]$numberofPGs
)

Write-Host "Connecting to vCenter Server"

Write-Host "connect-viserver -Server $vc_fqdn -User $vc_username -Password $vc_password"

connect-viserver -Server $vc_fqdn -User $vc_username -Password $vc_password

$number_pg=1..$numberofPGs
$number_pg | foreach {
Write-Host "Get-VDSwitch -Name $vdsname | New-VDPortgroup -Name $portgroupname$_ -VlanId $vlan -RunAsync:$true" 
Get-VDSwitch -Name $vdsname | New-VDPortgroup -Name $portgroupname$_ -VlanId $vlan -RunAsync:$true

Write-Host "Portgroups created. Now confirming settings" -ForegroundColor Cyan
Get-VDSwitch $vdsname | Get-VDPortgroup | select name, numports, portbinding, vlanconfiguration

}
#End of script.
