<#
#  Author  : BMO
#  Purpose : Utilize a single script to log into a variety of remote servers and load the proper powershell modules
#            for that server based on its role.
#  Created : September 12, 2018
#  Updated : September 14, 2018
#>

<#
    .SYNOPSIS
    Utilize a single script to log into a variety of remote powershell sessions.
    .DESCRIPTION
    By passing the kind of remote powershell session you'll connect to this script will automatically choose the needed syntax to sign in.
    .SYNTAX
    ./ConnectTo-RemoteServer.ps1 -Exchange -Hostname exchange.company.local
    ./ConnectTo-RemoteServer.ps1 -DomainController -hostname dc01.company.local
    ./ConnectTo-RemoteServer.ps1 -Office365 -Hostname outlook.office365.com
#>

# Parameters to be passed to the script
[CmdletBinding()]
# DefaultParameterSetName="Hostname")]
Param
(
    [Parameter(
        Mandatory=$True 
       # ParameterSetName="Hostname"
    )]
    [string]$Hostname,
    [Parameter(
       # ParameterSetName="ServerType"
    )]
    # [switch]$DomainController,
    [switch]$Exchange,
    [switch]$Office365
)

$user_credential = Get-Credential
Invoke-ExecutionPolicy Unrestricted -Force


if($Exchange)
{
    $Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://$Hostname/PowerShell/ `
    -Credential $user_credential -Authentication Kerberos
    Import-PSSession $Session
}
elseif($DomainController -ne $null)
{
    $Session = New-PSSession -ComputerName $Hostname -Credential $user_credential -Authentication Kerberos
    Invoke-Command $Session -ScriptBlock { Import-Module ActiveDirectory,GroupPolicy }
    Import-PSSession $Session -module ActiveDirectory,GroupPolicy
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


