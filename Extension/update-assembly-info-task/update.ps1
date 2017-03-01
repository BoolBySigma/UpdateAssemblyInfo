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

function IsNumeric ($value)
{
    return $value -match "^[\d\.]+$"
}

function BuildInvalidVariableMessage($variableName) {
	return "$variableName contains the variable `$(Invalid). Most likely this is because the default value must be changed to something meaningful."
}

try {
	$errors = 0

	# Validate description
	if (![string]::IsNullOrEmpty($description)) {
		if ($description.Contains("`$(Invalid)")) {
			Write-VstsTaskError (BuildInvalidVariableMessage("Description"))
			$errors += 1
		}
	}

	# Validate configuration
	if (![string]::IsNullOrEmpty($configuration)) {
		if ($configuration.Contains("`$(Invalid)")) {
			Write-VstsTaskError (BuildInvalidVariableMessage("Configuration"))
			$errors += 1
		}
	}

	# Validate company
	if (![string]::IsNullOrEmpty($company)) {
		if ($company.Contains("`$(Invalid)")) {
			Write-VstsTaskError (BuildInvalidVariableMessage("Company"))
			$errors += 1
		}
	}

	# Validate product
	if ([string]::IsNullOrEmpty($product)) {
		if ($product.Contains("`$(Invalid)")) {
			Write-VstsTaskError (BuildInvalidVariableMessage("Product"))
			$errors += 1
		}
	}

	# Validate copyright
	if (![string]::IsNullOrEmpty($copyright)) {
		if ($copyright.Contains("`$(Invalid)")) {
			Write-VstsTaskError (BuildInvalidVariableMessage("Copyright"))
			$errors += 1
		}
	}

	# Validate trademark
	if (![string]::IsNullOrEmpty($trademark)) {
		if ($trademark.Contains("`$(Invalid)")) {
			Write-VstsTaskError (BuildInvalidVariableMessage("Trademark"))
			$errors += 1
		}
	}

	# Validate information version
	if (![string]::IsNullOrEmpty($informationalVersion)) {
		if ($informationalVersion.Contains("`$(Invalid)")) {
			Write-VstsTaskError (BuildInvalidVariableMessage("Informational Version"))
			$errors += 1
		}
	}

	# Validate fileVersionMajor
	if ([string]::IsNullOrEmpty($fileVersionMajor)) {
		$fileVersionMajor = "`$(current)"
	} else {
		if ($fileVersionMajor.Contains("`$(Invalid)")) {
			Write-VstsTaskError (BuildInvalidVariableMessage("File Version Major"))
			$errors += 1
		}
		if (!(IsNumeric($fileVersionMajor))) {
			Write-VstsTaskError "Invalid value for File Version Major. `'$fileVersionMajor`' is not a numerical value."
			$errors += 1
		}
	}

	# Validate fileVersionMinor
	if ([string]::IsNullOrEmpty($fileVersionMinor)) {
		$fileVersionMinor = "`$(current)"
	} else {
		if ($fileVersionMinor.Contains("`$(Invalid)")) {
			Write-VstsTaskError (BuildInvalidVariableMessage("File Version Minor"))
			$errors += 1
		}
		if (!(IsNumeric($fileVersionMinor))) {
			Write-VstsTaskError "Invalid value for File Version Minor. `'$fileVersionMinor`' is not a numerical value."
			$errors += 1
		}
	}

	# Validate fileVersionBuild
	if ([string]::IsNullOrEmpty($fileVersionBuild)) {
		$fileVersionBuild = "`$(current)"
	} else {
		if ($fileVersionBuild.Contains("`$(Invalid)")) {
			Write-VstsTaskError (BuildInvalidVariableMessage("File Version Build"))
			$errors += 1
		}
		if (!(IsNumeric($fileVersionBuild))) {
			Write-VstsTaskError "Invalid value for File Version Build. `'$fileVersionBuild`' is not a numerical value."
			$errors += 1
		}
	}

	# Validate fileVersionRevision
	if ([string]::IsNullOrEmpty($fileVersionRevision)) {
		$fileVersionRevision = "`$(current)"
	} else {
		if ($fileVersionRevision.Contains("`$(Invalid)")) {
			Write-VstsTaskError (BuildInvalidVariableMessage("File Version Revision"))
			$errors += 1
		}
		if (!(IsNumeric($fileVersionRevision))) {
			Write-VstsTaskError "Invalid value for File Version Revision. `'$fileVersionRevision`' is not a numerical value."
			$errors += 1
		}
	}

	# Format file version
	$fileVersion = "$fileVersionMajor.$fileVersionMinor.$fileVersionBuild.$fileVersionRevision"

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
		$errors += 1
	}

	if ($errors) {
		Write-VstsTaskError "Failed with $errors error(s)"
		Write-VstsSetResult -Result "Failed"
	}
} finally {
    Trace-VstsLeavingInvocation $MyInvocation
}