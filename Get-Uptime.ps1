<#
#  Author  : BMO
#  Purpose : Get the uptime of a computer. By default it pulls the local uptime but a remote PC can be specified with the 
#            -ComputerName argument.
#  Created : October 25, 2018
#  Status  : Finished
#>

<#
    .SYNOPSIS
      Get-Uptime.ps1 is a script to get the local uptime of a PC or the uptime of a remote PC.
    .Syntax
      Get-Uptime.ps1 -ComputerName <string>
    .EXAMPLE
      Get-Uptime.ps1 -ComputerName DC01
#>

[CmdletBinding()]
Param
(
    [string]$ComputerName
)

if($ComputerName) {
    $(Get-Date) - $((Get-CimInstance -ClassName Win32_OperatingSystem -Property * -ComputerName $ComputerName).LastBootUpTime) | `
    Select Days,Hours,Minutes,Seconds
}
else {
    $(Get-Date) - $((Get-CimInstance -ClassName Win32_OperatingSystem -Property *).LastBootUpTime) | `
    Select Days,Hours,Minutes,Seconds
}
