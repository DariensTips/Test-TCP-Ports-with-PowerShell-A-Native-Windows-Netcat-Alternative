-- Title: Test TCP Ports with PowerShell: A Native Windows Netcat Alternative
-- Author / channel: Darien Hawkins / Darien's Tips
-- Source script: PSNCALT_Title-Script_20261024.txt
-- Preparation date: 2026-10-24
-- Purpose: Display SQL Server instance name and version.
-- Tested environment: SQL Server 2025 via SSMS.
-- Usage notes: F01 connected successfully. Run only in the stated database client.
-- Target: SQL Server 2025 session from the administrative client
-- Shell: SSMS T-SQL query window
-- Privileges: Database account authorized to connect and execute the demonstrated read-only query.

SELECT @@SERVERNAME AS ServerName,
       @@VERSION AS SQLServerVersion;
