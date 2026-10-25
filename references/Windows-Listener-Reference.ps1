<#
Title: Test TCP Ports with PowerShell: A Native Windows Netcat Alternative
Author / channel: Darien Hawkins / Darien's Tips
Source script: PSNCALT_Title-Script_20261024.txt
Preparation date: 2026-10-24
Purpose: Primary Windows listener creation, local verification and conditional cleanup (C/E).
Tested environment: Windows 11 Enterprise LTSC Evaluation; Windows PowerShell 5.1 / .NET Framework.
Usage notes: Reference-only; all examples are in comment blocks.
Copy only the command lines inside the chosen block to the indicated interactive session.
Replace IP placeholders first. Do not remove all comment blocks or run all stages at once.
See ../Command-Reference.md for cross-machine ordering and ../README.md for prerequisites.
#>

<#
C01 - Construct the listener object; this does not start listening.
Target: Windows test system at <WINDOWS_TEST_IPV4> on SERVER_VLAN
Shell: Windows PowerShell 5.1
Privileges: Elevated administrative Windows PowerShell session.
Prerequisites: Port 5050 available; retain this interactive PowerShell session through E.

$listeningPort = 5050
$listener = [System.Net.Sockets.TcpListener]::new(
    [System.Net.IPAddress]::Any,
    $listeningPort)
#>

<#
C02 - Create the demonstrated temporary inbound TCP rule.
Target: Windows test system at <WINDOWS_TEST_IPV4> on SERVER_VLAN
Shell: Windows PowerShell 5.1
Privileges: Elevated administrative Windows PowerShell session.
Prerequisites: C01 defined $listeningPort; do not overwrite an unrelated existing rule.

New-NetFirewallRule -Name "TempAllowPort5050" `
    -DisplayName "Temp Allow Inbound on Port 5050" `
    -Direction Inbound -Action Allow -Protocol TCP `
    -LocalPort $listeningPort
#>

<#
C03 - Enable the existing ICMPv4 Echo Request rule.
Target: Windows test system at <WINDOWS_TEST_IPV4> on SERVER_VLAN
Shell: Windows PowerShell 5.1
Privileges: Elevated administrative Windows PowerShell session.
Prerequisites: The named existing rule is present. Record its original enabled state.

Set-NetFirewallRule -DisplayName "File and Printer Sharing (Restrictive) (Echo Request - ICMPv4-In)" `
    -Enabled True
#>

<#
C04 - Start the listener.
Target: Windows test system at <WINDOWS_TEST_IPV4> on SERVER_VLAN
Shell: Windows PowerShell 5.1
Privileges: Elevated administrative Windows PowerShell session.
Prerequisites: C01-C03 complete in the retained interactive session.

$listener.Start()
#>

<#
C05 - Inspect TCP endpoints with netstat, as shown.
Target: Windows test system at <WINDOWS_TEST_IPV4> on SERVER_VLAN
Shell: Windows PowerShell 5.1
Privileges: Elevated administrative Windows PowerShell session.
Prerequisites: C04 started the listener.

netstat -anop tcp | Select-String -Pattern 5050
#>

<#
C06 - Inspect local TCP connections on 5050 using PowerShell.
Target: Windows test system at <WINDOWS_TEST_IPV4> on SERVER_VLAN
Shell: Windows PowerShell 5.1
Privileges: Elevated administrative Windows PowerShell session.
Prerequisites: C04 started the listener.

Get-NetTCPConnection -LocalPort 5050
#>

<#
E02 - Close the Windows listening socket.
Target: Windows test system at <WINDOWS_TEST_IPV4> on SERVER_VLAN
Shell: Windows PowerShell 5.1
Privileges: Elevated administrative Windows PowerShell session.
Prerequisites: Use the same interactive session that owns $listener.

$listener.Stop()
#>

<#
E03 - Remove the test TCP firewall rule.
Target: Windows test system at <WINDOWS_TEST_IPV4> on SERVER_VLAN
Shell: Windows PowerShell 5.1
Privileges: Elevated administrative Windows PowerShell session.
Prerequisites: E02 complete; remove only the rule created for this test.

Remove-NetFirewallRule -Name "TempAllowPort5050"
#>

<#
E04 - Restore the original disabled state; do not delete the built-in rule.
Target: Windows test system at <WINDOWS_TEST_IPV4> on SERVER_VLAN
Shell: Windows PowerShell 5.1
Privileges: Elevated administrative Windows PowerShell session.
Prerequisites: Run ONLY if the existing ICMP rule was disabled before C03. Otherwise skip.

Set-NetFirewallRule -DisplayName "File and Printer Sharing (Restrictive) (Echo Request - ICMPv4-In)" `
    -Enabled False
#>
