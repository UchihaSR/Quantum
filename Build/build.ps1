# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

$ErrorActionPreference = 'Stop'

& "$PSScriptRoot/set-env.ps1"
$all_ok = $True

function Build-One {
    param(
        $project
    );

    Write-Host "##[info]Building $project..."
    dotnet build $project `
        -c $Env:BUILD_CONFIGURATION `
        -v $Env:BUILD_VERBOSITY `
        /property:DefineConstants=$Env:ASSEMBLY_CONSTANTS `
        /property:Version=$Env:ASSEMBLY_VERSION `
        /property:QsharpDocsOutDir=$Env:DOCS_OUTDIR

    if  ($LastExitCode -ne 0) {
        Write-Host "##vso[task.logissue type=error;]Failed to build $project."
        $script:all_ok = $False
    }
}

Get-ChildItem (Join-Path $PSScriptRoot '..') -Recurse -Include '*.sln' `
    | ForEach-Object { Build-One $_.FullName }

if (-not $all_ok) {
    throw "At least one test failed execution. Check the logs."
}