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

$testsDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$charmDir = Split-Path -Parent $testsDir
$moduleName = "main"
$modulePath = Join-Path $charmDir "hooks\${moduleName}.psm1"

Import-Module $modulePath


InModuleScope $moduleName {
    # Describe block of the function to be tested
    Describe "Invoke-InstallHook" {
        # Test case when function execution has no errors
        Context "Main function is executed successfully" {
            Mock Write-JujuWarning { } -Verifiable

            Invoke-InstallHook

            It "should call the juju logger" {
                Assert-VerifiableMocks
            }
        }
    }

    Describe "Invoke-StartHook" {
        # Test case when function execution has no errors
        Context "Main function is executed successfully" {
            Mock Write-JujuWarning { } -Verifiable

            Invoke-StartHook

            It "should call the juju logger" {
                Assert-VerifiableMocks
            }
        }
    }

    Describe "Invoke-ConfigChangedHook" {
        # Test case when function execution has no errors
        Context "Main function is executed successfully" {
            Mock Write-JujuWarning { } -Verifiable

            Invoke-ConfigChangedHook

            It "should call the juju logger" {
                Assert-VerifiableMocks
            }
        }
    }

    Describe "Invoke-UpgradeHook" {
        # Test case when function execution has no errors
        Context "Main function is executed successfully" {
            Mock Write-JujuWarning { } -Verifiable

            Invoke-UpgradeHook

            It "should call the juju logger" {
                Assert-VerifiableMocks
            }
        }
    }

    Describe "Invoke-StopHook" {
        # Test case when function execution has no errors
        Context "Main function is executed successfully" {
            Mock Write-JujuWarning { } -Verifiable

            Invoke-StopHook

            It "should call the juju logger" {
                Assert-VerifiableMocks
            }
        }
    }

    Describe "Invoke-RelationNameJoinedHook" {
        # Test case when function execution has no errors
        Context "Main function is executed successfully" {
            Mock Write-JujuWarning { } -Verifiable

            Invoke-RelationNameJoinedHook

            It "should call the juju logger" {
                Assert-VerifiableMocks
            }
        }
    }

    Describe "Invoke-RelationNameChangedHook" {
        # Test case when function execution has no errors
        Context "Main function is executed successfully" {
            Mock Write-JujuWarning { } -Verifiable

            Invoke-RelationNameChangedHook

            It "should call the juju logger" {
                Assert-VerifiableMocks
            }
        }
    }

    Describe "Invoke-RelationNameDepartedHook" {
        # Test case when function execution has no errors
        Context "Main function is executed successfully" {
            Mock Write-JujuWarning { } -Verifiable

            Invoke-RelationNameDepartedHook

            It "should call the juju logger" {
                Assert-VerifiableMocks
            }
        }
    }

    Describe "Invoke-RelationNameBrokenHook" {
        # Test case when function execution has no errors
        Context "Main function is executed successfully" {
            Mock Write-JujuWarning { } -Verifiable

            Invoke-RelationNameBrokenHook

            It "should call the juju logger" {
                Assert-VerifiableMocks
            }
        }
    }
}

Remove-Module $moduleName
