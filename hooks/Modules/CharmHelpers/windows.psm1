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

$utilsModulePath = Join-Path $PSScriptRoot "utils.psm1"
Import-Module -Force -DisableNameChecking $utilsModulePath
$jujuModulePath = Join-Path $PSScriptRoot "juju.psm1"
Import-Module -Force -DisableNameChecking $jujuModulePath

function Start-ProcessRedirect {
    param(
        [Parameter(Mandatory=$true)]
        [array]$Filename,
        [Parameter(Mandatory=$true)]
        [array]$Arguments,
        [Parameter(Mandatory=$false)]
        [array]$Domain,
        [Parameter(Mandatory=$false)]
        [array]$Username,
        [Parameter(Mandatory=$false)]
        $SecPassword
    )

    $pinfo = New-Object System.Diagnostics.ProcessStartInfo
    $pinfo.FileName = $Filename
    if ($Domain -ne $null) {
        $pinfo.Username = $Username
        $pinfo.Password = $secPassword
        $pinfo.Domain = $Domain
    }
    $pinfo.CreateNoWindow = $true
    $pinfo.RedirectStandardError = $true
    $pinfo.RedirectStandardOutput = $true
    $pinfo.UseShellExecute = $false
    $pinfo.LoadUserProfile = $true
    $pinfo.Arguments = $Arguments
    $p = New-Object System.Diagnostics.Process
    $p.StartInfo = $pinfo
    $p.Start() | Out-Null
    $p.WaitForExit()

    $stdout = $p.StandardOutput.ReadToEnd()
    $stderr = $p.StandardError.ReadToEnd()
    Write-JujuLog "stdout: $stdout"
    Write-JujuLog "stderr: $stderr"

    return $p
}

function Is-ComponentInstalled {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Name
    )

    $component = Get-WmiObject -Class Win32_Product | `
                     Where-Object { $_.Name -Match $Name}

    return ($component -ne $null)
}

function Rename-Hostname {
    $jujuUnitName = ${env:JUJU_UNIT_NAME}.split('/')
    if ($jujuUnitName[0].Length -ge 15) {
        $jujuName = $jujuUnitName[0].substring(0, 12)
    } else {
        $jujuName = $jujuUnitName[0]
    }
    $newHostname = $jujuName + $jujuUnitName[1]

    if ($env:computername -ne $newHostname) {
        Rename-Computer -NewName $newHostname
        ExitFrom-JujuHook -WithReboot
    }
}

function Create-ADUsers {
    param(
        [Parameter(Mandatory=$true)]
        $UsersToAdd,
        [Parameter(Mandatory=$true)]
        [string]$AdminUsername,
        [Parameter(Mandatory=$true)]
        $AdminPassword,
        [Parameter(Mandatory=$true)]
        [string]$Domain,
        [Parameter(Mandatory=$true)]
        [string]$DCName,
        [Parameter(Mandatory=$true)]
        [string]$MachineName
    )

    $dcsecpassword = ConvertTo-SecureString $AdminPassword -AsPlainText -Force
    $dccreds = New-Object System.Management.Automation.PSCredential("$Domain\$AdminUsername", $dcsecpassword)
    $session = New-PSSession -ComputerName $DCName -Credential $dccreds
    Import-PSSession -Session $session -CommandName New-ADUser, Get-ADUser, Set-ADAccountPassword

    foreach($user in $UsersToAdd){
        $username = $user['Name']
        $password = $user['Password']
        $alreadyUser = $False
        try{
            $alreadyUser = (Get-ADUser $username) -ne $Null
        }
        catch{
            $alreadyUser = $False
        }

        $securePassword = ConvertTo-SecureString $password -AsPlainText -Force
        if($alreadyUser -eq $False){
            $Description = "AD user"
            New-ADUser -Name $username -AccountPassword $securePassword -Description $Description -Enabled $True

            $User = [ADSI]("WinNT://$Domain/$username")
            $Group = [ADSI]("WinNT://$MachineName/Administrators")
            $Group.PSBase.Invoke("Add",$User.PSBase.Path)
        }
        else{
            Write-JujuLog "User already addded"
            Set-ADAccountPassword -NewPassword $securePassword -Identity $username
        }
    }

    $session | Remove-PSSession
}

function Change-ServiceLogon {
    param(
        [Parameter(Mandatory=$true)]
        $Services,
        [Parameter(Mandatory=$true)]
        [string]$UserName,
        [Parameter(Mandatory=$false)]
        $Password
    )

    $Services | ForEach-Object { $_.Change($null,$null,$null,$null,$null,$null,$UserName,$Password) }
}

function Get-Subnet {
    param(
        [Parameter(Mandatory=$true)]
        $IP,
        [Parameter(Mandatory=$true)]
        $Netmask
    )

    $class = 32
    $netmaskClassDelimiter = "255"
    $netmaskSplit = $Netmask -split "[.]"
    $ipSplit = $IP -split "[.]"
    for ($i = 0; $i -lt 4; $i++) {
        if ($netmaskSplit[$i] -ne $netmaskClassDelimiter) {
            $class -= 8
            $ipSplit[$i] = "0"
        }
    }

    $fullSubnet = ($ipSplit -join ".") + "/" + $class
    return $fullSubnet
}

function Install-WindowsFeatures {
    param(
        [Parameter(Mandatory=$true)]
        [array]$Features
    )

    $rebootNeeded = $false
    foreach ($feature in $Features) {
        $state = ExecuteWith-Retry -Command {
            Install-WindowsFeature -Name $feature -ErrorAction Stop
        }
        if ($state.Success -eq $true) {
            if ($state.RestartNeeded -eq 'Yes') {
                $rebootNeeded = $true
            }
        } else {
            throw "Install failed for feature $feature"
        }
    }

    if ($rebootNeeded -eq $true) {
        ExitFrom-JujuHook -WithReboot
    }
}

function Get-CharmStateKeyPath () {
    return "HKLM:\SOFTWARE\Wow6432Node\Cloudbase Solutions"
}

function Set-CharmState {
    param(
        [Parameter(Mandatory=$true)]
        [string]$CharmName,
        [Parameter(Mandatory=$true)]
        [string]$Key,
        [Parameter(Mandatory=$true)]
        [string]$Val
    )

    $keyPath = Get-CharmStateKeyPath
    $fullKey = ($CharmName + $Key)
    $property = New-ItemProperty -Path $keyPath `
                                 -Name $fullKey `
                                 -Value $Val `
                                 -PropertyType String `
                                 -ErrorAction SilentlyContinue

    if ($property -eq $null) {
        Set-ItemProperty -Path $keyPath -Name $fullKey -Value $Val
    }
}

function Get-CharmState {
    param(
        [Parameter(Mandatory=$true)]
        [string]$CharmName,
        [Parameter(Mandatory=$true)]
        [string]$Key
    )

    $keyPath = Get-CharmStateKeyPath
    $fullKey = ($CharmName + $Key)
    $property = Get-ItemProperty -Path $keyPath `
                                 -Name $fullKey `
                                 -ErrorAction SilentlyContinue

    if ($property -ne $null) {
        $state = Select-Object -InputObject $property -ExpandProperty $fullKey
        return $state
    } else {
        return $null
    }
}

function Create-LocalAdmin {
    param(
        [Parameter(Mandatory=$true)]
        [string]$LocalAdminUsername,
        [Parameter(Mandatory=$true)]
        [string]$LocalAdminPassword
    )

    $existentUser = Get-WmiObject -Class Win32_Account `
                                  -Filter "Name = '$LocalAdminUsername'"
    if ($existentUser -eq $null) {
        $computer = [ADSI]"WinNT://$env:computername"
        $localAdmin = $computer.Create("User", $LocalAdminUsername)
        $localAdmin.SetPassword($LocalAdminPassword)
        $localAdmin.SetInfo()
        $LocalAdmin.FullName = $LocalAdminUsername
        $LocalAdmin.SetInfo()
        # UserFlags = Logon script | Normal user | No pass expiration
        $LocalAdmin.UserFlags = 1 + 512 + 65536
        $LocalAdmin.SetInfo()
    } else {
        Execute-ExternalCommand -Command {
            net.exe user $LocalAdminUsername $LocalAdminPassword
        } -ErrorMessage "Failed to create new user"
    }

    $localAdmins = Execute-ExternalCommand -Command {
        net.exe localgroup Administrators
    } -ErrorMessage "Failed to get local administrators"

    # Assign user to local admins groups if he isn't there
    $isLocalAdmin = ($localAdmins -match $LocalAdminUsername) -ne 0
    if ($isLocalAdmin -eq $false) {
        Execute-ExternalCommand -Command {
            net.exe localgroup Administrators $LocalAdminUsername /add
        } -ErrorMessage "Failed to add user to local admins group"
    }
}

function Get-DomainName {
    param(
        [Parameter(Mandatory=$true)]
        [string]$FQDN
    )

    $fqdnParts = $FQDN.split(".")
    $domainNameParts = $fqdnParts[0..($fqdnParts.Length - 2)]
    $domainName = $domainNameParts -join '.'

    return $domainName
}

function Get-ADCredential {
    param(
        [Parameter(Mandatory=$true)]
        $ADParams
    )

    $adminUsername = $ADParams["ad_username"]
    $adminPassword = $ADParams["ad_password"]
    $domain = Get-DomainName $ADParams["ad_domain"]
    $passwordSecure = ConvertTo-SecureString $adminPassword -AsPlainText -Force
    $adCredential = New-Object PSCredential("$domain\$adminUsername",
                                             $passwordSecure)

    return $adCredential
}

function Set-DNS {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Interface,
        [Parameter(Mandatory=$true)]
        [array]$DNSIPs
    )

    Set-DnsClientServerAddress -InterfaceAlias $Interface `
                               -ServerAddresses $DNSIPs
}

function Get-NetAdapterName {
    param(
        [switch]$Primary
    )

    $primaryEthernetNames = @(
        "Management0",
        "Ethernet0"
    )

    $netAdapters = Get-NetAdapter
    foreach ($adapter in $netAdapters) {
        if ($Primary -eq $true) {
            if ($primaryEthernetNames -match $adapter.Name) {
                return $adapter.Name
            }
        } else {
            if ($primaryEthernetNames -notmatch $adapter.Name) {
                return $adapter.Name
            }
        }
    }

    return $null
}

function Get-PrimaryNetAdapterName {
    return (Get-NetAdapterName)
}

function Get-SecondaryNetAdapterName {
    return (Get-NetAdapterName -Primary)
}

function Join-Domain {
    param(
        [Parameter(Mandatory=$true)]
        [string]$FQDN,
        [Parameter(Mandatory=$true)]
        [string]$DomainCtrlIP,
        [Parameter(Mandatory=$true)]
        $LocalCredential,
        [Parameter(Mandatory=$true)]
        $ADCredential
    )

    $netAdapterName = Get-PrimaryNetAdapterName
    if ($netAdapterName -eq $null) {
        $netAdapterName = Get-SecondaryNetAdapterName
    }
    Set-DNS $netAdapterName $DomainCtrlIP

    $domainName = Get-DomainName $FQDN
    Add-Computer -LocalCredential $LocalCredential `
                 -Credential $ADCredential `
                 -Domain $domainName
}

function Is-InDomain {
    param(
        [Parameter(Mandatory=$true)]
        [string]$WantedDomain
    )

    $currentDomain = (Get-WmiObject -Class `
                          Win32_ComputerSystem).Domain.ToLower()
    $comparedDomain = ($WantedDomain).ToLower()
    $inDomain = $currentDomain.Equals($comparedDomain)

    return $inDomain
}

function New-NetstatObject {
    param(
        [Parameter(Mandatory=$True)]
        $Properties
    )

    $process = Get-Process | Where-Object { $_.Id -eq $Properties.PID }
    $processName = $process.ProcessName

    $processObject = New-Object psobject -property @{
        Protocol      = $Properties.Protocol
        LocalAddress  = $Properties.LAddress
        LocalPort     = $Properties.LPort
        RemoteAddress = $Properties.RAddress
        RemotePort    = $Properties.RPort
        State         = $Properties.State
        ID            = [int]$Properties.PID
        ProcessName   = $processName
    }

    return $processObject
}

# It works only for command: netstat -ano
function Get-NetstatObjects {
    $null, $null, $null, $null,
    $netstatOutput = Execute-ExternalCommand -Command {
        netstat -ano
    } -ErrorMessage "Failed to execute netstat"

    [regex]$regexTCP = '(?<Protocol>\S+)\s+(?<LAddress>\S+):(?<LPort>\S+)' +
            '\s+(?<RAddress>\S+):(?<RPort>\S+)\s+(?<State>\S+)\s+(?<PID>\S+)'
    [regex]$regexUDP = '(?<Protocol>\S+)\s+(?<LAddress>\S+):(?<LPort>\S+)' +
                       '\s+(?<RAddress>\S+):(?<RPort>\S+)\s+(?<PID>\S+)'
    $objects = @()

    foreach ($line in $netstatOutput) {
        switch -regex ($line.Trim()) {
            $regexTCP {
                $process = New-NetstatObject -Properties $matches
                $objects = $objects + $process
                continue
            }
            $regexUDP {
                $process = New-NetstatObject -Properties $matches
                $objects = $objects + $process
                continue
            }
        }
    }

    return $objects
}

function Add-WindowsUser {
    param(
        [parameter(Mandatory=$true)]
        [string]$Username,
        [parameter(Mandatory=$true)]
        [string]$Password
    )

    Execute-ExternalCommand -Command {
        NET.EXE USER $Username $Password '/ADD'
    } -ErrorMessage "Failed to create new user"
}

function Delete-WindowsUser {
    param(
        [parameter(Mandatory=$true)]
        [string]$Username
    )

    Execute-ExternalCommand -Command {
        NET.EXE USER $Username '/DELETE'
    } -ErrorMessage "Failed to create new user"
}


# ALIASES

function Is-In-Domain {
    param(
        [Parameter(Mandatory=$true)]
        [string]$WantedDomain
    )

    return (Is-InDomain $WantedDomain)
}

function Get-Domain-Name {
    param(
        [Parameter(Mandatory=$true)]
        [string]$FullDomainName
    )

    return (Get-DomainName $FullDomainName)
}

function Create-Local-Admin {
    param(
        [Parameter(Mandatory=$true)]
        [string]$LocalAdminUsername,
        [Parameter(Mandatory=$true)]
        [string]$LocalAdminPassword
    )

    Create-LocalAdmin $LocalAdminUsername $LocalAdminPassword
}

function Get-Ad-Credential {
    param(
        [Parameter(Mandatory=$true)]
        $params
    )

    return (Get-ADCredential $params)
}

function Join-Any-Domain {
    param(
        [Parameter(Mandatory=$true)]
        [string]$domain,
        [Parameter(Mandatory=$true)]
        [string]$domainCtrlIp,
        [Parameter(Mandatory=$true)]
        $localCredential,
        [Parameter(Mandatory=$true)]
        $adCredential
    )

    Join-Domain $domain $domainCtrlIp $localCredential $adCredential
}

function Is-Component-Installed {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Name
    )

    return (Is-ComponentInstalled $Name)
}

function Start-Process-Redirect {
    param(
        [Parameter(Mandatory=$true)]
        [array]$Filename,
        [Parameter(Mandatory=$true)]
        [array]$Arguments,
        [Parameter(Mandatory=$false)]
        [array]$Domain,
        [Parameter(Mandatory=$false)]
        [array]$Username,
        [Parameter(Mandatory=$false)]
        $SecPassword
    )

    return (Start-ProcessRedirect $FileName `
                                   $Arguments `
                                   $Domain `
                                   $Username `
                                   $SecPassword)
}

function Create-AD-Users {
    param(
        [Parameter(Mandatory=$true)]
        $UsersToAdd,
        [Parameter(Mandatory=$true)]
        [string]$AdminUsername,
        [Parameter(Mandatory=$true)]
        $AdminPassword,
        [Parameter(Mandatory=$true)]
        [string]$Domain,
        [Parameter(Mandatory=$true)]
        [string]$DCName,
        [Parameter(Mandatory=$true)]
        [string]$MachineName
    )

    Create-ADUsers $UsersToAdd `
                   $AdminUsername `
                   $AdminPassword `
                   $Domain `
                   $DCName `
                   $MachineName
}

Export-ModuleMember -Function *
