<#
#  Author  : BMO
#  Purpose : Automate the disabling of AD Users 
#  Created : September 22, 2018
#  Status  : Unfinished
#>

<#
    .SYNOPSIS
      Disable-User.ps1 is a script intended to automate a large portion of the user offboarding process
    .EXAMPLE
      .\Disable-User.ps1 -Identity jdoe -DomainName bigcompany.local -DisabledOU "Terminated Users"
#>

# Parameters to be passed to the script
[CmdletBinding()]
Param
(
    [Parameter(
        Mandatory=$True
    )]
    [string]$Identity,
    [string]$DomainName,
    [string]$DisabledOU
)

# Check to confirm this script is being run by an admin in an elevated powershell prompt or else exit. Cmdlets needed to create users
# will not succeed otherwise. 
$identity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$principal = [System.Security.Principal.WindowsPrincipal] $identity
$role = [System.Security.Principal.WindowsBuiltInRole] "Administrator"

if(-not $principal.IsInRole($role))
{
    throw "This script requires elevated permissions, please confirm youre running from an elevated powershell prompt as an administrator"
}

# Required modules to run the cmdlets in the script
Import-Module ActiveDirectory

######### VARIABLES ##########

$disabled_password = ConvertTo-SecureString -String "Terminated-1982" -AsPlainText -Force
$get_ad_groups = Get-ADPrincipalGroupMembership -Identity $TemplateUser | Select -ExpandProperty name

########### MAIN ############

Disable-ADACcount -Identity $Identity

