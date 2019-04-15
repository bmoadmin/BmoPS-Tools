# BmoPS-Tools

BmoPS-Tools is a PowerShell module full of scripts I've written to simplify many daily tasks performed during daily troubleshooting.

## Table of Contents
- [Usage](#usage)
  - [Installation](#installation)
  - [Commands](#commands)
    - [Add-AutoUser](#Add-AutoUser)
    - [Connect-LocalExchange](#Connect-LocalExchange)
    - [Connect-RemoteServer](#Connect-RemoteServer)
    - [Connect-VM](#Connect-VM)
    - [Disable-User](#Disable-User)
    - [Get-LastLogon](#Get-LastLogon)
    - [Get-MappedDrives](#Get-MappedDrives)
    - [Get-OldComputer](#Get-OldComputer)
    - [Get-OldUser](#Get-OldUser)
    - [Get-RDPState](#Get-RDPState)
    - [Get-UACState](#Get-UACState)
    - [Get-Uptime](#Get-Uptime)
    - [Get-WindowsVersion](#Get-WindowsVersion)
    - [Remove-Printers](#Remove-Printers)

## Usage

How do.

### Installation

Some stuff on how to install.

### Commands

The following are the commands available in the module.

#### Connect-RemoteServer

```powershell
Connect-RemoteServer -DomainController -Hostname DC01
```
Starts a PS remote session with a specific server and loads the appropriate modules from that remote session based on the server's role.

#### Connect-VM

```powershell
Connect-VM -VMName vm01 
```
Connect to the console of one or more Hyper-V vm's.  The VM can be on the local Hyper-V host or a remote host. Remote hosts can be spcified with the -Hostname argument. In order to run this command the Hyper-V role must be installed on the machine its being run from.

#### Disable-User

```powershell
Disable-User
```
#### Get-MappedDrive

Returns information about all the mapped drives on the local or a remote computer. The -Simple switch will only return the assigned drive letter and UNC path to the file share.

```powershell
Get-MappedDrive -ComputerName desktop01 -Simple
```
```text
name providername
---- ------------
F:   \\filesrv01\finance
H:   \\filesrv01\HumanResources
S:   \\filesrv01\Sales
```

#### Get-OldComputer

```powershell
Get-OldComputer
```

#### Get-OldUser

```powershell
Get-OldUser
```

#### Get-Uptime

Returns the uptime of one or more remote computers. By default it will pull the uptime of the local computer.

```powershell
Get-Uptime -ComputerName desktop01,desktop02,desktop03
```
```text
Computer : desktop01
Days     : 20
Hours    : 3
Minutes  : 18
Seconds  : 5

Computer : desktop02
Days     : 5
Hours    : 20
Minutes  : 33
Seconds  : 7

Computer : desktop03
Days     : 0
Hours    : 5
Minutes  : 45
Seconds  : 33
```
