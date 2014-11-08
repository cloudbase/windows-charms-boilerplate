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
Import-Module $modulePath

InModuleScope $moduleName {
    # Describe block of the function to be tested
    Describe "Main" {
        # Test case when function execution has no errors
        Context "Main function is executed successfully" {
            Mock Write-JujuLog { }

            $fakeArg = "Fake Argument"
            # Call the function with fake  once with are done with mocking
            Main $fakeArg

            # Check if the mock was called with the correct parameters
            It "should write a message on the stdout" {
                $expectedMsg = "Running $fakeArg"
                Assert-MockCalled Write-JujuLog -Exactly 1 -ParameterFilter {
                    ($Message -eq $expectedMsg)
                }
            }
        }
    }
}

Remove-Module $moduleName
