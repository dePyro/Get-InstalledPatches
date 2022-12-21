<# 
.SYNOPSIS
    Gets all installed patches.
.DESCRIPTION 
    Gets all currently installed patches and optionally exports them into a CSV file.
 
.NOTES 
    Written by dePyro, 2022.
 
.Parameter Destination 
    Optional: Path to the destination CSV file.
.Parameter Delimiter
    Optional: Delimiter to be used in the CSV file.
.Parameter Encoding
    Optional: Encoding to be used in the CSV file. Choice from UTF8, UTF7, UTF32, ASCII, Unicode, BigEndianUnicode, OEM
.Parameter CliOnly
    Optional: Output results only to shell. Disables the other parameters.
#>

[CmdletBinding(DefaultParameterSetName='Export')]
Param(

    [Parameter (ParameterSetName='Export', Mandatory=$false)][string]$Destination = $PSScriptRoot + "\InstalledPatches.csv",
    [Parameter (ParameterSetName='Export', Mandatory=$false)][string]$Delimiter = ",",
    [Parameter (ParameterSetName='Export', Mandatory=$false)][string][ValidateSet("UTF8","UTF7","UTF32","ASCII","Unicode","BigEndianUnicode","OEM")]$Encoding = "UTF8",
    [Parameter (ParameterSetName='Cli', Mandatory=$false)][switch]$CliOnly = $false
)

#Gets all installed patches
try{

    $installedPatches = Get-HotFix -ErrorAction Stop | Sort-Object InstalledOn -Descending
}
catch{

    throw $Error[0] 
}

if($CliOnly){

    #Outputs all installed patches to command line
    Write-Output $installedPatches
}
else{

    #Gets path without filename for testing
    $pathOnly = $Destination | Split-Path -Parent

    #Tests if destination path is valid
    if(-not $(Test-Path $pathOnly)){

        Write-Error "Destination path $pathOnly invalid"
        throw "Script ended due to invalid path"
    }

    #Gets only interesting information to export
    $installedPatchesToExport = $installedPatches | Select-Object PSComputerName,InstalledOn,HotFixID,Description,InstalledBy,Caption

    #Exports installed patches to a CSV file with the chosen parameters
    $installedPatchesToExport | Export-Csv -Path $Destination -Encoding $Encoding -Delimiter $Delimiter -NoTypeInformation
}