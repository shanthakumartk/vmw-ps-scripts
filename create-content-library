# PowerCLI script to Create Content Library and Upload the OVA for VM Provisioning
# ================================================================================
#
#  Mandatory Inputs needed for the script are vC Sever FDQN, vC Server Username, 
#  vC Password, Datastore Name, Content LibraryName, OVA Name and OVA Path
#
# Pre-req
# OVA Template ( Only OVA is supported)
#
# Author: Shanthakumar K

# Start of script.

Param (
    # Required parameters for the script.
    [Parameter (Mandatory = $true, HelpMessage = 'Provide vCenter FQDN')] [ValidateNotNullOrEmpty()] [String]$vc_fqdn,
    [Parameter (Mandatory = $true, HelpMessage = 'Provide vCenter SSO User')] [ValidateNotNullOrEmpty()] [String]$vc_username,
    [Parameter (Mandatory = $true, HelpMessage = 'Provide vCenter SSO Password')] [ValidateNotNullOrEmpty()] [String]$vc_password,
    [Parameter (Mandatory = $true, HelpMessage = 'Provide Content Library Name')] [ValidateNotNullOrEmpty()] [String]$LibraryName,
    [Parameter (Mandatory = $true, HelpMessage = 'Provide Datastore Name')] [ValidateNotNullOrEmpty()] [String]$DatastoreName,
    [Parameter (Mandatory = $true, HelpMessage = 'Provide OVA Source Location')] [ValidateNotNullOrEmpty()] [String]$ovaPath,
    [Parameter (Mandatory = $true, HelpMessage = 'Provide OVA Prefix')] [ValidateNotNullOrEmpty()] [String]$ovaPrefix
)

# Ignore unsigned SSL certificates and increase the HTTP timeout value
Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false
Set-PowerCLIConfiguration -WebOperationTimeoutSeconds 3600 -Scope Session

Write-Host "Connecting to vCenter Server"
Write-Host "connect-viserver -Server $vc_fqdn -User $vc_username -Password $vc_password"
connect-viserver -Server $vc_fqdn -User $vc_username -Password $vc_password

Write-Host "Check the availability of the datastore and content library"
$ExLibraryName = Get-ContentLibrary -Name $LibraryName
$ExDatastore = Get-Datastore -Name $DatastoreName

Write-Host "Check the availability of the datastore and content library"
if (!$ExLibraryName -and $ExDatastore) {
    Write-Host "Creating New Content Library -- $LibraryName on $Datastore"
    New-ContentLibrary -Datastore $DatastoreName -Name $LibraryName

}

Write-Host "Check the availability of OVA Template"
$OVAlist = ls $($ovaPath)$ovaPrefix*.ova | Get-ChildItem -rec | ForEach-Object -Process {$_.BaseName}
Write-Host "OVA Template --->" $OVAlist

foreach( $ova in $OVAlist){
    $FullPath = "$($ovaPath)$($ova).ova"
	Write-Host "ABS Path of the OVA Template --->" $FullPath
    $ExistingItem = Get-ContentLibraryItem -Name $ova -ContentLibrary $LibraryName
	Write-Host $ExistingItem
    if (!$ExistingItem) {
        Write-Host "Uploading $($ova)"
        Write-Host "New-ContentLibraryItem -ContentLibrary $LibraryName -Name $ova -Files $FullPath"
        New-ContentLibraryItem -ContentLibrary $LibraryName -Name $ova -Files $FullPath
    } else
	{
    Write-Host "$($ova) Already Exists In Repo" }

}

#End of script.

# How to execute the script
# .\create-content-library.ps1 -vc_fqdn 10.0.0.6 -vc_username Administrator@vsphere.local -vc_password VMware123!VMware123! -LibraryName workload-template -DatastoreName sfo01-m01-vsan -ovaPath "C:\Users\Administrator\Downloads\" -ovaPrefix ubuntu
