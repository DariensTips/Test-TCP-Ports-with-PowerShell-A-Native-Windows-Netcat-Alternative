<#
Title: Test TCP Ports with PowerShell: A Native Windows Netcat Alternative
Author / channel: Darien Hawkins / Darien's Tips
Source script: PSNCALT_Title-Script_20261024.txt
Preparation date: 2026-10-24
Purpose: Client-side tests in the demonstrated B/C/D/G order, with explicit stage prerequisites.
Tested environment: Windows 11 client; Windows PowerShell; inter-VLAN routing already configured.
Usage notes: Reference-only; all examples are in comment blocks.
Copy only the command lines inside the chosen block to the indicated interactive session.
Replace IP placeholders first. Do not remove all comment blocks or run all stages at once.
See ../Command-Reference.md for cross-machine ordering and ../README.md for prerequisites.
#>

<#
B02 - Demonstrate the initial failed TCP connection.
Target: Windows 11 client on CLIENT_VLAN
Shell: Windows PowerShell 5.1
Privileges: Standard user; no elevation required for these tests.
Prerequisites: No netcat listener yet; planned routing and firewall path are established.

Test-NetConnection -ComputerName <LINUX_TEST_IPV4> -Port 5051
#>

<#
B05 - Repeat the connection test; the demonstrated result is True.
Target: Windows 11 client on CLIENT_VLAN
Shell: Windows PowerShell 5.1
Privileges: Standard user; no elevation required for these tests.
Prerequisites: B03 is running and B04 has shown the listening socket.

Test-NetConnection -ComputerName <LINUX_TEST_IPV4> -Port 5051
#>

<#
C07 - Verify remote TCP connection establishment.
Target: Windows 11 client on CLIENT_VLAN
Shell: Windows PowerShell 5.1
Privileges: Standard user; no elevation required for these tests.
Prerequisites: The Windows listener is active; path permits TCP 5050.

Test-NetConnection -ComputerName <WINDOWS_TEST_IPV4> -Port 5050
#>

<#
D01 - Verify that both required TCP connections fail.
Target: Windows 11 client on CLIENT_VLAN
Shell: Windows PowerShell 5.1
Privileges: Standard user; no elevation required for these tests.
Prerequisites: D00 active; both listeners remain running.

Test-NetConnection -ComputerName <WINDOWS_TEST_IPV4> -Port 5050
Test-NetConnection -ComputerName <LINUX_TEST_IPV4> -Port 5051
#>

<#
D02 - Check TCP 22 while application ports are blocked; this is not SSH authentication.
Target: Windows 11 client on CLIENT_VLAN
Shell: Windows PowerShell 5.1
Privileges: Standard user; no elevation required for these tests.
Prerequisites: OpenSSH Server is already listening on both test systems; TCP 22 is permitted.

Test-NetConnection -ComputerName <WINDOWS_TEST_IPV4> -Port 22
Test-NetConnection -ComputerName <LINUX_TEST_IPV4> -Port 22
#>

<#
D04 - Verify both required connections succeed after removing the router restrictions.
Target: Windows 11 client on CLIENT_VLAN
Shell: Windows PowerShell 5.1
Privileges: Standard user; no elevation required for these tests.
Prerequisites: D03 complete; the same listeners are still running.

Test-NetConnection -ComputerName <WINDOWS_TEST_IPV4> -Port 5050
Test-NetConnection -ComputerName <LINUX_TEST_IPV4> -Port 5051
#>

<#
G05 - Test the Windows and WSL listener endpoints independently.
Target: Windows 11 client on CLIENT_VLAN
Shell: Windows PowerShell 5.1
Privileges: Standard user; no elevation required for these tests.
Prerequisites: G02-G04 complete; use bonus addresses, not deployed database addresses.

Test-NetConnection -ComputerName <BONUS_WINDOWS_IPV4> -Port 5050
Test-NetConnection -ComputerName <BONUS_WSL_IPV4> -Port 5051
#>
