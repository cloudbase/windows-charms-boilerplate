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


function Run-InstallHook {
    Param()

    juju-log.exe "Running install hook."
}

function Run-StartHook {
    Param()

    juju-log.exe "Running start hook."
}

function Run-ConfigChangedHook {
    Param()

    juju-log.exe "Running config changed hook."
}

function Run-UpgradeHook {
    Param()

    juju-log.exe "Running upgrade hook."
}

function Run-StopHook {
    Param()

    juju-log.exe "Running stop hook."
}

function Run-RelationNameJoinedHook {
    Param()

    juju-log.exe "Running relationName joined hook."
}

function Run-RelationNameChangedHook {
    Param()

    juju-log.exe "Running relationName changed hook."
}

function Run-RelationNameDepartedHook {
    Param()

    juju-log.exe "Running relationName departed hook."
}

function Run-RelationNameBrokenHook {
    Param()

    juju-log.exe "Running relationName broken hook."
}

Export-ModuleMember -Function Run-InstallHook
Export-ModuleMember -Function Run-StartHook
Export-ModuleMember -Function Run-ConfigChangedHook
Export-ModuleMember -Function Run-UpgradeHook
Export-ModuleMember -Function Run-StopHook
Export-ModuleMember -Function Run-RelationNameJoinedHook
Export-ModuleMember -Function Run-RelationNameChangedHook
Export-ModuleMember -Function Run-RelationNameDepartedHook
Export-ModuleMember -Function Run-RelationNameBrokenHook
