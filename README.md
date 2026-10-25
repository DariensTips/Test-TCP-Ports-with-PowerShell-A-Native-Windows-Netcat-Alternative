# Test TCP Ports with PowerShell: A Native Windows Netcat Alternative

- **Author / channel:** Darien Hawkins / Darien's Tips
- **Purpose:** Reference the demonstrated temporary-listener, connection-test, cleanup and database-verification commands without adding automation.
- **Source script:** `PSNCALT_Title-Script_20261024.txt`
- **Preparation date:** 2026-10-24
- **Tested environment:** Author-reported demonstration: Windows 11 Enterprise LTSC Evaluation, Windows PowerShell 5.1 / .NET Framework, Ubuntu 26.04, Windows Server RRAS, SQL Server 2025, Oracle Database 26ai, and Windows 11 with Ubuntu under WSL 2. Exact Windows builds, .NET patch version and RRAS server version are not specified in the final script.
- **Usage notes:** Individual reference examples only. Replace angle-bracket IP placeholders before use. Select only the commands for the stated machine, shell and stage. Preserve the order across machines; do not run an entire reference file as a single script.

## Overview

Test access to the TCP endpoints an application will use before installing that application. This video compares an Ubuntu netcat listener with Windows PowerShell 5.1 using the .NET Framework `System.Net.Sockets.TcpListener` class. It then introduces a controlled RRAS block, verifies that ping and TCP 22 remain available, restores access, cleans up, and verifies real SQL Server and Oracle connections with queries.

An optional WSL 2 example runs netcat and the Windows listener on one Windows 11 host. It retains TCP 5050/5051 but uses separate bonus IP addresses. This is a temporary TCP connectivity test, not a complete netcat replacement, application protocol implementation, port scanner or production listener service.

Repository: https://github.com/DariensTips/Test-TCP-Ports-with-PowerShell-A-Native-Windows-Netcat-Alternative

## Start here

Read [Command-Reference.md](Command-Reference.md), which preserves the demonstrated cross-machine sequence. Copy one example at a time into its named shell. The `.ps1` sidecars intentionally contain only comment-block examples: opening or invoking them does not execute a batch of unrelated stages or automatically change the firewall. Copy the command lines inside the relevant block. The `.sql` files contain the exact read-only queries and must be opened in their respective database clients.

No new loops, functions, installation commands, IP-assignment commands, automated firewall restoration, `.Start()` parameters, or RRAS filter commands have been added. The Windows listener remains the minimal constructor plus `.Start()` implementation from the video. Original variables, port numbers, rule names, parameters and order are retained. Only destination IP literals are replaced with documented placeholders and quoted as strings.

## Files

| File | Target and purpose |
|---|---|
| [Command-Reference.md](Command-Reference.md) | Master reference, B-G order; separates terminals, hosts, GUI actions and commands. |
| [Windows-Listener-Reference.ps1](references/Windows-Listener-Reference.ps1) | Windows primary listener, socket inspection and E cleanup; inert copyable examples. |
| [Windows-Client-Tests-Reference.ps1](references/Windows-Client-Tests-Reference.ps1) | Standard Windows 11 client tests for B, C, D and G. |
| [WSL-Windows-Host-Reference.ps1](references/WSL-Windows-Host-Reference.ps1) | Elevated Windows-side WSL bonus steps and cleanup. |
| [Ubuntu-Netcat-Reference.md](references/Ubuntu-Netcat-Reference.md) | Ubuntu netcat, UFW status, second-terminal socket inspection and Ctrl+C cleanup. |
| [WSL-Ubuntu-Reference.md](references/WSL-Ubuntu-Reference.md) | Ubuntu WSL address inspection, netcat and separate terminal cleanup. |
| [SQL-Server-Verification.sql](references/SQL-Server-Verification.sql) | SQL Server instance name/version query for SSMS. |
| [Oracle-Verification.sql](references/Oracle-Verification.sql) | Database/container query for Oracle SQL Developer. |

## Prerequisites

### Common network and authorization

Use only systems you are authorized to administer. Establish routing between your client and destination networks before following the listener tests. Use available TCP ports and unique addresses that are valid for the configured prefixes and gateways. The source demonstrates VLAN2225 and VLAN711; substitute your own client/server VLANs without changing the role relationships.

The test source is a separate Windows 11 client. Both main destination systems already run OpenSSH Server on TCP 22; installation is not demonstrated. ICMP Echo Requests and TCP 22 remain permitted during selective blocking. RRAS routing and filter controls are prepared in advance; the video toggles the blocking condition, not a complete RRAS deployment.

### Linux and Windows listeners

Ubuntu 26.04 needs OpenBSD-style netcat, `ss`, and UFW for the shown status command. `sudo ufw status` inspects the existing setting; it does not disable a firewall. The author observes inactive UFW in the lab. Reproduction does not require disabling an otherwise-managed firewall; arrange authorized access to the required test traffic.

Use Windows PowerShell 5.1 with .NET Framework on the Windows listener host. The demonstrated host is Windows 11 Enterprise LTSC Evaluation. Use an elevated interactive session to create or modify Windows Firewall rules. Keep it open so the original `$listener` object is available for cleanup. Record the original enabled state of the existing ICMP rule before enabling it. The source's English display name must exist on the target machine; names and policy can differ in other environments.

### Application verification

Section F assumes SQL Server 2025 and Oracle Database 26ai are already deployed and configured on TCP 5050 and 5051, with the necessary firewall access. Have SSMS, Oracle SQL Developer and authorized database credentials. The source does not specify client-tool versions, the Oracle service name, database usernames, installation steps, TLS settings or database-listener configuration. Supply the connection details for your actual deployments; do not infer a default service name from the temporary-listener examples.

### WSL bonus

Use a Windows 11 host with Ubuntu under WSL 2, mirrored networking active, and Hyper-V Firewall On. Two host adapters on the destination VLAN carry the separate bonus addresses in the demonstrated setup. Verify the intended mirrored address with `ip a` before starting netcat. Applicable Windows host port rules must be permitted by the effective Hyper-V firewall policy, including host-policy merging where relevant. Managed policy may change the outcome; the combined rule is the demonstrated lab method, not a bypass for policy. Microsoft documents mirrored networking for Windows 11 22H2 and later; use a currently supported installation. No WSL installation, shutdown or network reconfiguration commands are added to this reference.

## Placeholder guide

Replace every occurrence of each token consistently. The labels `CLIENT_VLAN` and `SERVER_VLAN` describe roles, not literal shell arguments.

| Placeholder / role | Source example | Replacement requirement |
|---|---|---|
| `<WINDOWS_TEST_IPV4>` | `10.7.11.50` | Primary Windows temporary listener; later SQL Server endpoint on TCP 5050. Keep the address consistent across C, D and F. |
| `<LINUX_TEST_IPV4>` | `10.7.11.51` | Primary Ubuntu temporary listener; later Oracle endpoint on TCP 5051. Keep it consistent across B, D and F. |
| `<BONUS_WINDOWS_IPV4>` | `10.7.11.150` | Unused Windows host address tested against TCP 5050 in G. Separate from the deployed SQL Server address. |
| `<BONUS_WSL_IPV4>` | `10.7.11.151` | Other bonus host/mirrored address tested against WSL netcat on TCP 5051. Separate from the deployed Oracle address. |
| Client address (descriptive; not a command placeholder) | `10.22.25.226` | Your remote Windows 11 testing client on CLIENT_VLAN. |
| `CLIENT_VLAN` | VLAN2225 | Source client network. |
| `SERVER_VLAN` | VLAN711 | Routed destination network. |

TCP 5050, 5051 and 22 are retained as demonstrated, not generalized away. The firewall rule names are also retained so creation and cleanup match. The SSMS connection field is `tcp:<WINDOWS_TEST_IPV4>,5050`. Oracle SQL Developer uses host `<LINUX_TEST_IPV4>`, port `5051`, and your actual service name and credentials.

The final script does not specify a subnet mask. Do not infer one from the VLAN ID. The bonus `.150` and `.151` examples do not belong to `10.7.11.0/26`; use addressing/routing that actually accommodates your chosen endpoints. Avoid simultaneous address duplication when moving from test endpoints to deployed database systems.

`IPAddress.Any` is preserved. It means the Windows listener is not exclusively bound to the named test destination address. The netcat examples also do not explicitly select one local interface. The separate IPs specify where the remote client tests, not per-adapter isolation guarantees.

## Demonstrated workflow and verification

| Stage | Actions in the demonstrated order | Verification shown |
|---|---|---|
| B | Ubuntu UFW status -> client test before netcat -> start netcat -> `ss` in a second terminal -> client retest | Before the listener: failed TCP, successful ping in the observed output. After netcat: `TcpTestSucceeded: True`. |
| C | Create `$listener` -> create TCP rule -> enable existing ICMP rule -> `.Start()` -> `netstat` -> `Get-NetTCPConnection` -> remote client test | Local listening socket, potentially displayed as `0.0.0.0`, followed by a successful remote TCP test. |
| D | Block TCP 5050/5051 at RRAS -> test those ports -> test TCP 22 -> remove RRAS blocks -> retest 5050/5051 | Required ports fail while ping and TCP 22 remain available; then both required ports succeed without listener restarts. |
| E | Ctrl+C in Ubuntu -> `$listener.Stop()` in its original Windows session -> remove test TCP rule -> conditionally restore ICMP state | Cleanup actions shown; required RRAS path remains permitted for the applications. |
| F | Connect with SSMS -> execute SQL Server query -> connect with Oracle SQL Developer -> execute Oracle query | Successful database connections, authentication and query results. |
| G | Check WSL mirrored address -> start WSL netcat -> create/start Windows bonus listener -> add combined TCP rule -> client tests against bonus IPs -> Ctrl+C in WSL -> stop Windows bonus listener -> remove rule | Both bonus endpoint tests return True, followed by explicit cleanup. |

These observations are reported by the author in the supplied final script. They are not claims of tests executed in this preparation environment. A failed TCP test alone does not identify a firewall as the cause; the RRAS attribution is justified here by the controlled change. TCP 22 tests establish TCP connectivity, not an authenticated SSH session.

## Command explanations

| Command or element | Role in the demonstration |
|---|---|
| `sudo ufw status` | Inspect Ubuntu's UFW state without changing it. |
| `netcat -4 -l -k 5051` | IPv4 TCP listening on 5051, continuing after a connection completes. The command runs in the foreground. |
| `ss -ltnp` | Display listening TCP sockets with numeric addresses/ports and available process details. Use a separate terminal. |
| `TcpListener::new(IPAddress.Any, port)` | Create the listener object using the existing wildcard IPv4 binding. |
| `$listener.Start()` | Begin listening and queue connection requests; it does not add an application request handler. |
| `New-NetFirewallRule` | Create the port-based inbound permit rule using exactly the supplied parameters. |
| `Set-NetFirewallRule` | Enable the existing Echo Request rule; later restore its original disabled state only when that was the starting state. |
| `netstat ...` / `Get-NetTCPConnection` | View local TCP endpoint state; they do not establish remote reachability. |
| `Test-NetConnection -ComputerName ... -Port ...` | Test TCP connection establishment from the separate client. |
| `$listener.Stop()` | Stop the listener in the session that owns the object; independent of firewall-rule deletion. |
| `Remove-NetFirewallRule` | Delete only the named test rule created earlier. |
| `ip a` | Display WSL interface addresses before the bonus listener is started. |
| `@@SERVERNAME` / `@@VERSION` | Return SQL Server instance identification/version information after connection. |
| `SYS_CONTEXT('USERENV', ...)` | Return database and container names for the Oracle session. |

## Limits and operational cautions

The native example intentionally does not call `AcceptTcpClient()` or drain the pending queue. It preserves the demonstrated short connection-establishment test, not a sustained connection-handling service. Do not infer that it is a complete netcat equivalent or a reliable long-running load-test endpoint. No accept loop has been silently inserted.

The firewall rules intentionally retain their source parameters, with no added source-address or profile restrictions. Their names containing “Temp” do not make them expire automatically. Assess the scope and applicable policy for your environment; remove only test-created access and restore prior ICMP state when finished. Stopping a listener is not the same as deleting a firewall rule.

Do not run the E04 ICMP disable example when the rule was already enabled before the test. Do not delete built-in rules. Keep replacement application firewall access in place before removing any test-only rule still needed by a reused host. The supplied examples are instructional references, not an automated rollback plan.

The tests use IPv4 address literals. They do not verify DNS-based access, IPv6, UDP, TLS requirements, application authorization, or every feature of a database deployment. Section F verifies a connection, authentication and the displayed query, not application-wide functionality. Firewall or socket changes can affect other users; use an isolated or approved test window.

## Official references

The following official pages were checked during preparation. General cmdlet URLs may redirect to the current documentation view. The .NET Framework 4.8.1 view is a documentation reference, not a claim that the final script specifies the runtime patch version.

- [Ubuntu netcat manual](https://manpages.ubuntu.com/manpages/resolute/man1/nc_openbsd.1.html)
- [TcpListener (.NET Framework documentation view)](https://learn.microsoft.com/en-us/dotnet/api/system.net.sockets.tcplistener?view=netframework-4.8.1)
- [TCP client and listener overview](https://learn.microsoft.com/en-us/dotnet/fundamentals/networking/sockets/tcp-classes)
- [Test-NetConnection](https://learn.microsoft.com/en-us/powershell/module/nettcpip/test-netconnection)
- [Get-NetTCPConnection](https://learn.microsoft.com/en-us/powershell/module/nettcpip/get-nettcpconnection)
- [New-NetFirewallRule](https://learn.microsoft.com/en-us/powershell/module/netsecurity/new-netfirewallrule)
- [WSL networking](https://learn.microsoft.com/en-us/windows/wsl/networking)
- [Hyper-V firewall](https://learn.microsoft.com/en-us/windows/security/operating-system-security/network-security/windows-firewall/hyper-v-firewall)
- [TcpListener.Start](https://learn.microsoft.com/en-us/dotnet/api/system.net.sockets.tcplistener.start?view=netframework-4.8.1)
- [TcpListener.Stop](https://learn.microsoft.com/en-us/dotnet/api/system.net.sockets.tcplistener.stop?view=netframework-4.8.1)
- [Windows PowerShell 5.1](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_windows_powershell_5.1?view=powershell-5.1)
- [Set-NetFirewallRule](https://learn.microsoft.com/en-us/powershell/module/netsecurity/set-netfirewallrule)
- [Remove-NetFirewallRule](https://learn.microsoft.com/en-us/powershell/module/netsecurity/remove-netfirewallrule?view=windowsserver2025-ps)
- [netstat](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/netstat)
- [Ubuntu ss manual](https://manpages.ubuntu.com/manpages/resolute/man8/ss.8.html)
- [Ubuntu ip manual](https://manpages.ubuntu.com/manpages/resolute/man8/ip.8.html)
- [Ubuntu UFW manual](https://manpages.ubuntu.com/manpages/resolute/man8/ufw.8.html)
- [RRAS IP filtering reference (background; no added commands)](https://learn.microsoft.com/en-us/powershell/module/remoteaccess/add-remoteaccessipfilter?view=windowsserver2025-ps)
- [WSL configuration](https://learn.microsoft.com/en-us/windows/wsl/wsl-config)
- [Hyper-V firewall host-policy merging](https://learn.microsoft.com/en-us/powershell/module/netsecurity/set-netfirewallhypervvmsetting?view=windowsserver2025-ps)
- [Connect to SQL Server from another computer](https://learn.microsoft.com/en-us/sql/relational-databases/lesson-2-connecting-from-another-computer?view=sql-server-ver17)
- [SQL Server @@SERVERNAME](https://learn.microsoft.com/en-us/sql/t-sql/functions/servername-transact-sql?view=sql-server-ver17)
- [SQL Server @@VERSION](https://learn.microsoft.com/en-us/sql/t-sql/functions/version-transact-sql-configuration-functions?view=sql-server-ver17)
- [Oracle SYS_CONTEXT](https://docs.oracle.com/en/database/oracle/oracle-database/26/sqlrf/SYS_CONTEXT.html)

The RRAS reference provides background only. It does not imply that a PowerShell RRAS configuration command appears in the video.
