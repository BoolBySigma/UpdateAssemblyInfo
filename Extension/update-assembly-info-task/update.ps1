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
$assemblyVersionMajor = Get-VstsInput -Name assemblyVersionMajor
$assemblyVersionMinor = Get-VstsInput -Name assemblyVersionMinor
$assemblyVersionBuild = Get-VstsInput -Name assemblyVersionBuild
$assemblyVersionRevision = Get-VstsInput -Name assemblyVersionRevision
$informationalVersion = Get-VstsInput -Name informationalVersion
$comVisible = Get-VstsInput -Name comVisible

$global:errors = 0

function Block-InvalidVariable {
	param(
		[string]
		$displayName,
		[string]
		$parameter
	)

	if (![string]::IsNullOrEmpty($parameter)) {
		if ($parameter.Contains("`$(Invalid)")) {
			Write-VstsTaskError "$displayName contains the variable `$(Invalid). Most likely this is because the default value must be changed to something meaningful."
			$global:errors += 1
		}
	}
}

function Block-NonNumericParameter {
	param(
		[string]
		$displayName,
		[string]
		$parameter
	)

	if (![string]::IsNullOrEmpty($parameter)) {
		if (!($parameter -match "^[\d\.]+$")) {
			Write-VstsTaskError "Invalid value for `'$displayName`'. `'$parameter`' is not a numerical value."
			$global:errors += 1
		}
	}	
}

function Block-InvalidVersion {
	param(
		[string]
		$displayName,
		[string]
		$parameter
	)

	if ([string]::IsNullOrEmpty($parameter)) {
		return "`$(current)"
	} else {
		Block-InvalidVariable $displayName $parameter
		Block-NonNumericParameter $displayName $parameter
		return $parameter
	}
}

try {
	# Check description
	Block-InvalidVariable "Description" $description

	# Check configuration
	Block-InvalidVariable "Configuration" $configuration

	# Check company
	Block-InvalidVariable "Company" $company

	# Check product
	Block-InvalidVariable "Product" $product

	# Check copyright
	Block-InvalidVariable "Copyright" $copyright

	# Check trademark
	Block-InvalidVariable "Trademark" $trademark

	# Check informational version
	Block-InvalidVariable "Informational Version" $informationalVersion

	# Check fileVersionMajor
	$fileVersionMajor = (Block-InvalidVersion "File Version Major" $fileVersionMajor)

	# Check fileVersionMinor
	$fileVersionMinor = (Block-InvalidVersion "File Version Minor" $fileVersionMinor)

	# Check fileVersionBuild
	$fileVersionBuild = (Block-InvalidVersion "File Version Build" $fileVersionBuild)

	# Check fileVersionRevision
	$fileVersionRevision = (Block-InvalidVersion "File Version Revision" $fileVersionRevision)

	# Check assemblyVersionMajor
	$assemblyVersionMajor = (Block-InvalidVersion "Assembly Version Major" $assemblyVersionMajor)

	# Check assemblyVersionMinor
	$assemblyVersionMinor = (Block-InvalidVersion "Assembly Version Minor" $assemblyVersionMinor)

	# Check assemblyVersionBuild
	$assemblyVersionBuild = (Block-InvalidVersion "Assembly Version Build" $assemblyVersionBuild)

	# Check assemblyVersionRevision
	$assemblyVersionRevision = (Block-InvalidVersion "Assembly Version Revision" $assemblyVersionRevision)

	if ($global:errors) {
		Write-VstsTaskError "Failed with $errors error(s)"
		Write-VstsSetResult -Result "Failed"
	}

	# Format file version
	$fileVersion = "$fileVersionMajor.$fileVersionMinor.$fileVersionBuild.$fileVersionRevision"

	# Format assembly version
	$assemblyVersion = "$assemblyVersionMajor.$assemblyVersionMinor.$assemblyVersionBuild.$assemblyVersionRevision"

	# Format description
	$description = $description.Replace("`$(Assembly.Company)", $company)
	$description = $description.Replace("`$(Assembly.Product)", $product)
	$description = $description.Replace("`$(Assembly.Year)", (Get-Date).Year)
	# Leave in for legacy functionality
	$description = $description.Replace("`$(Year)", (Get-Date).Year)

	# Format copyright
	$copyright = $copyright.Replace("`$(Assembly.Company)", $company)
	$copyright = $copyright.Replace("`$(Assembly.Product)", $product)
	$copyright = $copyright.Replace("`$(Assembly.Year)", (Get-Date).Year)
	# Leave in for legacy functionality
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

	$informationalVersion = $informationalVersion.Replace("`$(Assembly.AssemblyVersion)", $assemblyVersion)
	$informationalVersion = $informationalVersion.Replace("`$(Assembly.AssemblyVersionMajor)", $assemblyVersionMajor)
	$informationalVersion = $informationalVersion.Replace("`$(Assembly.AssemblyVersionMinor)", $assemblyVersionMinor)
	$informationalVersion = $informationalVersion.Replace("`$(Assembly.AssemblyVersionBuild)", $assemblyVersionBuild)
	$informationalVersion = $informationalVersion.Replace("`$(Assembly.AssemblyVersionRevision)", $assemblyVersionRevision)

	$informationalVersionDisplay = $informationalVersion.Replace("`$(fileversion)", $fileVersion)

	# Print parameters
	$parameters = @()
	$parameters += New-Object PSObject -Property @{Parameter="Description"; Value=$description}
	$parameters += New-Object PSObject -Property @{Parameter="Configuration"; Value=$configuration}
	$parameters += New-Object PSObject -Property @{Parameter="Company"; Value=$company}
	$parameters += New-Object PSObject -Property @{Parameter="Product"; Value=$product}
	$parameters += New-Object PSObject -Property @{Parameter="Copyright"; Value=$copyright}
	$parameters += New-Object PSObject -Property @{Parameter="Trademark"; Value=$trademark}
	$parameters += New-Object PSObject -Property @{Parameter="Informational Version"; Value=$informationalVersionDisplay}
	$parameters += New-Object PSObject -Property @{Parameter="Com Visible"; Value=$comVisible}
	$parameters += New-Object PSObject -Property @{Parameter="File Version"; Value=$fileVersion}
	$parameters += New-Object PSObject -Property @{Parameter="Assembly Version"; Value=$assemblyVersion}
	$parameters | format-table -property Parameter, Value

	Import-Module (Join-Path -Path $PSScriptRoot -ChildPath "Bool.PowerShell.UpdateAssemblyInfo.dll")

	$files = @()

	if (Test-Path -LiteralPath $assemblyInfoFiles) {
		$file = (Resolve-Path $assemblyInfoFiles).Path
		if ($file -like "*\AssemblyInfo.*") {
			$files += $file
		}
	} else {
		$files = Get-ChildItem $assemblyInfoFiles -Recurse | ForEach-Object {$_.FullName} | Where-Object {$_ -like "*\AssemblyInfo.*"}
	}

	if ($files) {
		Write-Output "Updating:"
		Write-Output $files
		
		Update-AssemblyInfo -Files $files -AssemblyDescription $description -AssemblyConfiguration $configuration -AssemblyCompany $company -AssemblyProduct $product -AssemblyCopyright $copyright -AssemblyTrademark $trademark -AssemblyFileVersion $fileVersion -AssemblyInformationalVersion $informationalVersion -AssemblyVersion $assemblyVersion
	} else {
		Write-VstsTaskError "AssemblyInfo.* file not found using search pattern `'$assemblyInfoFiles`'."
		Write-VstsSetResult -Result "Failed"
	}
} finally {
    Trace-VstsLeavingInvocation $MyInvocation
}