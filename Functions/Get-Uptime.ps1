Function Get-Uptime
{
    <#
        .SYNOPSIS
          Check the uptime of a computer.

        .DESCRIPTION
          Check the uptime of either the local computer or a remote computer by using the ComputerName argument. To get a remote computer
          uptime it needs to be on the same domain.

        .PARAMETER ComputerName
          Specify a different computer other then the local one retrieve the uptime from.

        .EXAMPLE
          Get-Uptime

          Get the uptime of the locahost.

        .EXAMPLE
          Get-Uptime -ComputerName DC01

          Get the uptime of the remote computer with the hostname DC01.

        .NOTES
          NAME    : Get-Uptime
          AUTHOR  : BMO
          EMAIL   : brandonseahorse@gmail.com
          GITHUB  : github.com/Bmo1992
          CREATED : October 25, 2018
    #>

    [CmdletBinding()]
    Param
    (
        [string]$ComputerName
    )

    if($ComputerName) 
    {
        $(Get-Date) - $((Get-CimInstance -ClassName Win32_OperatingSystem -Property * -ComputerName $ComputerName).LastBootUpTime) | `
        Select Days,Hours,Minutes,Seconds
    }
    else 
    {
        $(Get-Date) - $((Get-CimInstance -ClassName Win32_OperatingSystem -Property *).LastBootUpTime) | `
        Select Days,Hours,Minutes,Seconds
    }
}
