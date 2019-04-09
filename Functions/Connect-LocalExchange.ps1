Function Connect-LocalExchange
{
    <#
        .SYNOPSIS
          Connect to a local installation of Exchange.

        .DESCRIPTION
          Connects to the locally installed Exchange shell. If the Exchange Command Shell is already loaded 

        .EXAMPLE
          Connect-LocalExchange

          Connect to the locally installed version of Exchange. 

        .NOTES
          NAME    : Connect-LocalExchange
          AUTHOR  : BMO
          EMAIL   : brandonseahorse@gmail.com
          GITHUB  : github.com/Bmo1992
          CREATED : April 9, 2019
    #>
    [CmdletBinding()]
    Param
    (
    )

    Function Test-Command
    {
        Param
        (
            [string]$Command
        )
        Try
        {
            Get-Command $Command -ErrorAction Stop
            Return $True
        }
        Catch
        {
            Return $False
        }
    }

    if(Test-Command "Get-Mailbox")
    {
        Throw "Already connected to Exchange! Exiting script"
    }
    else
    {
        $GetExchange = ". '$env:ExchangeInstallPath\bin\RemoteExchange.ps1'; `
                        Connect-ExchangeServer -auto -ClientApplication:ManagementShell "
        Invoke-Expression $GetExchange
    }
}
