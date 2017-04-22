[CmdletBinding()]
param()

Trace-VstsEnteringInvocation $MyInvocation

$global:errors = 0

function Block-InvalidVariable {
    param(
        [string]
        $displayName,
        [string]
        $parameterName,
        [string]
        $parameter
    )

    Write-VstsTaskDebug -Message "Block-InvalidVariable: $parameterName"

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
        $parameterName,
        [string]
        $parameter
    )

    Write-VstsTaskDebug -Message "Block-NonNumericParameter: $parameterName"

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
        $parameterName,
        [string]
        $parameter
    )

    Write-VstsTaskDebug -Message "Block-InvalidVersion: $parameterName"

    if ([string]::IsNullOrEmpty($parameter)) {
        Write-VstsTaskDebug -Message "$parameterName`: `$(current)"
        return "`$(current)"
    }
    else {
        Block-InvalidVariable $displayName $parameterName $parameter
        Block-NonNumericParameter $displayName $parameterName $parameter
        return $parameter
    }
}

function Set-NullIfEmpty {
    param(
        [string]
        $parameterName,
        [string]
        $parameter
    )

    Write-VstsTaskDebug -Message "Set-NullIfEmpty`: $parameterName"

    if ([string]::IsNullOrEmpty($parameter)) {
        Write-VstsTaskDebug -Message "$parameterName`: `$null"
        return $null
    }

    return $parameter
}

try {
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
    $comVisible = Get-VstsInput -Name comVisible -AsBool
	$ensureAttribute = Get-VstsInput -Name ensureAttribute -AsBool

    # Check description
    Block-InvalidVariable "Description" "description" $description

    # Check configuration
    Block-InvalidVariable "Configuration" "configuration" $configuration

    # Check company
    Block-InvalidVariable "Company" "company" $company

    # Check product
    Block-InvalidVariable "Product" "product" $product

    # Check copyright
    Block-InvalidVariable "Copyright" "copyright" $copyright

    # Check trademark
    Block-InvalidVariable "Trademark" "trademark" $trademark

    # Check informational version
    Block-InvalidVariable "Informational Version" "informationalVersion" $informationalVersion

    # Check fileVersionMajor
    $fileVersionMajor = (Block-InvalidVersion "File Version Major" "fileVersionMajor" $fileVersionMajor)

    # Check fileVersionMinor
    $fileVersionMinor = (Block-InvalidVersion "File Version Minor" "fileVersionMinor" $fileVersionMinor)

    # Check fileVersionBuild
    $fileVersionBuild = (Block-InvalidVersion "File Version Build" "fileVersionBuild" $fileVersionBuild)

    # Check fileVersionRevision
    $fileVersionRevision = (Block-InvalidVersion "File Version Revision" "fileVersionRevision" $fileVersionRevision)

    # Check assemblyVersionMajor
    $assemblyVersionMajor = (Block-InvalidVersion "Assembly Version Major" "assemblyVersionMajor" $assemblyVersionMajor)

    # Check assemblyVersionMinor
    $assemblyVersionMinor = (Block-InvalidVersion "Assembly Version Minor" "assemblyVersionMinor" $assemblyVersionMinor)

    # Check assemblyVersionBuild
    $assemblyVersionBuild = (Block-InvalidVersion "Assembly Version Build" "assemblyVersionBuild" $assemblyVersionBuild)

    # Check assemblyVersionRevision
    $assemblyVersionRevision = (Block-InvalidVersion "Assembly Version Revision" "assemblyVersionRevision" $assemblyVersionRevision)

    if ($global:errors) {
        Write-VstsSetResult -Result "Failed" -Message "Failed with $errors error(s)"
    }

    # Format file version
    Write-VstsTaskDebug -Message "formatting file version"
    $fileVersion = "$fileVersionMajor.$fileVersionMinor.$fileVersionBuild.$fileVersionRevision"
    Write-VstsTaskDebug -Message "fileVersion: $fileVersion"

    # Format assembly version
    Write-VstsTaskDebug -Message "formatting assembly version"
    $assemblyVersion = "$assemblyVersionMajor.$assemblyVersionMinor.$assemblyVersionBuild.$assemblyVersionRevision"
    Write-VstsTaskDebug -Message "assmeblyVersion: $assemblyVersion"

    # Format description
    Write-VstsTaskDebug -Message "formatting description"
    $description = $description.Replace("`$(Assembly.Company)", $company)
    $description = $description.Replace("`$(Assembly.Product)", $product)
    $description = $description.Replace("`$(Assembly.Year)", (Get-Date).Year)
    # Leave in for legacy functionality
    $description = $description.Replace("`$(Year)", (Get-Date).Year)
    Write-VstsTaskDebug -Message "description: $description"

    # Format copyright
    Write-VstsTaskDebug -Message "formatting copyright"
    $copyright = $copyright.Replace("`$(Assembly.Company)", $company)
    $copyright = $copyright.Replace("`$(Assembly.Product)", $product)
    $copyright = $copyright.Replace("`$(Assembly.Year)", (Get-Date).Year)
    # Leave in for legacy functionality
    $copyright = $copyright.Replace("`$(Year)", (Get-Date).Year)
    Write-VstsTaskDebug -Message "copyright: $copyright"

    # Format trademark
    Write-VstsTaskDebug -Message "formatting trademark"
    $trademark = $trademark.Replace("`$(Assembly.Company)", $company)
    $trademark = $trademark.Replace("`$(Assembly.Product)", $product)
    Write-VstsTaskDebug -Message "trademark: $trademark"

    # Format informational version
    Write-VstsTaskDebug -Message "formatting informational version"
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
    Write-VstsTaskDebug -Message "informationalVersion: $informationalVersion"

    $informationalVersionDisplay = $informationalVersion.Replace("`$(fileversion)", $fileVersion)
    Write-VstsTaskDebug -Message "informationalVersionDisplay: $informationalVersionDisplay"
    
    # Ensure null values if empty
    $description =          (Set-NullIfEmpty "description" $description)
    $configuration =        (Set-NullIfEmpty "configuration" $configuration)
    $company =              (Set-NullIfEmpty "company" $company)
    $product =              (Set-NullIfEmpty "product" $product)
    $copyright =            (Set-NullIfEmpty "copyright" $copyright)
    $trademark =            (Set-NullIfEmpty "trademark" $trademark)
    $informationalVersion = (Set-NullIfEmpty "informationalVersion" $informationalVersion)

    # Print parameters
    $parameters = @()
    $parameters += New-Object PSObject -Property @{Parameter = "Description"; Value = $description}
    $parameters += New-Object PSObject -Property @{Parameter = "Configuration"; Value = $configuration}
    $parameters += New-Object PSObject -Property @{Parameter = "Company"; Value = $company}
    $parameters += New-Object PSObject -Property @{Parameter = "Product"; Value = $product}
    $parameters += New-Object PSObject -Property @{Parameter = "Copyright"; Value = $copyright}
    $parameters += New-Object PSObject -Property @{Parameter = "Trademark"; Value = $trademark}
    $parameters += New-Object PSObject -Property @{Parameter = "Informational Version"; Value = $informationalVersionDisplay}
    $parameters += New-Object PSObject -Property @{Parameter = "Com Visible"; Value = $comVisible}
    $parameters += New-Object PSObject -Property @{Parameter = "File Version"; Value = $fileVersion}
    $parameters += New-Object PSObject -Property @{Parameter = "Assembly Version"; Value = $assemblyVersion}
    $parameters += New-Object PSObject -Property @{Parameter = "Add Missing Attriute"; Value = $ensureAttribute}
    $parameters | format-table -property Parameter, Value

    # Update files
    Import-Module (Join-Path -Path $PSScriptRoot -ChildPath "Bool.PowerShell.UpdateAssemblyInfo.dll")

    $files = @()


    Write-VstsTaskDebug -Message "testing assembly info files path"
    if (Test-Path -LiteralPath $assemblyInfoFiles) {
        Write-VstsTaskDebug -Message "assembly info file path is absolute"
        $files += (Resolve-Path $assemblyInfoFiles).Path
    }
    else {
        Write-VstsTaskDebug -Message "getting assembly info files based on minimatch"
        $files = Get-ChildItem $assemblyInfoFiles -Recurse | ForEach-Object {$_.FullName}
    }

    if ($files) {
        Write-VstsTaskDebug -Message "files:"
        Write-VstsTaskDebug -Message "$files"
        Write-Output "Updating..."
        $updateResult = Update-AssemblyInfo -Files $files -AssemblyDescription $description -AssemblyConfiguration $configuration -AssemblyCompany $company -AssemblyProduct $product -AssemblyCopyright $copyright -AssemblyTrademark $trademark -AssemblyFileVersion $fileVersion -AssemblyInformationalVersion $informationalVersion -AssemblyVersion $assemblyVersion -ComVisible $comVisible -EnsureAttribute $ensureAttribute

        Write-Output "Updated:"
        $result += $updateResult | ForEach-Object { New-Object PSObject -Property @{File = $_.File; FileVersion = $_.FileVersion; AssemblyVersion = $_.AssemblyVersion } }
        $result | format-table -property File, FileVersion, AssemblyVersion
		
        Write-VstsTaskDebug -Message "exporting variables"
		$firstResult = $result[0]
        Write-VstsTaskDebug -Message "firstResult: $firstResult"
        Write-VstsSetVariable -Name 'Assembly.FileVersion' -Value $firstResult.FileVersion
        Write-VstsSetVariable -Name 'Assembly.AssemblyVersion' -Value $firstResult.AssemblyVersion
    }
    else {
        Write-VstsSetResult -Result "Failed" -Message "AssemblyInfo.* file not found using search pattern `'$assemblyInfoFiles`'."
    }
}
catch {
    Write-VstsSetResult -Result "Failed" -Message $_.Exception.Message
}
finally {
    Trace-VstsLeavingInvocation $MyInvocation
}
