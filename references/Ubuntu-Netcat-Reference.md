# Test TCP Ports with PowerShell: A Native Windows Netcat Alternative

- **Author / channel:** Darien Hawkins / Darien's Tips
- **Purpose:** Linux shell reference for Ubuntu 26.04 test system at <LINUX_TEST_IPV4> on SERVER_VLAN.
- **Source script:** `PSNCALT_Title-Script_20261024.txt`
- **Preparation date:** 2026-10-24
- **Tested environment:** Author-reported demonstration: Windows 11 Enterprise LTSC Evaluation, Windows PowerShell 5.1 / .NET Framework, Ubuntu 26.04, Windows Server RRAS, SQL Server 2025, Oracle Database 26ai, and Windows 11 with Ubuntu under WSL 2. Exact Windows builds, .NET patch version and RRAS server version are not specified in the final script.
- **Usage notes:** Individual reference examples only. Replace angle-bracket IP placeholders before use. Select only the commands for the stated machine, shell and stage. Preserve the order across machines; do not run an entire reference file as a single script.

## Target environment

Ubuntu 26.04, OpenBSD-style netcat, ss, and UFW.

### B01 — Report UFW status; do not disable the firewall.

Target: Ubuntu 26.04 test system at <LINUX_TEST_IPV4> on SERVER_VLAN  
Shell: Ubuntu shell  
Privileges: sudo authorization for this status check.  
Prerequisites: Routing is already configured; UFW is installed.

```bash
sudo ufw status
```

### B03 — Start the IPv4 listener; retain this foreground terminal.

Target: Ubuntu 26.04 test system at <LINUX_TEST_IPV4> on SERVER_VLAN  
Shell: Ubuntu shell  
Privileges: Standard user for port 5051.  
Prerequisites: OpenBSD-style netcat installed; TCP 5051 is available.

```bash
netcat -4 -l -k 5051
```

### B04 — Inspect listening TCP sockets without altering the listener.

Target: Ubuntu 26.04 test system at <LINUX_TEST_IPV4> on SERVER_VLAN  
Shell: A second Ubuntu shell  
Privileges: Standard user; process details may be limited by permissions.  
Prerequisites: Leave B03 running in its original terminal.

```bash
ss -ltnp
```

### E01 — Stop the Linux temporary listener.

Target: Ubuntu 26.04 test system at <LINUX_TEST_IPV4> on SERVER_VLAN  
Shell: Original foreground netcat terminal  
Privileges: Same user that started netcat.  
Prerequisites: D04 verification complete.

Press Ctrl+C in the terminal running netcat. This is a keyboard action, not a shell command.
