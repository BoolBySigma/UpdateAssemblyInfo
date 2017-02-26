[CmdletBinding()]
param()

Trace-VstsEnteringInvocation $MyInvocation

$assemblyInfoFiles = Get-VstsInput -Name assemblyInfoFiles -Require
$description = Get-VstsInput -Name description
$configuration = Get-VstsInput -Name configuration
$company = Get-VstsInput -Name company
$product = Get-VstsInput -Name product
$copyright = Get-VstsInput -Name copyright
$trademark = Get-VstsInput -Name trademark
$fileVersionMajor = Get-VstsInput -Name fileVersionMajor
$fileVersionMinor = Get-VstsInput -Name fileVersionMinor
$fileVersionBuild = Get-VstsInput -Name fileVersionBuild
$fileVersionRevision = Get-VstsInput -Name fileVersionRevision
$informationalVersion = Get-VstsInput -Name informationalVersion

function Is-Numeric ($value)
{
    return $value -match "^[\d\.]+$"
}

try {
	# Validate description
	if ([string]::IsNullOrEmpty($description)) {
		$description = $null
	}

	# Validate configuration
	if ([string]::IsNullOrEmpty($configuration)) {
		$configuration = $null
	}

	# Validate company
	if ([string]::IsNullOrEmpty($company)) {
		$company = $null
	}

	# Validate product
	if ([string]::IsNullOrEmpty($product)) {
		$product = $null
	}

	# Validate copyright
	if ([string]::IsNullOrEmpty($copyright)) {
		$copyright = $null
	}

	# Validate trademark
	if ([string]::IsNullOrEmpty($trademark)) {
		$trademark = $null
	}

	# Validate fileVersionMajor
	if ([string]::IsNullOrEmpty($fileVersionMajor)) {
		$fileVersionMajor = "`$(current)"
	} else {
		if (!(Is-Numeric($fileVersionMajor))) {
			Write-VstsTaskError "Invalid value for File Version Major. `'$fileVersionMajor`' is not a numerical value."
		}
	}

	# Validate fileVersionMinor
	if ([string]::IsNullOrEmpty($fileVersionMinor)) {
		$fileVersionMinor = "`$(current)"
	} else {
		if (!(Is-Numeric($fileVersionMinor))) {
			Write-VstsTaskError "Invalid value for File Version Minor. `'$fileVersionMinor`' is not a numerical value."
		}
	}

	# Validate fileVersionBuild
	if ([string]::IsNullOrEmpty($fileVersionBuild)) {
		$fileVersionBuild = "`$(current)"
	} else {
		if (!(Is-Numeric($fileVersionBuild))) {
			Write-VstsTaskError "Invalid value for File Version Build. `'$fileVersionBuild`' is not a numerical value."
		}
	}

	# Validate fileVersionRevision
	if ([string]::IsNullOrEmpty($fileVersionRevision)) {
		$fileVersionRevision = "`$(current)"
	} else {
		if (!(Is-Numeric($fileVersionRevision))) {
			Write-VstsTaskError "Invalid value for File Version Revision. `'$fileVersionRevision`' is not a numerical value."
		}
	}

	# Format file version
	$fileVersion = "$fileVersionMajor.$fileVersionMinor.$fileVersionBuild.$fileVersionRevision"

	# Format description
	$description = $description.Replace("`$(Assembly.Company)", $company)
	$description = $description.Replace("`$(Assembly.Product)", $product)
	$description = $description.Replace("`$(Year)", (Get-Date).Year)

	# Format copyright
	$copyright = $copyright.Replace("`$(Assembly.Company)", $company)
	$copyright = $copyright.Replace("`$(Assembly.Product)", $product)
	$copyright = $copyright.Replace("`$(Year)", (Get-Date).Year)

	# Format trademark
	$trademark = $trademark.Replace("`$(Assembly.Company)", $company)
	$trademark = $trademark.Replace("`$(Assembly.Product)", $product)

	# Format informational version
	$informationalVersion = $informationalVersion.Replace("`$(Assembly.FileVersion)", "`$(fileversion)")
	$informationalVersion = $informationalVersion.Replace("`$(Assembly.FileVersionMajor)", $fileVersionMajor)
	$informationalVersion = $informationalVersion.Replace("`$(Assembly.FileVersionMinor)", $fileVersionMinor)
	$informationalVersion = $informationalVersion.Replace("`$(Assembly.FileVersionBuild)", $fileVersionBuild)
	$informationalVersion = $informationalVersion.Replace("`$(Assembly.FileVersionRevision)", $fileVersionRevision)
	$informationalVersionDisplay = $informationalVersion.Replace("`$(fileversion)", $fileVersion)

	# Print parameters
	$parameters = @()
	$parameters += New-Object PSObject -Property @{Parameter="Description"; Value=$description}
	$parameters += New-Object PSObject -Property @{Parameter="Configuration"; Value=$configuration}
	$parameters += New-Object PSObject -Property @{Parameter="Company"; Value=$company}
	$parameters += New-Object PSObject -Property @{Parameter="Product"; Value=$product}
	$parameters += New-Object PSObject -Property @{Parameter="Copyright"; Value=$copyright}
	$parameters += New-Object PSObject -Property @{Parameter="Trademark"; Value=$trademark}
	$parameters += New-Object PSObject -Property @{Parameter="File Version"; Value=$fileVersion}
	$parameters += New-Object PSObject -Property @{Parameter="Informational Version"; Value=$informationalVersionDisplay}
	$parameters | format-table -property Parameter, Value

	Import-Module (Join-Path -Path $PSScriptRoot -ChildPath "Bool.PowerShell.UpdateAssemblyInfo.dll")

	$files = @()

	if (Test-Path -LiteralPath $assemblyInfoFiles) {
		$file = (Resolve-Path $assemblyInfoFiles).Path
		if ($file -like "*\AssemblyInfo.*") {
			$files += $file
		}
	} else {
		$files = Get-ChildItem $assemblyInfoFiles -Recurse | % {$_.FullName} | Where-Object {$_ -like "*\AssemblyInfo.*"}
	}

	if ($files) {
		Write-Output "Updating:"
		Write-Output $files
		
		Update-AssemblyInfo -Files $files -AssemblyDescription $description -AssemblyConfiguration $configuration -AssemblyCompany $company -AssemblyProduct $product -AssemblyCopyright $copyright -AssemblyTrademark $trademark -AssemblyFileVersion $fileVersion -AssemblyInformationalVersion $informationalVersion
	} else {
		Write-VstsTaskError "AssemblyInfo.* file not found using search pattern `'$assemblyInfoFiles`'."
	}
} finally {
    Trace-VstsLeavingInvocation $MyInvocation
}