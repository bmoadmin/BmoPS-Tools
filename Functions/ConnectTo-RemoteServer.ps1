Function ConnectTo-RemoteServer
{
    <#
        .SYNOPSIS
          Automatically establish a PS Session with a remote server.

        .DESCRIPTION
          Automatically establish a PS Session with a remote server and load the correct active directory modules to interact with it by passing the primary server role to the script as an argument.  The hostname or IPv4 address of the remote server is required to make a connection.

        .PARAMETER Hostname
          The hostname of the remote server, this is the only required parameter.

        .PARAMETER DomainController
          This parameter tells the script that the remote server is a Domain Controller and to load the ActiveDirectory and GroupPolicy powershell modules.

        .PARAMETER Exchange
          This parameter tells the script that the remote server is on premesis exchange and to load the remote exchange DB.

        .PARAMETER FileServer
          This parameter tells the script that the remote server is a File Server and to load the smbshare powershell module.

        .PARAMETER Office365
          This parameter tells the script that the remote server is Exchange Online and to connect to the powershell liveid.

        .EXAMPLE
          ConnectTo-RemoteServer -Hostname exchange.bigcorp.local -Exchange

          Start a remote PS Session with the server named exchange.bigcorp.local and load the remote Exchange DB. 

        .EXAMPLE
          ConnectTo-RemoteServer -Hostname pdc.bigcorp.local -DomainController

          Start a remote PS Session with the server named pdc.bigcorp.local and load the ActiveDirectory and GroupPolicy modules.

        .EXAMPLE
          ConnectTo-RemoteServer -Hostname filesrv.bigcorp.local -FileServer

          Start a remote PS Session with the server named filesrv.bigcorp.local and load the smbshare powershell module

        .EXAMPLE
          ConnectTo-RemoteServer -Hostname outlook.office365.com -Office365

          Start a remote PS Session with exchange online.        

        .NOTES
          NAME    : ConnectTo-RemoteServer
          AUTHOR  : BMO
          EMAIL   : brandonseahorse@gmail.com
          GITHUB  : github.com/Bmo1992
          CREATED : Setpember 28, 2018
    #>

    # The hostname is required for any login, the other parameters allow you to specify what type of server youre logging into.
    [CmdletBinding()]
    Param
    (
        [Parameter(
            Mandatory=$True 
        )]
        [string]$Hostname,
        [Parameter(
        )]
        [switch]$DomainController,
        [switch]$Exchange,
        [switch]$FileServer,
        [switch]$Office365
    )

    # Get the credentials from the user required to log into the remote server
    $user_credential = Get-Credential -Message "Enter the credentials needed to log into the $Hostname"

    # Check which server type was specified as a function argument and execute the necessary steps to log into that specific server.
    if($Exchange)
    {
        $Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://$Hostname/PowerShell/ `
        -Credential $user_credential -Authentication Kerberos
        Import-PSSession $Session
    }
    elseif($DomainController)
    {
        Set-ExecutionPolicy Unrestricted -Force
        $Session = New-PSSession -ComputerName $Hostname -Credential $user_credential -Authentication Kerberos
        Invoke-Command $Session -ScriptBlock { Import-Module ActiveDirectory,GroupPolicy }
        Import-PSSession $Session -module ActiveDirectory,GroupPolicy
    }
    elseif($FileServer)
    {
        Set-ExecutionPolicy Unrestricted -Force
        $Sessions = New-PSSession -ComputerName $Hostname -Credential $user_credential -Authentication Kerberos
        Invoke-Command $Session -ScriptBlock { Import-Module smbshare }
        Import-PSSession $Session -module smbshare
    }
    elseif($Office365)
    {
        $Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://$Hostname/powershell-liveid/ `
        -Credential $user_credential -Authentication Basic -AllowRedirection
        Import-PSSession $Session -DisableNameChecking
    }
    else
    {
        Throw "No remote server type was specified, please rerun script and specify a server type."
    } 
}
