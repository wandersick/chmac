Before compiling Setup.exe and ChMac_Unattended_Installer.exe, move all files within this folder (except Readme.txt) to one level above it, i.e. in the same directory as ChMac.bat

ChMac_7-Zip_SFX.exe should be prepared first

For details, refer to https://medium.com/wandersick/how-to-create-a-silent-installer-with-autohotkey-and-publish-it-on-chocolatey-8e3a9cf6da70

1. Setup.exe

- The compiled Setup.exe should be stored in the same directory as ChMac.bat in order for it to execute successfully

2. ChMac_Unattended_Installer.exe

- There is no dependency on other files. This is a standalone installer that can install ChMac from beginning to end
