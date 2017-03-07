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

$global:errors = 0

function IsNumeric {
	param(
		[string]
		$value
	)
    return $value -match "^[\d\.]+$"
}

function Write-InvalidVariableError {
	param(
		[string]
		$displayName
	)
	Write-VstsTaskError "$displayName contains the variable `$(Invalid). Most likely this is because the default value must be changed to something meaningful."
}

function Block-InvalidVariable {
	param(
		[string]
		$displayName,
		[string]
		$parameter
	)

	if (![string]::IsNullOrEmpty($parameter)) {
		if ($parameter.Contains("`$(Invalid)")) {
			Write-InvalidVariableError $displayName
			$global:errors += 1
		}
	}
}

function ValidateVersion {
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
		<#if ($parameter.Contains("`$(Invalid)")) {
			Write-InvalidVariableError $displayName
			$global:errors += 1
		}#>
		if (!(IsNumeric $parameter)) {
			Write-VstsTaskError "Invalid value for `'$displayName`'. `'$parameter`' is not a numerical value."
			$global:errors += 1
		}
		return $parameter
	}
}

try {
	# Validate description
	Block-InvalidVariable "Description" $description

	# Validate configuration
	Block-InvalidVariable "Configuration" $configuration

	# Validate company
	Block-InvalidVariable "Company" $company

	# Validate product
	Block-InvalidVariable "Product" $product

	# Validate copyright
	Block-InvalidVariable "Copyright" $copyright

	# Validate trademark
	Block-InvalidVariable "Trademark" $trademark

	# Validate informational version
	Block-InvalidVariable "Informational Version" $informationalVersion

	# Validate fileVersionMajor
	$fileVersionMajor = (ValidateVersion "File Version Major" $fileVersionMajor)

	# Validate fileVersionMinor
	$fileVersionMinor = (ValidateVersion "File Version Minor" $fileVersionMinor)

	# Validate fileVersionBuild
	$fileVersionBuild = (ValidateVersion "File Version Build" $fileVersionBuild)

	# Validate fileVersionRevision
	$fileVersionRevision = (ValidateVersion "File Version Revision" $fileVersionRevision)

	# Validate assemblyVersionMajor
	$assemblyVersionMajor = (ValidateVersion "Assembly Version Major" $assemblyVersionMajor)

	# Validate assemblyVersionMinor
	$assemblyVersionMinor = (ValidateVersion "Assembly Version Minor" $assemblyVersionMinor)

	# Validate assemblyVersionBuild
	$assemblyVersionBuild = (ValidateVersion "Assembly Version Build" $assemblyVersionBuild)

	# Validate assemblyVersionRevision
	$assemblyVersionRevision = (ValidateVersion "Assembly Version Revision" $assemblyVersionRevision)

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
	$parameters += New-Object PSObject -Property @{Parameter="File Version"; Value=$fileVersion}
	$parameters += New-Object PSObject -Property @{Parameter="Assembly Version"; Value=$assemblyVersion}
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
		
		Update-AssemblyInfo -Files $files -AssemblyDescription $description -AssemblyConfiguration $configuration -AssemblyCompany $company -AssemblyProduct $product -AssemblyCopyright $copyright -AssemblyTrademark $trademark -AssemblyFileVersion $fileVersion -AssemblyInformationalVersion $informationalVersion -AssemblyVersion $assemblyVersion
	} else {
		Write-VstsTaskError "AssemblyInfo.* file not found using search pattern `'$assemblyInfoFiles`'."
		Write-VstsSetResult -Result "Failed"
	}
} finally {
    Trace-VstsLeavingInvocation $MyInvocation
}