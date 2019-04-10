Function Get-Uptime
{
    <#
        .SYNOPSIS
          Check the uptime of the local computer, a remote computer, or multiple remote computers.

        .DESCRIPTION
          Check the uptime of either the local computer or a remote computer by using the ComputerName argument. To get a remote computer
          uptime it needs to be on the same domain. Multiple computers can also be specified.

        .PARAMETER ComputerName
          Specify the remote computer or computers to check the uptime of.

        .EXAMPLE
          Get-Uptime

          Get the uptime of the locahost.

        .EXAMPLE
          Get-Uptime -ComputerName desktop01

          Get the uptime of the remote computer with the hostname desktop01.

        .EXAMPLE
          Get-Uptime -ComputerName desktop01,desktop02,desktop03

          Get the uptime of the remote computers desktop01, desktop02, and desktop03.

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
        [string[]]$ComputerName
    )

    if($ComputerName) 
    {
        Foreach($computer in $ComputerName)
        {
            Try
            {
                if(Test-Connection -ComputerName $computer -Count 1 -ErrorAction SilentlyContinue)
                {
                    $(Get-Date) - `
                    $((Get-CimInstance -ClassName Win32_OperatingSystem -Property * -ComputerName $computer).LastBootUpTime) | `
                    Select @{
                            Label='Computer';
                            Expression=
                            {
                                $computer
                            }
                        },
                        @{
                            Label='Days';
                            Expression=
                            {
                                $_.Days
                            } 
                        },
                        @{
                            Label='Hours';
                            Expression=
                            {
                                $_.Hours
                             }
                        },
                        @{
                            Label='Minutes';
                            Expression=
                            {
                                $_.Minutes
                            } 
                        },
                        @{
                            Label='Seconds';
                            Expression=
                            {
                                $_.Seconds
                            }
                        }
                }
            }
            Catch
            {
                Write-Error "Couldn't connect to $computer. Please confirm it's on an try again."
            }
        }
    }
    else 
    {
        $(Get-Date) - $((Get-CimInstance -ClassName Win32_OperatingSystem -Property *).LastBootUpTime) | `
        Select Days,Hours,Minutes,Seconds
    }
}
