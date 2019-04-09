Function Get-WindowsVersion
{
    <#
        .SYNOPSIS
          Get the version of Windows installed on the local computer, a remote computer, or a group of remote computers.

        .DESCRIPTION
          Get the version of Windows installed on the local computer, a remote computer, or a group of remote computers. Returned values include the hostname of the computer and the version of Windows installed. This function only works with Windows operating systems and cannot be used to identify other operating systems with PowerShell installed such as Linux.

        .PARAMETER ComputerName
          Specify one or more remote computers to pull the hostname and operating system version for.

        .EXAMPLE
          Get-WindowsVersion

          Returns the hostname and the version of Windows installed on the local computer.

        .EXAMPLE
          Get-WindowsVersion -ComputerName desktop01

          Returns the hostname and the version of Windows installed on the computer desktop01.

        .EXAMPLE
          Get-WindowsVersion -ComputerName desktop01,desktop02,desktop03

          Returns the hostname and the version of Windows installed on the computers desktop01, desktop02, and desktop03.

        .NOTES
          NAME    : Get-WindowsVersion
          AUTHOR  : BMO
          EMAIL   : brandonseahorse@gmail.com
          GITHUB  : github.com/Bmo1992
          CREATED : April 9, 2019
    #>
    [CmdletBinding()]
    Param
    (
        [Parameter(
            Mandatory=$False
        )]
        [string[]]$ComputerName
    )

    if($ComputerName)
    {
        ForEach($computer in $ComputerName)
        {
            Try
            {
                Get-WmiObject Win32_OperatingSystem -ComputerName $computer | Select CSName,Caption
            }
            Catch
            {
                Write-Error "Couldn't connect to $computer"
            }
        }
    }
    else
    {
        Get-WmiObject Win32_OperatingSystem | Select CSName,Caption
    }
}
