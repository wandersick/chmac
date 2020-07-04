
$ErrorActionPreference = 'Stop';
$toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$fileLocation = Join-Path $toolsDir 'Setup.exe'
$url        = 'https://github.com/wandersick/chmac/releases/download/v2.0/ChMac-2.0.0.5_Silent_Installer.exe'

$packageArgs = @{
  packageName   = 'ChMac'
  unzipLocation = $toolsDir
  fileType      = 'exe'
  url           = $url
  file          = $fileLocation

  softwareName  = 'ChMac*'

  checksum      = 'e32d4181f31802330d0688587dcf968f'
  checksumType  = 'md5'

  silentArgs    = "/programfiles /unattendaz=1"
  validExitCodes= @(0)
}

Install-ChocolateyPackage @packageArgs
