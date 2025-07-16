Connect-VIServer -Server wld4-vcenter.cp.tb12.org -U Administrator@wld4.cp.org -Password 'VMware123!VMware123!'

# Set the resource pool name
$resourcePoolName = "Workload-VM-RPool"

# Get the resource pool object
$rp = Get-ResourcePool -Name $resourcePoolName


# Get all VMs in the resource pool
$vms = Get-VM | Where-Object { $_.ExtensionData.ResourcePool -eq $rp.Id }

# Power off and delete
$vms | Where-Object { $_.PowerState -eq "PoweredOn" } | ForEach-Object {
    Write-Host "Powering off VM: $($_.Name)"
    Stop-VM -VM $_ -Confirm:$false
}

$vms | ForEach-Object {
    Write-Host "Deleting VM: $($_.Name)"
    Remove-VM -VM $_ -DeletePermanently -Confirm:$false
}
