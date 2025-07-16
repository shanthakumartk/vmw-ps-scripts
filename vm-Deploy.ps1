# PowerCLI script to Create Virtual Machine using Content Library Template/ Template in Scale
# ===========================================================================================

#Start of script.


param (
    [string]$vCenter,
    [string]$UserName,
    [string]$Password
)

function Show-Menu {
    param (
        [string]$Prompt,
        [array]$Options
    )
    Write-Host "`n====== $Prompt ======" -ForegroundColor Cyan
    for ($i = 0; $i -lt $Options.Count; $i++) {
        Write-Host "[$i] $($Options[$i].Name)" -ForegroundColor Yellow
    }
    do {
        $choice = Read-Host "Enter selection (0 - $($Options.Count - 1))"
    } while (-not ($choice -match '^\d+$') -or [int]$choice -lt 0 -or [int]$choice -ge $Options.Count)
    return $Options[[int]$choice]
}

# Load PowerCLI modules
Import-Module VMware.PowerCLI -ErrorAction Stop
#Import-Module VMware.VimAutomation.Content -ErrorAction Stop

Write-Host "`n============================================================ " -ForegroundColor Cyan
Write-Host "`n      Script to Deploy VMs " -ForegroundColor Cyan
Write-Host "`n------------------------------------------------------------ " -ForegroundColor Cyan
Write-Host "`nPre-Req: 1. VM Image : Either in Template or Content Library" -ForegroundColor Red
Write-Host "`nPre-Req: 2. Dedicated VM Network: on VDS or NSX with DHCP" -ForegroundColor Red
Write-Host "`nPre-Req: 3. Resource Pool: to Isolate the VMs" -ForegroundColor Red
Write-Host "`n============================================================ " -ForegroundColor Cyan


Write-Host "`n🎛️  All the Pre-req are taken care (yes/no)" -ForegroundColor Red
$prereq = Read-Host "Pre-requistes"
if ($prereq -match "^n") {
	Write-Host "`n PLEASE TAKE CARE OF PRE-REQ"
	exit 1
}

# Prompt for vCenter if not passed
if (-not $vCenter) {
	Write-Host "`n📝 Enter vCenter FQDN Detail" -ForegroundColor Green
    $vCenter = Read-Host "vCenter FQDN"
	# Connect to vCenter
	try {
		Connect-VIServer -Server $vCenter -ErrorAction Stop | Out-Null
	} catch {
		Write-Host "❌ Failed to connect to vCenter '$vCenter'. Exiting." -ForegroundColor Red
		exit 1
	}
} else {
	Write-Host "`n📝 NOTE: Security Violation ALERT !!!!" -ForegroundColor Red
	Write-Host "`n Credentails are passed as commandline Input" -ForegroundColor Red
	# Connect to vCenter
	try {
		Connect-VIServer -Server $vCenter -User $UserName -Password $Password -ErrorAction Stop | Out-Null
	} catch {
		Write-Host "❌ Failed to connect to vCenter '$vCenter'. Exiting." -ForegroundColor Red
		exit 1
	}
}
Write-Host "`n------------------------------------------------------------ " -ForegroundColor Cyan

Write-Host "`n🎛️Please choose VM Deployment Mode as per the below options" -ForegroundColor Red
Write-Host "`nOptions: #1 - Content Library Item" -ForegroundColor Cyan
Write-Host "`nOptions: #2 - Template  " -ForegroundColor Cyan
Write-Host "`nOptions: #3 - Dummy VM " -ForegroundColor Cyan

$VMDeployMode = Read-Host "VM Deployment Mode"

Switch ($VMDeployMode) {
 1{echo "1- VM Deployment Mode : from Content Library"}
 2{echo "2- VM Deployment Mode : from Template"}
 3{echo "3- Dummy VM Deployment without Guest OS"}
}

if ($VMDeployMode -match "1") {
	# Select Content Library and Template from Content Library
	$ContentLibraryList = Get-ContentLibrary
	if (-not $ContentLibraryList -or $ContentLibraryList.Count -eq 0) {
		Write-Host "❌ No Content Library found in vCenter. Exiting." -ForegroundColor Red
		Disconnect-VIServer -Confirm:$false
		exit 1
	}
	$library = Show-Menu -Prompt "Select Content Library" -Options $ContentLibraryList

	$templateItems = Get-ContentLibraryItem -ContentLibrary $library
	if (-not $templateItems -or $templateItems.Count -eq 0) {
		Write-Host "❌ No template found in the selected Content Library. Exiting." -ForegroundColor Red
		Disconnect-VIServer -Confirm:$false
		exit 1
	}
	$template = Show-Menu -Prompt "Select Template" -Options $templateItems
} elseif ($VMDeployMode -match "2") {

	# Select Template
    $templates = Get-Template
    if (-not $templates) {
        Write-Host "❌ No VM templates found in vCenter. Exiting." -ForegroundColor Red
        Disconnect-VIServer -Confirm:$false
        exit 1
    }
    $template = Show-Menu -Prompt "Select Template" -Options $templates
} elseif ($VMDeployMode -match "3") {
	Write-Host "VM Deployment choosen is Dummy VM" -ForegroundColor Red
}


# Prompt for VM Count and Prefix
Write-Host "`n🔢 How many VMs do you want to deploy?" -ForegroundColor Cyan
$VMCount = [int](Read-Host "VM Count")

Write-Host "`n📝 Enter VM name prefix:" -ForegroundColor Cyan
$VMPrefix = Read-Host "VM Prefix"

# Select DataCenter
$datacenters = Get-Datacenter
$datacenter = Show-Menu -Prompt "Select Datacenter" -Options $datacenters

# Select Cluster and Host
$clusters = Get-Cluster
$cluster = Show-Menu -Prompt "Select Cluster" -Options $clusters
$vmHost = $cluster | Get-VMHost | Get-Random

# Select Datastore
$datastores = Get-Datastore -Location $datacenter
$datastore = Show-Menu -Prompt "Select Datastore" -Options $datastores

# Select Network
$networks = Get-VDPortgroup 
$network = Show-Menu -Prompt "Select Portgroup/Network" -Options $networks

# Optional Resource Pool
$resourcePools = Get-ResourcePool -Location $cluster
Write-Host "`n🎛️  Use a specific Resource Pool? (yes/no)" -ForegroundColor Cyan
$useRP = Read-Host "Resource Pool" 
$resourcePool = $null
if ($useRP -match "^y") {
    $resourcePool = Show-Menu -Prompt "Select Resource Pool" -Options $resourcePools
}

# Initialize log
$log = @()

# Deploy VMs
for ($i = 1; $i -le $VMCount; $i++) {
    $vmName = "$VMPrefix-$i"
    Write-Host "`nDeploying VM: $vmName" -ForegroundColor Yellow
	
	if ($VMDeployMode -match "1") {
		$deployParams = @{
			Name               = $vmName
			ContentLibraryItem = $template
			VMHost             = $vmHost
			Datastore          = $datastore
		}
	} elseif ($VMDeployMode -match "2") {
		$deployParams = @{
			Name               = $vmName
			Template           = $template
			VMHost             = $vmHost
			Datastore          = $datastore
		}
	} elseif ($VMDeployMode -match "3") {
		$deployParams = @{
			Name               = $vmName
			Datastore          = $datastore
		}
	}
		
    if ($resourcePool) {
        $deployParams['ResourcePool'] = $resourcePool
    }

    try {
		Write-Host "`n====== Deploying New VM ======== " -ForegroundColor Cyan
        $vm = New-VM @deployParams

        # Attach network adapter
		Write-Host "`n====== Attach Network Adaptor to VM ======== " -ForegroundColor Cyan
        Get-NetworkAdapter -VM $vm | Set-NetworkAdapter -PortGroup $network -Confirm:$false

        # Power on the VM
		Write-Host "`n====== PowerON the VM ======== " -ForegroundColor Cyan
        Start-VM -VM $vm | Out-Null

        # Log entry
        $log += [PSCustomObject]@{
            VMName     = $vmName
            Cluster    = $cluster.Name
            Host       = $vmHost.Name
            Datastore  = $datastore.Name
            Network    = $network.Name
            Timestamp  = (Get-Date)
        }
    } catch {
        Write-Host "❌ Failed to deploy $vmName. $_" -ForegroundColor Red
    }
}

# Save log
$logFile = "VMDeploymentLog_$(Get-Date -Format 'yyyyMMdd_HHmmss').csv"
$log | Export-Csv -Path $logFile -NoTypeInformation
Write-Host "`n✅ Deployment completed. Log saved to $logFile." -ForegroundColor Green

# Disconnect
Disconnect-VIServer -Confirm:$false
Write-Host "`n🔌 Disconnected from vCenter." -ForegroundColor Gray
Write-Host "`n===============================================================================" -ForegroundColor Cyan

#End of script