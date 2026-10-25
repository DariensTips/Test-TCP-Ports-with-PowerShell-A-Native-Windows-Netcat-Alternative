# Test TCP Ports with PowerShell: A Native Windows Netcat Alternative

- **Author / channel:** Darien Hawkins / Darien's Tips
- **Purpose:** Linux shell reference for Ubuntu WSL 2 instance on the Windows bonus host.
- **Source script:** `PSNCALT_Title-Script_20261024.txt`
- **Preparation date:** 2026-10-24
- **Tested environment:** Author-reported demonstration: Windows 11 Enterprise LTSC Evaluation, Windows PowerShell 5.1 / .NET Framework, Ubuntu 26.04, Windows Server RRAS, SQL Server 2025, Oracle Database 26ai, and Windows 11 with Ubuntu under WSL 2. Exact Windows builds, .NET patch version and RRAS server version are not specified in the final script.
- **Usage notes:** Individual reference examples only. Replace angle-bracket IP placeholders before use. Select only the commands for the stated machine, shell and stage. Preserve the order across machines; do not run an entire reference file as a single script.

## Target environment

Ubuntu under WSL 2; Windows 11 host; mirrored networking.

### G01 — Confirm the expected mirrored interface address is present.

Target: Ubuntu WSL 2 instance on the Windows bonus host  
Shell: Ubuntu WSL shell  
Privileges: Standard user.  
Prerequisites: G00 settings are active.

```bash
ip a
```

### G02 — Start the WSL Linux listener and leave this terminal running.

Target: Ubuntu WSL 2 instance on the Windows bonus host  
Shell: Ubuntu WSL shell  
Privileges: Standard user for port 5051.  
Prerequisites: G01 checked; netcat installed and TCP 5051 available.

```bash
netcat -4 -l -k 5051
```

### G06 — Stop the WSL netcat listener.

Target: Ubuntu WSL 2 instance on the Windows bonus host  
Shell: Original foreground Ubuntu WSL netcat terminal  
Privileges: Same user that started netcat.  
Prerequisites: G05 complete.

Press Ctrl+C in the Ubuntu WSL terminal running netcat.
