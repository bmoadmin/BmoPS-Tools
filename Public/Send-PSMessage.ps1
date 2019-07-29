Function Send-PSMessage
{
    <#
        .SYNOPSIS
          Send a message to one or more remote computers with powershell.

        .DESCRIPTION
          Send a message to one or more remote computers with powershell. Must have the power to create a process on the remotes computers.

        .PARAMETER Message
          Specify the message to send to the remote computer/computerss.

        .PARAMETER ComputerName
          Specify the name of the remote computer/computers to send the message to.

        .EXAMPLE
          Send-PSMessage -ComputerName desktop01 -Message "Rebooting in 5 minutes, please logoff immediatly"

          Send the message "Rebooting in 5 minutes, please logoff immediatly" to the computer desktop01.

        .EXAMPLE
          Send-PSMessage -ComputerName desktop01,desktop02,desktop03 "Rebooting in 5 minutes, please logoff immediatly"

          Send the message "Rebooting in 5 minutes, please logoff immediatly" to the computers desktop01, desktop02, and desktop03.

        .NOTES
          NAME    : Send-PSMessage
          AUTHOR  : BMO
          EMAIL   : brandonseahorse@gmail.com
          GITHUB  : github.com/Bmo1992
          CREATED : April 8, 2019
    #>
    [CmdletBinding()]
    Param
    (
        [Parameter(
            Mandatory=$True
        )]
        [string]$Message,
        [string[]]$ComputerName
    )

    ForEach($computer in $ComputerName)
    {
        Try
        {
            Invoke-WmiMethod -Path Win32_Process -Name Create -ArgumentList "msg * $Message" -ComputerName $computer
        }
        Catch
        {
            Write-Error "Couldn't connect to $computer, please confirm the computer is on and try again"
        }
    }
}
