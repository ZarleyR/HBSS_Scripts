### This is used to self elevate the script to Administrator. ###

$myWindowsID=[System.Security.Principal.WindowsIdentity]::GetCurrent()
$myWindowsPrincipal = new-object System.Security.Principal.WindowsPrincipal($myWindowsID)
$adminRole=[System.Security.Principal.WindowsBuiltInRole]::Administrator
if($myWindowsPrincipal.IsInRole($adminRole))
{
$Host.UI.RawUI.WindowTitle = $MyInvocation.MyCommand.Definition + "(Administrator)"
Clear-Host
}
else {
$newProcess = new-object System.Diagnostics.ProcessStartInfo "PowerShell";
$newProcess.Arguments = $MyInvocation.MyCommand.Definition;
$newProcess.Verb = "runas";
[System.Diagnostics.Process]::Start($newProcess);
exit
}

### End of self-elevated script ###

### Begin of HBSS Client Scripts ###

$Shell = New-Object -ComObject ("WScript.Shell")

$isAccepted = $false
do {
# Variables to determine if the system is utilizing DSR
$title = "`n`n`t`tDynamic System Resilience (DSR) System`n____________________________________________________`n`n  If the system is running DSR, you will have a primary and a backup HBSS Server.`n`n"
$question = "Is this system implementing DSR?"
$choices = New-Object Collections.ObjectModel.Collection[Management.Automation.Host.ChoiceDescription]
$choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '  &Yes  '))
$choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '  &No  '))
$decision = $Host.UI.PromptForChoice($title, $question, $choices, 1)

# get user decision
if ($decision -eq 0) {
    # the user selected YES
    $isDSR = $true
    Write-Host "`n  Implementing DSR: True"
} else {
    # the user selected NO
    $isDSR = $false
    Write-Host "`n  Implementing DSR: False"
}
# get System ID from user
Write-Host "`n`n`n  System ID`n____________________________________________________`n`n"
Write-Host "  The System ID will be the Core Security Management Server HostName.  This information will be`n  used to create desktop shortcuts and registry keys required for remote connection to CSMS.`n`n"
Write-Host "  The System ID must meet the following criteria:`n`n`t  -Must start with sz`n`t  -Must be 6 characters in length`n`n"
$validID = $false
do {
    [string]$readID = Read-Host "  What is the System ID? (ex. sz00FE)"
    $sysID = $readID.ToLower()
    if ($sysID.Length -eq 6 -and $sysID -match '^[s][z][0-9]{4}$') {
        $validID = $true
    } else {
        $validID = $false
    }
 } until ($validID)

# Variables to determine if the user is satisfied with their settings
$title = "`n`n`t`tVerification`n____________________________________________________`n`n`t`tImplementing DSR:`t`t`t`t$isDSR`n`t`tSystem ID:`t`t`t`t`t`t`t`t`t`t`t$sysID`n`n"
$question = "Are these settings correct?"
$choices = New-Object Collections.ObjectModel.Collection[Management.Automation.Host.ChoiceDescription]
$choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '  &Yes  '))
$choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '  &No  '))
$decision = $Host.UI.PromptForChoice($title, $question, $choices, 1)

# get user decision
if ($decision -eq 0) {
    # the user selected to continue
    $isAccepted = $true
} else {
    # the user selected to restart
    $isAccepted = $false
    Clear-Host
}

} until ($isAccepted)
# clear screen
Clear-Host
Write-Host "`n`n##############  Creating Desktop Shortcuts!  ##############`n`n"

if($isDSR) {
Try {
    $ShortCut = $Shell.CreateShortcut($env:USERPROFILE + "\Desktop\Primary_ePO.url")
    $ShortCut.TargetPath="https://" + $sysID + "01:49508/core/orionSplashScreen.do"
    $ShortCut.Save()
    $ShortCut = $Shell.CreateShortcut($env:USERPROFILE + "\Desktop\Backup_ePO.url")
    $ShortCut.TargetPath="https://" + $sysID + "02:49508/core/orionSplashScreen.do"
    $ShortCut.Save()
    Copy-Item -Path ($env:USERPROFILE + "\Desktop\Primary_ePO.url") -Destination ("C:\Users\Default\Desktop\Primary_ePO.url")
    Copy-Item -Path ($env:USERPROFILE + "\Desktop\Primary_ePO.url") -Destination ($env:PUBLIC + "\Desktop\Primary_ePO.url")
    Copy-Item -Path ($env:USERPROFILE + "\Desktop\Backup_ePO.url") -Destination ("C:\Users\Default\Desktop\Backup_ePO.url")
    Copy-Item -Path ($env:USERPROFILE + "\Desktop\Backup_ePO.url") -Destination ($env:PUBLIC + "\Desktop\Backup_ePO.url")
    Write-Host -NoNewline ("Desktop Shortcuts: ")
    Write-Host "Success"
} Catch {
    Write-Host -NoNewline ("Desktop Shortcuts: ") 
    Write-Host "Failed"
}
} else {
Try {
    $ShortCut = $Shell.CreateShortcut($env:USERPROFILE + "\Desktop\Primary_ePO.url")
    $ShortCut.TargetPath="https://" + $sysID + "01:49508/core/orionSplashScreen.do"
    $ShortCut.Save()
    Copy-Item -Path ($env:USERPROFILE + "\Desktop\Primary_ePO.url") -Destination ("C:\Users\Default\Desktop\Primary_ePO.url")
    Copy-Item -Path ($env:USERPROFILE + "\Desktop\Primary_ePO.url") -Destination ($env:PUBLIC + "\Desktop\Primary_ePO.url")
    Write-Host -NoNewline ("Desktop Shortcuts: ")
    Write-Host "Success"
} Catch {
    Write-Host -NoNewline ("Desktop Shortcuts: ") 
    Write-Host "Failed"
}
}
Write-Host "`n`n##############  Verifying McAfee Registry Keys!  ##############`n`n"

#Update variables for first registry key values
$keyPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
$keyName = "LocalAccountTokenFilterPolicy"
$keyValue = "1"

Write-Host "First registry key being verified:"
Write-Host "__________________________________________`n"
Write-Host "`tKey Path:`t$keyPath"
Write-Host "`tKey Name:`t$keyName"
Write-Host "`tKey Type:`tDWORD"
Write-Host "`tKey Value:`t00000001`n`n"

if (Test-Path ($keyPath)) {
    Try {
    New-ItemProperty -Path $keyPath -Name $keyName -Value $keyValue -PropertyType DWORD -Force | Out-Null
    Write-Host -NoNewline ($keyName + ": ") 
    Write-Host "Success"
    } Catch {
    Write-Host -NoNewline ($keyName + ": ") 
    Write-Host "Failed"
    }
} else {
    Write-Host -NoNewline ($keyPath + ": ") 
    Write-Host "Does not exist! Check Registry Files"
}

#Update variables for second registry key values
$keyPath = "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters"
$keyName = "SmbServerNameHardeningLevel"
$keyValue = "0"

Write-Host "`n`nSecond registry key being verified:"
Write-Host "__________________________________________`n"
Write-Host "`tKey Path:`t$keyPath"
Write-Host "`tKey Name:`t$keyName"
Write-Host "`tKey Type:`tDWORD"
Write-Host "`tKey Value:`t00000000`n`n"

if (Test-Path ($keyPath)) {
    Try {
    New-ItemProperty -Path $keyPath -Name $keyName -Value $keyValue -PropertyType DWORD -Force | Out-Null
    Write-Host -NoNewline ($keyName + ": ") 
    Write-Host "Success"
    } Catch {
    Write-Host -NoNewline ($keyName + ": ") 
    Write-Host "Failed"
    }
} else {
    Write-Host -NoNewline ($keyPath + ": ") 
    Write-Host "Does not exist! Check Registry Files"
}
Write-Host "`n`n##############  Updating Local Group Policy!  ##############`n`n"

# vARIABLES FOR UPDATED LOCAL GPO DYNAMIC TRUSTED SITE ASSIGNMENT LIST
$needPath1 = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\Internet Settings"
$needPath2 = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap"
$keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains"
$keyFolder1 = ($sysID + "01")
$keyFolder2 = ($sysID + "02")
$keyFolder1Path = ("HKLM:\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\"+ $sysID +"01")
$keyFolder2Path = ("HKLM:\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\"+ $sysID +"02")
$keyName = "*"
$keyValue = "2"
$KeyPathZoneMap = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMapKey"
$keyNameZoneMap1 = ($sysID + "01")
$keyNameZoneMap2 = ($sysID + "02")

if($isDSR) {
#DSR
#create 2 keys within the \ZoneMap\Domain\
#create registry DWORD keys with name = * and value = 2
#create path key within the \Internet Settings\ZoneMapKey
#create registry STRING keys with name sz00FE and value = 2
    Write-Host "Group Policies being applied:"
    Write-Host "__________________________________________`n"
    Write-Host "`tKey Path:`t$keyPathZoneMap"
    Write-Host "`tKey Name:`t$keyNameZoneMap1 and $keyNameZoneMap2"
    Write-Host "`tKey Type:`tSTRING"
    Write-Host "`tKey Value:`t2`n"
    Write-Host "`tKey Path:`t$keyPath"
    Write-Host "`tKey Name:`t$keyFolder1 and $keyFolder2`n"
    Write-Host "`tKey Path:`t$keyFolder1Path"
    Write-Host "`tKey Path:`t$keyFolder2Path"
    Write-Host "`tKey Name:`t$keyName"
    Write-Host "`tKey Type:`tDWORD"
    Write-Host "`tKey Value:`t00000002`n`n"

    Try {
        # if "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains" already
        # exisits then don't recreate this folder as it will blow away existing subkeys
        if (Test-Path $keyPath) {
        } else {
            New-Item -Path $needPath2 -Name "Domains" -Force | Out-Null
        }
        New-Item -Path $keyPath -Name $keyFolder1 -Force | Out-Null
        New-Item -Path $keyPath -Name $keyFolder2 -Force | Out-Null
        New-ItemProperty -Path $keyFolder1Path -Name $keyName -Value $keyValue -PropertyType DWORD -Force | Out-Null
        New-ItemProperty -Path $keyFolder2Path -Name $keyName -Value $keyValue -PropertyType DWORD -Force | Out-Null
        if (Test-Path $KeyPathZoneMap) {
        } else {
            New-Item -Path $needPath1 -Name "ZoneMapKey" -Force | Out-Null
        }
        New-ItemProperty -Path $keyPathZoneMap -Name $keyNameZoneMap1 -Value $keyValue -PropertyType STRING -Force | Out-Null
        New-ItemProperty -Path $keyPathZoneMap -Name $keyNameZoneMap2 -Value $keyValue -PropertyType STRING -Force | Out-Null
        Write-Host -NoNewline "Group Policies Updated: "
        Write-Host "Success"
    } Catch {
        Write-Host -NoNewline "Group Policies Updated: "
        Write-Host "Failed"
    }
    Write-Host "`n__________________________________________`n"
} else {
#not DSR
#create 1 key within the \ZoneMap\Domain\
#create registry DWORD keys with name = * and value = 2
#create path key within the \Internet Settings\ZoneMapKey
#create registry STRING keys with name sz00FE and value = 2

    Write-Host "Group Policies being applied:"
    Write-Host "__________________________________________`n"
    Write-Host "`tKey Path:`t$keyPathZoneMap"
    Write-Host "`tKey Name:`t$keyNameZoneMap1"
    Write-Host "`tKey Type:`tSTRING"
    Write-Host "`tKey Value:`t2`n"
    Write-Host "`tKey Path:`t$keyPath"
    Write-Host "`tKey Name:`t$keyFolder1`n"
    Write-Host "`tKey Path:`t$keyFolder1Path"
    Write-Host "`tKey Name:`t$keyName"
    Write-Host "`tKey Type:`tDWORD"
    Write-Host "`tKey Value:`t00000002`n`n"

    Try {
        # if "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains" already
        # exisits then don't recreate this folder as it will blow away existing subkeys
        if (Test-Path $keyPath) {
        } else {
            New-Item -Path $needPath2 -Name "Domains" -Force | Out-Null
        }
        New-Item -Path $keyPath -Name $keyFolder1 -Force | Out-Null
        New-ItemProperty -Path $keyFolder1Path -Name $keyName -Value $keyValue -PropertyType DWORD -Force | Out-Null
        if (Test-Path $KeyPathZoneMap) {
        } else {
            New-Item -Path $needPath1 -Name "ZoneMapKey" -Force | Out-Null
        }
        New-ItemProperty -Path $keyPathZoneMap -Name $keyNameZoneMap1 -Value $keyValue -PropertyType STRING -Force | Out-Null
        Write-Host -NoNewline "Group Policies Updated: "
        Write-Host "Success"
    } Catch {
        Write-Host -NoNewline "Group Policies Updated: "
        Write-Host "Failed"
    }
    Write-Host ""
    Write-Host "__________________________________________"
    Write-Host ""
}

Write-Host ""
Write-Host ""
Write-Host "Press any button to exit..."
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');

### End of HBSS Client Scripts ###



