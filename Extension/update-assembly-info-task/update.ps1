[CmdletBinding(DefaultParameterSetName = 'None')]
param(
	[Parameter(Mandatory=$true)]
	[ValidateNotNullOrEmpty()]
    [string]
	$assemblyInfoFiles,

	[string]
	$description,

	[string]
	$configuration,
	
	[string]
	$company,

	[string]
	$product,

	[string]
	$copyright,

	[string]
	$trademark,

	[string]
	$fileVersionMajor,

	[string]
	$fileVersionMinor,

	[string]
	$fileVersionBuild,

	[string]
	$fileVersionRevision,

	[string]
	$informationalVersion
)

function Is-Numeric ($value)
{
    return $value -match "^[\d\.]+$"
}

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
		throw "File Version Major must be numeric value"
	}
}

# Validate fileVersionMinor
if ([string]::IsNullOrEmpty($fileVersionMinor)) {
	$fileVersionMinor = "`$(current)"
} else {
	if (!(Is-Numeric($fileVersionMinor))) {
		throw "File Version Minor must be numeric value"
	}
}

# Validate fileVersionBuild
if ([string]::IsNullOrEmpty($fileVersionBuild)) {
	$fileVersionBuild = "`$(current)"
} else {
	if (!(Is-Numeric($fileVersionBuild))) {
		throw "File Version Build must be numeric value"
	}
}

# Validate fileVersionRevision
if ([string]::IsNullOrEmpty($fileVersionRevision)) {
	$fileVersionRevision = "`$(current)"
} else {
	if (!(Is-Numeric($fileVersionRevision))) {
		throw "File Version Revision must be numeric value"
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
Write-Output "Description`t`t: $description"
Write-Output "Configuration`t`t: $configuration"
Write-Output "Company`t`t`t: $company"
Write-Output "Product`t`t`t: $product"
Write-Output "Copyright`t`t: $copyright"
Write-Output "Trademark`t`t: $trademark"
Write-Output "File Version`t`t: $fileVersion"
Write-Output "Informational Version`t: $informationalVersionDisplay"

Import-Module (Join-Path -Path $PSScriptRoot -ChildPath "Bool.PowerShell.UpdateAssemblyInfo.dll")

$files = @()

if (Test-Path -LiteralPath $assemblyInfoFiles) {
	$files += ((Resolve-Path $assemblyInfoFiles).Path -like "*\AssemblyInfo.*")
} else {
	$files = Get-ChildItem $assemblyInfoFiles -Recurse | % {$_.FullName} | Where-Object {$_ -like "*\AssemblyInfo.*"}
}

if ($files) {
	Write-Output "Updating:"
	Write-Output $files
	
	Update-AssemblyInfo -Files $files -AssemblyDescription $description -AssemblyConfiguration $configuration -AssemblyCompany $company -AssemblyProduct $product -AssemblyCopyright $copyright -AssemblyTrademark $trademark -AssemblyFileVersion $fileVersion -AssemblyInformationalVersion $informationalVersion
} else {
	Write-Output "Found no AssemblyInfo.* files to update"
}