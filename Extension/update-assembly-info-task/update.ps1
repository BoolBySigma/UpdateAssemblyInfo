[CmdletBinding(DefaultParameterSetName = 'None')]
param(
    [string]
	$assemblyInfoFiles
)

# Validate files
if ([string]::IsNullOrEmpty($assemblyInfoFiles)) {
	$assemblyInfoFiles = "**\AssemblyInfo.cs"
}

Import-Module (Join-Path -Path $PSScriptRoot -ChildPath "Bool.PowerShell.UpdateAssemblyInfo.dll") -Verbose

#Set-Location $Env:BUILD_SOURCESDIRECTORY

$files = $assemblyInfoFiles

if (!(Test-Path -LiteralPath $files)) {
Write-Output "Multiple files"
$files = Get-ChildItem $assemblyInfoFiles -Recurse | % {$_.FullName}
} else {
Write-Output "One file"
}

Write-Output $files