
                             [ ChMac v2.0 ]

          https://tech.wandersick.com | wandersick@gmail.com

     [ What? ]

  #  Named after chmod, chmac is a command-line-interface (CLI) tool for
     Windows that changes or randomizes MAC addresses of specified network
     adapters, e.g. for a client device to reuse public Wi-Fi hotspot that
     has past usage limit for the day.

     An easy-to-use interactive console is available, alongside command-line
     parameters, e.g. for scheduling jobs with Task Scheduler. ChMac also has
     support for recurrence built-in.

     [ Features ]

  #  Change MAC addresses on Windows automatically or manually

     Automatically change MAC addresses on set intervals. This is useful to
     reconnect to some free public Wi-Fi hotspots that impose a time limit by
     recognizing MAC addresses to prevent the same device from reconnecting
  
  #  Randomize MAC addresses for better security using public Wi-Fi

     Generate new MAC addresses randomly based on a customizable list of
     organizationally unique identifiers (OUI)

  #  Optionally leverages DevCon.exe to simply the process by automatically
     disabling and re-enabling network interface card (NIC)

     ChMac also works without DevCon by showing the Network Connections
     folder when finished, so that users can manually disable and re-enable
     NIC for new settings to take effect

     On first launch, users are guided to download DevCon with convenient
     automatic and manual options

  #  Restore original MAC address

  #  Error checking + rich return codes for scripting or other possibilities

  #  While portable by default, it can be installed (using setup.exe) to
     enable the 'ChMac' command anywhere for ease of use, by adding to Run
     prompt and PATH environmental variable (feature available since v2.0)

  #  Free and open-source software written in Windows Batch language

  #  Supports Windows 2000/XP/Vista/7/8/8.1/10 and Server 2000-2019

  #  Easy-to-use interactive console + command-line mode accepting parameters

     Just follow instructions on screen for the interactive console.

     For command-line mode, see the following:

     [ Syntax ]

     chmac.bat [/d dir][/l][/m address][/n id][/r][/help][/?]

     [ Parameters ]

     /d dir        :: working directory -- maybe required
                      (MUST be specified before other parameters)
     /l            :: list network adapters and their IDs
     /m            :: new mac address to be applied.
     /n            :: adapter to be applied new mac address
                      if /m is unspecified. New mac address will be
                      randomized (OUI kept) and automatically filled in
     /r            :: restore to original MAC address
     /a            :: auto-change interval
                      suffix may be s for sec, m for min, h for hour or d for day
                      e.g. enter '20m' to recur per 20 mins. [X] to reset or exit

  #  The mac address format can be any of the following:

     AB-CD-EF-12-34-56
     AB:CD:EF:12:34:56
     AB.CD.EF.12.34.56
     AB CD EF 12 34 56     :: or without any separation in between at all

  #  When no parameter is specified, interactive mode is entered.

     [ Examples ]

     . chmac /l                     :: list available adapter IDs
     . chmac /n 1                   :: update network adapter #1 with
                                       randomized mac address numbers.
     . chmac /m 00301812AB01 /n 2   :: update network adapter #2 with the
                                       new mac address: 00-30-18-12-AB-01
     . chmac /n 3 /r                :: restore adapter 3 to its original MAC
     . chmac /n 4 /a 20m            :: auto-change MAC per 20 minute
     . chmac /?                     :: shows short help. [/help] for long.

     [ Return codes ]

  #  (0) Success     (1) Failure    (3) NIC error
     (4) Bad syntax  (5) No exe     (7) No admin rights

     [ Requirements ]

  #  All Windows operating systems from Windows 2000 and up (Windows 10 1809
     at the moment) are supported.

     - To use this in Windows 2000 or some minimal Windows PE, place these files
       from another machine which runs English Windows XP or 2003: 'msvcp60.dll'
       as well as 'getmac.exe' and 'reg.exe' into 'ChMac\Data\3rdparty\LP'

  #  Admin rights are required for editing MAC addresses, disabling and re-
     enabling network adapters

     - Since version 1.3, ChMac automatically elevates itself if there is no
       admin rights when User Account Control (UAC) is enabled in the system

  #  ChMac wraps around DevCon (optional), OS-native and GNU Linux utilities

     All of the below dependencies are optional. Most of them are included

     - DevCon.exe - Optionally enhances ChMac using DevCon, Microsoft Windows
       Device Console which can be downloaded during first launch of the script

       Beware of the version to download as there are lots of DevCon versions
       for different OS. See https://superuser.com/a/1099688/112570

     - Unix utilities leveraged by ChMac are included already:
       tr.exe, sed.exe, which.exe, sleep.exe, wc.exe, wget.exe, grep.exe

     - Other OS built-in dependencies natively in Windows since Windows XP:
       getmac.exe, reg.exe, msvcp60.dll

     - Optional OS built-in dependency natively in Windows since Windows Vista:
       choice.exe, falling back to 'set /p' if unavailable, thru a sub-script
       '_choiceMulti.bat'

     [ Limitations ]

     1. Some virtual adapters may be unsupported

     2. Randomization logic randomizes numbers (0-9) instead of hex (0-9, A-F)

     [ GitHub repository ]

     A more detailed documentation of ChMac is available on GitHub at:
     https://github.com/wandersick/chmac

     [ Donation ]

     If ChMac or my other utilities help you, consider buying a cup of coffee
     at https://tinyurl.com/buy-coffee which would be much appreciated :)
     