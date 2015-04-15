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

$modulePath = (Resolve-Path "..\hooks\main.psm1").Path
$moduleName = $modulePath.Split('\')[-1].Split('.')[0]
Import-Module $modulePath -Force -DisableNameChecking

InModuleScope $moduleName {

    # Describe block of the function to be tested
    Describe "Run-InstallHook" {
        # Test case when function execution has no errors
        Context "Main function is executed successfully" {
           Mock juju-log.exe { } -Verifiable

            Run-InstallHook

            It "should call the juju logger" {
                Assert-VerifiableMocks
            }
        }
    }

    Describe "Run-StartHook" {
        # Test case when function execution has no errors
        Context "Main function is executed successfully" {
           Mock juju-log.exe { } -Verifiable

            Run-StartHook

            It "should call the juju logger" {
                Assert-VerifiableMocks
            }
        }
    }

    Describe "Run-ConfigChangedHook" {
        # Test case when function execution has no errors
        Context "Main function is executed successfully" {
           Mock juju-log.exe { } -Verifiable

            Run-ConfigChangedHook

            It "should call the juju logger" {
                Assert-VerifiableMocks
            }
        }
    }

    Describe "Run-UpgradeHook" {
        # Test case when function execution has no errors
        Context "Main function is executed successfully" {
           Mock juju-log.exe { } -Verifiable

            Run-UpgradeHook

            It "should call the juju logger" {
                Assert-VerifiableMocks
            }
        }
    }

    Describe "Run-StopHook" {
        # Test case when function execution has no errors
        Context "Main function is executed successfully" {
           Mock juju-log.exe { } -Verifiable

            Run-StopHook

            It "should call the juju logger" {
                Assert-VerifiableMocks
            }
        }
    }

    Describe "Run-RelationNameJoinedHook" {
        # Test case when function execution has no errors
        Context "Main function is executed successfully" {
           Mock juju-log.exe { } -Verifiable

            Run-RelationNameJoinedHook

            It "should call the juju logger" {
                Assert-VerifiableMocks
            }
        }
    }

    Describe "Run-RelationNameChangedHook" {
        # Test case when function execution has no errors
        Context "Main function is executed successfully" {
           Mock juju-log.exe { } -Verifiable

            Run-RelationNameChangedHook

            It "should call the juju logger" {
                Assert-VerifiableMocks
            }
        }
    }

    Describe "Run-RelationNameDepartedHook" {
        # Test case when function execution has no errors
        Context "Main function is executed successfully" {
           Mock juju-log.exe { } -Verifiable

            Run-RelationNameDepartedHook

            It "should call the juju logger" {
                Assert-VerifiableMocks
            }
        }
    }

    Describe "Run-RelationNameBrokenHook" {
        # Test case when function execution has no errors
        Context "Main function is executed successfully" {
           Mock juju-log.exe { } -Verifiable

            Run-RelationNameBrokenHook

            It "should call the juju logger" {
                Assert-VerifiableMocks
            }
        }
    }
}

Remove-Module $moduleName
