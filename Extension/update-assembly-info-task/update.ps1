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

$errors = 0

function IsNumeric {
	param(
		[strint]
		$value
	)
    return $value -match "^[\d\.]+$"
}

function BuildInvalidVariableMessage {
	param(
		[string]
		$variableName
	)
	return "$variableName contains the variable `$(Invalid). Most likely this is because the default value must be changed to something meaningful."
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
		if ($parameter.Contains("`$(Invalid)")) {
			Write-VstsTaskError (BuildInvalidVariableMessage $displayName)
			$global:errors += 1
		}
		if (!(IsNumeric $parameter)) {
			Write-VstsTaskError "Invalid value for `'$displayName`'. `'$parameter`' is not a numerical value."
			$global:errors += 1
		}
		return $parameter
	}
}

function ValidateInvalid {
	param(
		[string]
		$displayName,
		[string]
		$parameter
	)

	if (![string]::IsNullOrEmpty($parameter)) {
		if ($parameter.Contains("`$(Invalid)")) {
			Write-VstsTaskError (BuildInvalidVariableMessage $displayName)
			$global:errors += 1
		}
	}
}

try {
	# Validate description
	ValidateInvalid "Description" $description

	# Validate configuration
	ValidateInvalid "Configuration" $configuration

	# Validate company
	ValidateInvalid "Company" $company

	# Validate product
	ValidateInvalid "Product" $product

	# Validate copyright
	ValidateInvalid "Copyright" $copyright

	# Validate trademark
	ValidateInvalid "Trademark" $trademark

	# Validate informational version
	ValidateInvalid "Informational Version" $informationalVersion

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

	if ($errors) {
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
		
		Update-AssemblyInfo -Files $files -AssemblyDescription $description -AssemblyConfiguration $configuration -AssemblyCompany $company -AssemblyProduct $product -AssemblyCopyright $copyright -AssemblyTrademark $trademark -AssemblyFileVersion $fileVersion -AssemblyInformationalVersion $informationalVersion
	} else {
		Write-VstsTaskError "AssemblyInfo.* file not found using search pattern `'$assemblyInfoFiles`'."
		Write-VstsSetResult -Result "Failed"
	}
} finally {
    Trace-VstsLeavingInvocation $MyInvocation
}