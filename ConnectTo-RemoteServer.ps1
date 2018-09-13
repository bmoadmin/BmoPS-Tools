<#
#  Author  : BMO
#  Purpose : Utilize a single script to log into a variety of remote servers and load the proper powershell modules
#            for that server based on its role.
#  Created : September 12, 2018
#  Updated : September 13, 2018
#>

<#
    .SYNOPSIS
      ConnectTo-RemoteServer.ps1
    .EXAMPLE
      .\ConnectTo-RemoteServer.ps1 -DomainController -Hostname exchange.company.local
#>

# Parameters to be passed to the script
[CmdletBinding(DefaultParameterSetName="Hostname")]
Param
(
    [Parameter(
        Mandatory=$True, 
        ParameterSetName="Hostname"
    )]
    [string]$Hostname,
    [Parameter(
        Mandatory=$True, 
        Position = 0, 
        ParameterSetName="ServerType"
    )]
    [switch]$DomainController,
    [switch]$Exchange,
    [switch]$Office365
)

$user_credential = Get-Credential

if($Exchange)
{
    $Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://$Hostname/PowerShell `
    -Credential $UserCredential -Authentication Kerberos
    Import-Session $Session
}
elseif($DomainController)
{
    Import-Session $Session
}
elseif($Office365)
{
    Import-Session $Session
}
else
{
    Throw "No remote server type was specified, please rerun script and specify a server type."
} 


