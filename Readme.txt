
                               [ ChMac v1.1 ]

             http://wandersick.blogspot.com | wandersick@gmail.com

     [ What? ]

  #  ChMac is an easy-to-use portable command-line-interface (CLI) tool that
     changes MAC addresses of specified network adapters. As a CLI tool, it
     can be used in any way such as scheduling tasks with 'schtasks' command.

     [ Features ]

  #  An interactive console as well as accepting parameters.

  #  Automatically changes MAC addresses on set intervals. This is useful to
     connect to some free public Wi-Fi hotspots that have a time limit and
     recognize MAC addresses in order to disallow the same person to use the
     service again.

  #  Uses DevCon.exe to automate the whole process. ChMac still works without
     it, but will show the Network Connections folder when finished, so that
     users can manually disable and re-enable the adapter for new settings to
     take effect. (On 1st run users are asked to download DevCon to avoid it)

  #  Multilingual interface. (See tip 5)

  #  Free software. Written in poorly commented Batch. Any codes of anything
     by me are GPL-licensed. However the 3rdparty component DevCon.exe is not.
     You may freely adopt it to your free projects.

  #  Windows XP or later are fully supported. If you use this in Windows PE
     or 2000, you may place from a XP machine: msvcp60.dll, getmac.exe,
     reg.exe in "ChMac\Dict\conf\3rdparty\LP". Admins rights are required.

  #  The interactive console is easier to use. Just follow instructions on
     screen. For command line mode, see the following:

     [ Parameters ]

  #  ChMac [/d dir][/l][/m address][/n id][/r][/u][/help][/?]

     /d dir        :: working directory -- maybe required
                      (MUST be specified before other parameters)
     /l            :: list network adapters and their IDs
     /m            :: new mac address to be applied.
     /n            :: adapter to be applied new mac address
                      if /m is unspecified. New mac address will be
                      randomized (OUI kept) and automatically filled.
     /r            :: restore to original MAC address
     /a            :: auto-change interval
     /u            :: check for program update

  #  The mac address format can be any of the following:

     AB-CD-EF-12-34-56
     AB:CD:EF:12:34:56
     AB.CD.EF.12.34.56
     AB CD EF 12 34 56 ... or without any separation in between at all.

  #  When no parameter is specified, interactive mode is entered.

     [ Examples ]

  #  . chmac /l                     :: list available adapter IDs
     . chmac /n 1                   :: update network adapter #1 with
                                       randomized mac address numbers.
     . chmac /m 00301812AB01 /n 2   :: update network adapter #2 with the
                                       new mac address: 00-30-18-12-AB-01
     . chmac /n 3 /r                :: restore adapter 3 to its original MAC
     . chmac /n 4 /a 20m            :: auto-change MAC per 20 minute
     . chmac /?                     :: shows short help. [/help] for long.

     [ Return codes ]

  #  (0) Success  (1) Failure  (3) NIC error  (4) Bad syntax  (5) No exe

     [ Limitations ]

  #  1. While it may seem this program is multi-lingual, only English has been
        implemented for this version.

     2. Some virtual adapters are unsupported.

     [ Suggestion ]

  #  Please drop me a line by email or the web site atop.