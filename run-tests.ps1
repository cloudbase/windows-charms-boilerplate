#ps1_sysnative

# Copyright 2014 Cloudbase Solutions Srl
#
#    Licensed under the Apache License, Version 2.0 (the "License"); you may
#    not use this file except in compliance with the License. You may obtain
#    a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#    WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#    License for the specific language governing permissions and limitations
#    under the License.

param($TestModule="CharmHelpers")
$ErrorActionPreference = "Stop"

function Log {
    param($message="")
    Write-Host $message
}

function TestIn-Path {
    param($path=".",
          $pesterPath=".\lib\Modules")

    $fullPath = Resolve-Path $path
    $pesterFullPath = Resolve-Path $pesterPath
    $initialPSModulePath = $env:PSModulePath
    $env:PSModulePath = $env:PSModulePath + ";$pesterFullPath"
    
    try {
        Log "Executing tests in the folder $fullPath"
        pushd $fullPath
        Invoke-Pester
    } catch {
        Log "Tests have failed."
        Log $_.Exception.ToString()
    } finally {
        popd
        $env:PSModulePath = $initialPSModulePath
    }
} 

$testTypeCharmHelpersModules = "CharmHelpers"
$charmHelpersTestPath = ".\lib\Modules\CharmHelpers\Tests"
$testTypeCharmMainModule = "CharmMainModule"
$mainModuleTestPath = ".\Tests"

if ($TestModule -ne $testTypeCharmHelpersModules -and $TestModule -ne $testTypeCharmMainModule) {
    throw "The test module should be '$testTypeCharmHelpersModules' or '$testTypeCharmMainModule'"
} else {
    if ($TestModule -eq $testTypeCharmHelpersModules) {
        TestIn-Path $charmHelpersTestPath
    }
    if ($TestModule -eq $testTypeCharmMainModule) {
        TestIn-Path $mainModuleTestPath
    }
}




