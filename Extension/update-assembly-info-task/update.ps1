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
	$fileVersionMajor,

	[string]
	$fileVersionMinor,

	[string]
	$fileVersionBuild,

	[string]
	$fileVersionRevision
)

function Is-Numeric ($Value)
{
    return $Value -match "^[\d\.]+$"
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
if ($copyright.Contains("`$(Company)")) {
	if ([string]::IsNullOrEmpty($company)) {
		throw "When using variable `$(Company), Company must be set"
	}
	$copyright = $copyright.Replace("`$(Company)", $company)
}
$copyright = $copyright.Replace("`$(Year)", (Get-Date).Year)

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

$fileVersion = "$fileVersionMajor.$fileVersionMinor.$fileVersionBuild.$fileVersionRevision"

Write-Output "Description`t: $description"
Write-Output "Configuration`t: $configuration"
Write-Output "Company`t`t: $company"
Write-Output "Product`t`t: $product"
Write-Output "Copyright`t: $copyright"
Write-Output "File Version`t: $fileVersion"

Import-Module (Join-Path -Path $PSScriptRoot -ChildPath "Bool.PowerShell.UpdateAssemblyInfo.dll") -Verbose

$files = @()

if (Test-Path -LiteralPath $assemblyInfoFiles) {
	$files += (Resolve-Path $assemblyInfoFiles).Path
} else {
	$files = Get-ChildItem $assemblyInfoFiles -Recurse | % {$_.FullName}
}

if ($files) {
Write-Output $files.count
Write-Output $files

Update-AssemblyInfo -Files $files -AssemblyDescription $description -AssemblyConfiguration $configuration -AssemblyCompany $company -AssemblyProduct $product -AssemblyCopyright $copyright -AssemblyFileVersion $fileVersion

} else {

}