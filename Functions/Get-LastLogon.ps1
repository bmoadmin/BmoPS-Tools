Function Get-LastLogon
{
    <#
        .SYNOPSIS
          Get the last logon times for each user on the local or a remote computer.

        .DESCRIPTION
          Get the lasts logon times for each user on the local computer, a remote computer, or multiple remote computers. The remote computers can be specified with the ComputerName argument.

        .PARAMETER ComputerName
          Specify one or more remote computers to get the last logon time from.

        .EXAMPLE
          Get-LastLogon

          Get the last logon times for all users on the local computer.

        .EXAMPLE
          Get-LastLogon -ComputerName desktop01

          Get the last logon times for all users on the remote computer desktop01.

        .EXAMPLE
          Get-LastLogon -ComputerName desktop01,desktop02,desktop03

          Get the last logon times for all users on the remote computers desktop01, desktop02, and desktop03.

        .NOTES
          NAME    : Get-LastLogon
          AUTHOR  : BMO
          EMAIL   : brandonseahorse@gmail.com
          GITHUB  : github.com/Bmo1992
          CREATED : April 8, 2019
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
                if(Test-Connection -ComputerName $computer -Count 1 -ErrorAction SilentlyContinue)
                {
                    Write-Host $computer
                    Get-ChildItem "\\$computer\c$\Users" -ErrorAction SilentlyContinue | Sort LastWriteTime -Descending | `
                    Select Name,LastWriteTime
                }
            }
            Catch
            {
                Throw "Can't connect to $computer, please confirm it's on and try again."
            }
        }
    }
    else
    {
        Get-ChildItem "C:\Users\" -ErrorAction SilentlyContinue | Sort LastWriteTime -Descending | Select Name,LastWriteTime
    }
}
