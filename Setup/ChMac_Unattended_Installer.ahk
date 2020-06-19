; Package an application (e.g. ChMac) in 7-Zip SFX, self-extracting archive (FYI: the ChMac download already comes with an SFX)
; Place it in the location specified below, e.g. C:\az-autohotkey-silent-setup\ChMac_7-Zip_SFX.exe
FileInstall, C:\az-autohotkey-silent-setup\ChMac_7-Zip_SFX.exe, %A_ScriptDir%\ChMac_7-Zip_SFX.exe, 1

; Silently extract ChMac from the SFX file into the current directory
RunWait, %A_ScriptDir%\ChMac_7-Zip_SFX.exe -o"%A_ScriptDir%" -y

; Run silent setup command: Setup.exe /programfiles /unattendaz=1
; For ChMac, this command will install ChMac to All Users (/programfiles) and silently (/unattendedaz=1)
; as well as uninstalling in case an ChMac copy is found in the target location (built into the logic of Setup.exe of ChMac)
RunWait, %A_ScriptDir%\ChMac\Setup.exe /programfiles /unattendaz=1

; Clean up temporary files used during setup shortly after setup finishes installation
Sleep, 100
FileDelete, %A_ScriptDir%\ChMac_7-Zip_SFX.exe
FileRemoveDir, %A_ScriptDir%\ChMac, 1
