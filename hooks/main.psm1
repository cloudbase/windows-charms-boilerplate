# Copyright 2016 Cloudbase Solutions Srl
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


Import-Module JujuLogging


function Invoke-InstallHook {
    Write-JujuWarning "Running install hook."
}

function Invoke-ConfigChangedHook {
    Write-JujuWarning "Running config changed hook."
}

function Invoke-UpgradeHook {
    Write-JujuWarning "Running upgrade hook."
}

function Invoke-StartHook {
    Write-JujuWarning "Running start hook."
}

function Invoke-StopHook {
    Write-JujuWarning "Running stop hook."
}

function Invoke-RelationNameJoinedHook {
    Write-JujuWarning "Running relationName joined hook."
}

function Invoke-RelationNameChangedHook {
    Write-JujuWarning "Running relationName changed hook."
}

function Invoke-RelationNameDepartedHook {
    Write-JujuWarning "Running relationName departed hook."
}

function Invoke-RelationNameBrokenHook {
    Write-JujuWarning "Running relationName broken hook."
}

Export-ModuleMember -Function @(
    'Invoke-InstallHook',
    'Invoke-ConfigChangedHook',
    'Invoke-UpgradeHook',
    'Invoke-StartHook',
    'Invoke-StopHook',
    'Invoke-RelationNameJoinedHook',
    'Invoke-RelationNameChangedHook',
    'Invoke-RelationNameDepartedHook',
    'Invoke-RelationNameBrokenHook'
)
