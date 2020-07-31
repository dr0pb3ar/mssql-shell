# MS SQL Shell
A simple shell interface for pentesting Microsoft SQL servers. Includes a couple of extra convenience commands for pentesting.

## Requirements
```sh
gem install tiny_tds colorize
apt install freetds-dev
```

## Usage
```
./mssql-shell.rb -u username -p password 192.168.123.5
Connected to '192.168.123.5'.
192.168.123.5> select @@version;
select @@version;
|                                                                                                                                                                                                                              |
|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
|Microsoft SQL Server 2017 (RTM) - 14.0.1000.169 (X64)
        Aug 22 2017 17:04:49
        Copyright (C) 2017 Microsoft Corporation
        Express Edition (64-bit) on Windows Server 2016 Standard 10.0 <X64> (Build 14393: ) (Hypervisor)
    |
192.168.123.5> EXEC sp_configure 'show advanced options'
EXEC sp_configure 'show advanced options'
|name                     |minimum    |maximum    |config_value    |run_value    |
|-------------------------|-----------|-----------|----------------|-------------|
|show advanced options    |0          |1          |1               |1            |
```

Use the `:xp_cmdshell` command instead of nmap 'xp_cmdshell' script:
```
192.168.123.5> :xp_cmdshell whoami
EXEC xp_cmdshell 'whoami';
|output                 |
|-----------------------|
|nt authority\system    |
|                       |
```
