-- Title: Test TCP Ports with PowerShell: A Native Windows Netcat Alternative
-- Author / channel: Darien Hawkins / Darien's Tips
-- Source script: PSNCALT_Title-Script_20261024.txt
-- Preparation date: 2026-10-24
-- Purpose: Display the database and container names.
-- Tested environment: Oracle Database 26ai via Oracle SQL Developer.
-- Usage notes: F03 connected successfully. Run only in the stated database client.
-- Target: Oracle Database 26ai session from the administrative client
-- Shell: Oracle SQL Developer SQL worksheet
-- Privileges: Database account authorized to connect and execute the demonstrated read-only query.

SELECT SYS_CONTEXT('USERENV', 'DB_NAME') AS DatabaseName,
       SYS_CONTEXT('USERENV', 'CON_NAME') AS ContainerName
FROM DUAL;
