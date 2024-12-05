# PowerCLI script to Create Virtual Machine using Content Library Template in Scale
# ==================================================================================
#
#  Mandatory Inputs needed for the script are vC Sever FDQN, vC Server Username, vC Password, VDS Portgroup Name, Datastore Name
#  Resourcepool Name, Template, OS customization spec, and Number of Virtual Machines to be created
#
# Pre-req
# VM Template & VM CustmomizatioSpec should be created upfront
# Other Parameters have it handy
#
# Author: Shanthakumar K


#Start of script.

Param (
    # Required parameters for the script.
    [Parameter (Mandatory = $true, HelpMessage = 'Provide vCenter FQDN')] [ValidateNotNullOrEmpty()] [String]$vc_fqdn,
    [Parameter (Mandatory = $true, HelpMessage = 'Provide vCenter SSO User')] [ValidateNotNullOrEmpty()] [String]$vc_username,
    [Parameter (Mandatory = $true, HelpMessage = 'Provide vCenter SSO Password')] [ValidateNotNullOrEmpty()] [String]$vc_password,
    [Parameter (Mandatory = $true, HelpMessage = 'Provide Virtual Machine Name')] [ValidateNotNullOrEmpty()] [String]$vmname,
    [Parameter (Mandatory = $true, HelpMessage = 'Provide Portgroup Name')] [ValidateNotNullOrEmpty()] [String]$portgroupname,
    [Parameter (Mandatory = $true, HelpMessage = 'Provide Datastore Name')] [ValidateNotNullOrEmpty()] [String]$datastorename,
    [Parameter (Mandatory = $true, HelpMessage = 'Provide Cluster Name')] [ValidateNotNullOrEmpty()] [String]$clustername,
    [Parameter (Mandatory = $true, HelpMessage = 'Provide Content Library Template Name')] [ValidateNotNullOrEmpty()] [String]$contentLibraryItem,
    [Parameter (Mandatory = $true, HelpMessage = 'Provide Number of Virtual Machines to be created')] [ValidateNotNullOrEmpty()] [String]$numberofVMs
)

Write-Host "Connecting to vCenter Server"
Write-Host "connect-viserver -Server $vc_fqdn -User $vc_username -Password $vc_password"
connect-viserver -Server $vc_fqdn -User $vc_username -Password $vc_password

Write-Host "Create Resource Pool under Cluster"
$ExResourcePool = Get-ResourcePool -Location $clustername -Name Workload-VM-RPool

if (!$ExResourcePool) {
    Write-Host "Creating New Resource Pool"
    $ExResourcePool = New-ResourcePool -Name Workload-VM-RPool -Location $clustername
}

$numberofVM=1..$numberofVMs
$numberofVM | foreach {

Write-Host "New-VM -Name $vmname-$_ -Datastore $datastorename -ResourcePool $ExResourcePool -ContentLibraryItem $contentLibraryItem"
New-VM -Name $vmname-$_ -Datastore $datastorename -ResourcePool $ExResourcePool -ContentLibraryItem $contentLibraryItem

Get-VM $vmname-$_ | Get-NetworkAdapter | Set-NetworkAdapter -NetworkName $portgroupname -Confirm:$false

Write-Host "Start-VM $vmname-$_"
Start-VM $vmname-$_

}

#End of script.

# How to execute the script
#  .\create-vm.ps1 -vc_fqdn 10.0.0.6 -vc_username Administrator@vsphere.local -vc_password VMware123!VMware123! 
#       -vmname test01 -portgroupname SDDC-DPortGroup-VSAN -datastorename sfo01-m01-vsan -clustername SDDC-Cluster1  -contentLibraryItem ubuntu-scale -numberofVMs 5
