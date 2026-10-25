# Test TCP Ports with PowerShell: A Native Windows Netcat Alternative

- **Author / channel:** Darien Hawkins / Darien's Tips
- **Purpose:** Reference the demonstrated temporary-listener, connection-test, cleanup and database-verification commands without adding automation.
- **Source script:** `PSNCALT_Title-Script_20261024.txt`
- **Preparation date:** 2026-10-24
- **Tested environment:** Author-reported demonstration: Windows 11 Enterprise LTSC Evaluation, Windows PowerShell 5.1 / .NET Framework, Ubuntu 26.04, Windows Server RRAS, SQL Server 2025, Oracle Database 26ai, and Windows 11 with Ubuntu under WSL 2. Exact Windows builds, .NET patch version and RRAS server version are not specified in the final script.
- **Usage notes:** Individual reference examples only. Replace angle-bracket IP placeholders before use. Select only the commands for the stated machine, shell and stage. Preserve the order across machines; do not run an entire reference file as a single script.

## Execution order and safety

Examples follow source sections B-G. Manual actions are explicitly separated from commands. Keep the Windows listener PowerShell sessions open until their corresponding Stop() cleanup. The ICMP restoration command is conditional on the original rule state. No accept loop, automated RRAS changes, installation steps or additional tests have been introduced.

## B01 — Report UFW status; do not disable the firewall.

**Target:** Ubuntu 26.04 test system at <LINUX_TEST_IPV4> on SERVER_VLAN  
**Shell / interface:** Ubuntu shell  
**Privileges:** sudo authorization for this status check.  
**Prerequisites:** Routing is already configured; UFW is installed.

```bash
sudo ufw status
```

## B02 — Demonstrate the initial failed TCP connection.

**Target:** Windows 11 client on CLIENT_VLAN  
**Shell / interface:** Windows PowerShell 5.1  
**Privileges:** Standard user; no elevation required for these tests.  
**Prerequisites:** No netcat listener yet; planned routing and firewall path are established.

```powershell
Test-NetConnection -ComputerName <LINUX_TEST_IPV4> -Port 5051
```

## B03 — Start the IPv4 listener; retain this foreground terminal.

**Target:** Ubuntu 26.04 test system at <LINUX_TEST_IPV4> on SERVER_VLAN  
**Shell / interface:** Ubuntu shell  
**Privileges:** Standard user for port 5051.  
**Prerequisites:** OpenBSD-style netcat installed; TCP 5051 is available.

```bash
netcat -4 -l -k 5051
```

## B04 — Inspect listening TCP sockets without altering the listener.

**Target:** Ubuntu 26.04 test system at <LINUX_TEST_IPV4> on SERVER_VLAN  
**Shell / interface:** A second Ubuntu shell  
**Privileges:** Standard user; process details may be limited by permissions.  
**Prerequisites:** Leave B03 running in its original terminal.

```bash
ss -ltnp
```

## B05 — Repeat the connection test; the demonstrated result is True.

**Target:** Windows 11 client on CLIENT_VLAN  
**Shell / interface:** Windows PowerShell 5.1  
**Privileges:** Standard user; no elevation required for these tests.  
**Prerequisites:** B03 is running and B04 has shown the listening socket.

```powershell
Test-NetConnection -ComputerName <LINUX_TEST_IPV4> -Port 5051
```

## C01 — Construct the listener object; this does not start listening.

**Target:** Windows test system at <WINDOWS_TEST_IPV4> on SERVER_VLAN  
**Shell / interface:** Windows PowerShell 5.1  
**Privileges:** Elevated administrative Windows PowerShell session.  
**Prerequisites:** Port 5050 available; retain this interactive PowerShell session through E.

```powershell
$listeningPort = 5050
$listener = [System.Net.Sockets.TcpListener]::new(
    [System.Net.IPAddress]::Any,
    $listeningPort)
```

## C02 — Create the demonstrated temporary inbound TCP rule.

**Target:** Windows test system at <WINDOWS_TEST_IPV4> on SERVER_VLAN  
**Shell / interface:** Windows PowerShell 5.1  
**Privileges:** Elevated administrative Windows PowerShell session.  
**Prerequisites:** C01 defined $listeningPort; do not overwrite an unrelated existing rule.

```powershell
New-NetFirewallRule -Name "TempAllowPort5050" `
    -DisplayName "Temp Allow Inbound on Port 5050" `
    -Direction Inbound -Action Allow -Protocol TCP `
    -LocalPort $listeningPort
```

## C03 — Enable the existing ICMPv4 Echo Request rule.

**Target:** Windows test system at <WINDOWS_TEST_IPV4> on SERVER_VLAN  
**Shell / interface:** Windows PowerShell 5.1  
**Privileges:** Elevated administrative Windows PowerShell session.  
**Prerequisites:** The named existing rule is present. Record its original enabled state.

```powershell
Set-NetFirewallRule -DisplayName "File and Printer Sharing (Restrictive) (Echo Request - ICMPv4-In)" `
    -Enabled True
```

## C04 — Start the listener.

**Target:** Windows test system at <WINDOWS_TEST_IPV4> on SERVER_VLAN  
**Shell / interface:** Windows PowerShell 5.1  
**Privileges:** Elevated administrative Windows PowerShell session.  
**Prerequisites:** C01-C03 complete in the retained interactive session.

```powershell
$listener.Start()
```

## C05 — Inspect TCP endpoints with netstat, as shown.

**Target:** Windows test system at <WINDOWS_TEST_IPV4> on SERVER_VLAN  
**Shell / interface:** Windows PowerShell 5.1  
**Privileges:** Elevated administrative Windows PowerShell session.  
**Prerequisites:** C04 started the listener.

```powershell
netstat -anop tcp | Select-String -Pattern 5050
```

## C06 — Inspect local TCP connections on 5050 using PowerShell.

**Target:** Windows test system at <WINDOWS_TEST_IPV4> on SERVER_VLAN  
**Shell / interface:** Windows PowerShell 5.1  
**Privileges:** Elevated administrative Windows PowerShell session.  
**Prerequisites:** C04 started the listener.

```powershell
Get-NetTCPConnection -LocalPort 5050
```

## C07 — Verify remote TCP connection establishment.

**Target:** Windows 11 client on CLIENT_VLAN  
**Shell / interface:** Windows PowerShell 5.1  
**Privileges:** Standard user; no elevation required for these tests.  
**Prerequisites:** The Windows listener is active; path permits TCP 5050.

```powershell
Test-NetConnection -ComputerName <WINDOWS_TEST_IPV4> -Port 5050
```

## D00 — Introduce the controlled blocking condition.

**Target:** Windows Server RRAS router  
**Shell / interface:** RRAS management interface  
**Privileges:** Administrative access to RRAS.  
**Prerequisites:** Both listeners and endpoint firewall settings remain unchanged.

Using the already-prepared RRAS configuration, block destination TCP 5050 and 5051 between CLIENT_VLAN and SERVER_VLAN. Continue permitting ICMP Echo Requests and TCP 22. The source provides no RRAS command syntax; no new filter commands are added here.

## D01 — Verify that both required TCP connections fail.

**Target:** Windows 11 client on CLIENT_VLAN  
**Shell / interface:** Windows PowerShell 5.1  
**Privileges:** Standard user; no elevation required for these tests.  
**Prerequisites:** D00 active; both listeners remain running.

```powershell
Test-NetConnection -ComputerName <WINDOWS_TEST_IPV4> -Port 5050
Test-NetConnection -ComputerName <LINUX_TEST_IPV4> -Port 5051
```

## D02 — Check TCP 22 while application ports are blocked; this is not SSH authentication.

**Target:** Windows 11 client on CLIENT_VLAN  
**Shell / interface:** Windows PowerShell 5.1  
**Privileges:** Standard user; no elevation required for these tests.  
**Prerequisites:** OpenSSH Server is already listening on both test systems; TCP 22 is permitted.

```powershell
Test-NetConnection -ComputerName <WINDOWS_TEST_IPV4> -Port 22
Test-NetConnection -ComputerName <LINUX_TEST_IPV4> -Port 22
```

## D03 — Restore the tested TCP path.

**Target:** Windows Server RRAS router  
**Shell / interface:** RRAS management interface  
**Privileges:** Administrative access to RRAS.  
**Prerequisites:** Leave the listeners and endpoint rules unchanged.

Remove the temporary RRAS restrictions on TCP 5050 and 5051, as demonstrated. Do not restart the listeners.

## D04 — Verify both required connections succeed after removing the router restrictions.

**Target:** Windows 11 client on CLIENT_VLAN  
**Shell / interface:** Windows PowerShell 5.1  
**Privileges:** Standard user; no elevation required for these tests.  
**Prerequisites:** D03 complete; the same listeners are still running.

```powershell
Test-NetConnection -ComputerName <WINDOWS_TEST_IPV4> -Port 5050
Test-NetConnection -ComputerName <LINUX_TEST_IPV4> -Port 5051
```

## E01 — Stop the Linux temporary listener.

**Target:** Ubuntu 26.04 test system at <LINUX_TEST_IPV4> on SERVER_VLAN  
**Shell / interface:** Original foreground netcat terminal  
**Privileges:** Same user that started netcat.  
**Prerequisites:** D04 verification complete.

Press Ctrl+C in the terminal running netcat. This is a keyboard action, not a shell command.

## E02 — Close the Windows listening socket.

**Target:** Windows test system at <WINDOWS_TEST_IPV4> on SERVER_VLAN  
**Shell / interface:** Windows PowerShell 5.1  
**Privileges:** Elevated administrative Windows PowerShell session.  
**Prerequisites:** Use the same interactive session that owns $listener.

```powershell
$listener.Stop()
```

## E03 — Remove the test TCP firewall rule.

**Target:** Windows test system at <WINDOWS_TEST_IPV4> on SERVER_VLAN  
**Shell / interface:** Windows PowerShell 5.1  
**Privileges:** Elevated administrative Windows PowerShell session.  
**Prerequisites:** E02 complete; remove only the rule created for this test.

```powershell
Remove-NetFirewallRule -Name "TempAllowPort5050"
```

## E04 — Restore the original disabled state; do not delete the built-in rule.

**Target:** Windows test system at <WINDOWS_TEST_IPV4> on SERVER_VLAN  
**Shell / interface:** Windows PowerShell 5.1  
**Privileges:** Elevated administrative Windows PowerShell session.  
**Prerequisites:** Run ONLY if the existing ICMP rule was disabled before C03. Otherwise skip.

```powershell
Set-NetFirewallRule -DisplayName "File and Printer Sharing (Restrictive) (Echo Request - ICMPv4-In)" `
    -Enabled False
```

## F01 — Open the real SQL Server connection.

**Target:** Windows 11 administrative client  
**Shell / interface:** SSMS connection dialog  
**Privileges:** Authorized SQL Server credentials; local OS elevation is not the database permission.  
**Prerequisites:** Temporary listeners stopped; actual SQL Server 2025 service and firewall access prepared at <WINDOWS_TEST_IPV4>:5050.

In the SSMS server-name field enter tcp:<WINDOWS_TEST_IPV4>,5050 and authenticate using the appropriate database credentials. Database installation, protocol configuration and authentication setup are prerequisites, not added procedures.

## F02 — Display SQL Server instance name and version.

**Target:** SQL Server 2025 session from the administrative client  
**Shell / interface:** SSMS T-SQL query window  
**Privileges:** Database account authorized to connect and execute the demonstrated read-only query.  
**Prerequisites:** F01 connected successfully.

```sql
SELECT @@SERVERNAME AS ServerName,
       @@VERSION AS SQLServerVersion;
```

## F03 — Open the real Oracle connection.

**Target:** Windows 11 administrative client  
**Shell / interface:** Oracle SQL Developer connection dialog  
**Privileges:** Authorized Oracle database credentials.  
**Prerequisites:** Actual Oracle Database 26ai service and firewall access prepared at <LINUX_TEST_IPV4>:5051.

Connect to host <LINUX_TEST_IPV4>, TCP port 5051, using your actual Oracle service name and appropriate credentials. The source does not specify a service name, username or password; none is invented here.

## F04 — Display the database and container names.

**Target:** Oracle Database 26ai session from the administrative client  
**Shell / interface:** Oracle SQL Developer SQL worksheet  
**Privileges:** Database account authorized to connect and execute the demonstrated read-only query.  
**Prerequisites:** F03 connected successfully.

```sql
SELECT SYS_CONTEXT('USERENV', 'DB_NAME') AS DatabaseName,
       SYS_CONTEXT('USERENV', 'CON_NAME') AS ContainerName
FROM DUAL;
```

## G00 — Prepare the optional consolidated lab without changing the primary database endpoints.

**Target:** Windows 11 WSL host with <BONUS_WINDOWS_IPV4> and <BONUS_WSL_IPV4>  
**Shell / interface:** Windows and WSL Settings interfaces  
**Privileges:** Administrative access for network and firewall settings.  
**Prerequisites:** A Windows 11 host with Ubuntu under WSL 2 is already installed.

Use two already-configured adapters on SERVER_VLAN with separate, unused <BONUS_WINDOWS_IPV4> and <BONUS_WSL_IPV4> addresses. WSL networking is Mirrored; Hyper-V Firewall is On; RRAS blocks are removed. The source demonstrates existing settings rather than providing installation or address-assignment commands.

## G01 — Confirm the expected mirrored interface address is present.

**Target:** Ubuntu WSL 2 instance on the Windows bonus host  
**Shell / interface:** Ubuntu WSL shell  
**Privileges:** Standard user.  
**Prerequisites:** G00 settings are active.

```bash
ip a
```

## G02 — Start the WSL Linux listener and leave this terminal running.

**Target:** Ubuntu WSL 2 instance on the Windows bonus host  
**Shell / interface:** Ubuntu WSL shell  
**Privileges:** Standard user for port 5051.  
**Prerequisites:** G01 checked; netcat installed and TCP 5051 available.

```bash
netcat -4 -l -k 5051
```

## G03 — Construct and start the Windows-side bonus listener.

**Target:** Windows 11 WSL host with <BONUS_WINDOWS_IPV4> and <BONUS_WSL_IPV4>  
**Shell / interface:** Windows PowerShell 5.1  
**Privileges:** Elevated administrative Windows PowerShell session.  
**Prerequisites:** Separate from the primary Windows listener session; TCP 5050 available.

```powershell
$listeningPort50 = 5050
$listener50 = [System.Net.Sockets.TcpListener]::new(
    [System.Net.IPAddress]::Any,
    $listeningPort50)

$listener50.Start()
```

## G04 — Create the demonstrated combined inbound TCP rule.

**Target:** Windows 11 WSL host with <BONUS_WINDOWS_IPV4> and <BONUS_WSL_IPV4>  
**Shell / interface:** Windows PowerShell 5.1  
**Privileges:** Elevated administrative Windows PowerShell session.  
**Prerequisites:** G03 complete; effective firewall policy permits the eligible host port rule to apply to WSL.

```powershell
$listeningPortsx50x51 = 5050,5051
New-NetFirewallRule -Name "TempAllowPortOn5050and5051" `
    -DisplayName "Temp Allow Inbound on Ports 5050 and 5051 for WSL" `
    -Direction Inbound -Action Allow -Protocol TCP `
    -LocalPort $listeningPortsx50x51
```

## G05 — Test the Windows and WSL listener endpoints independently.

**Target:** Windows 11 client on CLIENT_VLAN  
**Shell / interface:** Windows PowerShell 5.1  
**Privileges:** Standard user; no elevation required for these tests.  
**Prerequisites:** G02-G04 complete; use bonus addresses, not deployed database addresses.

```powershell
Test-NetConnection -ComputerName <BONUS_WINDOWS_IPV4> -Port 5050
Test-NetConnection -ComputerName <BONUS_WSL_IPV4> -Port 5051
```

## G06 — Stop the WSL netcat listener.

**Target:** Ubuntu WSL 2 instance on the Windows bonus host  
**Shell / interface:** Original foreground Ubuntu WSL netcat terminal  
**Privileges:** Same user that started netcat.  
**Prerequisites:** G05 complete.

Press Ctrl+C in the Ubuntu WSL terminal running netcat.

## G07 — Stop the Windows bonus listener, then remove the combined test rule.

**Target:** Windows 11 WSL host with <BONUS_WINDOWS_IPV4> and <BONUS_WSL_IPV4>  
**Shell / interface:** Windows PowerShell 5.1  
**Privileges:** Elevated administrative Windows PowerShell session.  
**Prerequisites:** G06 complete; retained PowerShell session still owns $listener50.

```powershell
$listener50.Stop()
Remove-NetFirewallRule -Name "TempAllowPortOn5050and5051"
```
