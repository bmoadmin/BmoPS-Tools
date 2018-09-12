<#
#  Author  : BMO
#  Purpose : Utilize a single script to log into a variety of remote servers and load the proper powershell modules
#            for that server based on its role.
#  Created : September 12, 2018
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
    [Parameter(Mandatory=$True, ParameterSetName="Hostname")]
    [string]$Hostname
    [Parameter(Mandatory=$True, ParameterSetName="DC")]
    [switch]$DomainController,
    [Parameter(Mandatory=$True, ParameterSetName="Exchange")]
    [switch]$Exchange,
    [Parameter(Mandatory=$True, ParameterSetName="O365")]
    [switch]$Office365
)

$user_credential = Get-Credential

$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://gcexchange.countyofglenn.local/PowerShell -Credential $UserCredential -Authentication Kerberos

Import-Session $Session





