<#
Title: Test TCP Ports with PowerShell: A Native Windows Netcat Alternative
Author / channel: Darien Hawkins / Darien's Tips
Source script: PSNCALT_Title-Script_20261024.txt
Preparation date: 2026-10-24
Purpose: Windows-side bonus listener, combined firewall rule and cleanup (G).
Tested environment: Windows 11; Windows PowerShell 5.1; WSL 2 mirrored networking; Hyper-V Firewall On.
Usage notes: Reference-only; all examples are in comment blocks.
Copy only the command lines inside the chosen block to the indicated interactive session.
Replace IP placeholders first. Do not remove all comment blocks or run all stages at once.
See ../Command-Reference.md for cross-machine ordering and ../README.md for prerequisites.
#>

<#
G03 - Construct and start the Windows-side bonus listener.
Target: Windows 11 WSL host with <BONUS_WINDOWS_IPV4> and <BONUS_WSL_IPV4>
Shell: Windows PowerShell 5.1
Privileges: Elevated administrative Windows PowerShell session.
Prerequisites: Separate from the primary Windows listener session; TCP 5050 available.

$listeningPort50 = 5050
$listener50 = [System.Net.Sockets.TcpListener]::new(
    [System.Net.IPAddress]::Any,
    $listeningPort50)

$listener50.Start()
#>

<#
G04 - Create the demonstrated combined inbound TCP rule.
Target: Windows 11 WSL host with <BONUS_WINDOWS_IPV4> and <BONUS_WSL_IPV4>
Shell: Windows PowerShell 5.1
Privileges: Elevated administrative Windows PowerShell session.
Prerequisites: G03 complete; effective firewall policy permits the eligible host port rule to apply to WSL.

$listeningPortsx50x51 = 5050,5051
New-NetFirewallRule -Name "TempAllowPortOn5050and5051" `
    -DisplayName "Temp Allow Inbound on Ports 5050 and 5051 for WSL" `
    -Direction Inbound -Action Allow -Protocol TCP `
    -LocalPort $listeningPortsx50x51
#>

<#
G07 - Stop the Windows bonus listener, then remove the combined test rule.
Target: Windows 11 WSL host with <BONUS_WINDOWS_IPV4> and <BONUS_WSL_IPV4>
Shell: Windows PowerShell 5.1
Privileges: Elevated administrative Windows PowerShell session.
Prerequisites: G06 complete; retained PowerShell session still owns $listener50.

$listener50.Stop()
Remove-NetFirewallRule -Name "TempAllowPortOn5050and5051"
#>
