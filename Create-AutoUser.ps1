#!/bin/pwsh
<#
#  Author  : BMO
#  Purpose : To automate a user creation process that's become increasingly time consuming
#            as more and more departments, users, and applications are added to a large
#            network. 
#  Created : September 11, 2018
#  Updated : September 12, 2018		 
#>

<#
    .SYNOPSIS
      Create-AutoUser.ps1
    .EXAMPLE
      .\Create-AutoUser.ps1 -FirstName John -LastName Smith -TemplateUser jdoe
#>

# Parameters to be passed to the script
[CmdletBinding()]
Param
(
    [Parameter(Mandatory=$True)]$FirstName,
    [Parameter(Mandatory=$True)]$LastName,
    [Parameter(Mandatory=$True)]$TemplateUser
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

$display_name = "$FirstName $LastName"
$samaccountname = "$($FirstName[0])$LastName"
$temp_password = ConvertTo-SecureString -String "ABcd1234*" -AsPlainText -Force
$template = Get-ADUser -Identity $TemplateUser
$get_ad_groups = Get-ADPrincipalGroupMembership -Identity $TemplateUser | Select -ExpandProperty name

########### MAIN ############

$final_check = @{
    "Name"=$display_name
    "ldap"=$samaccountname
    "parentou"=(($template).distinguishedname -replace '^.+?,(CN|OU.+)','$1')
    "adgroups"=$get_ad_groups
}

Write-Host "Are you sure you want to create a new user with the following properties?"
Write-Host $null
$hash.Keys | % { " $_ => " + $hash.Item($_) }
Write-Host $null

$accept_user = Read-Host "Is this correct [y/n]?"

# If yes create the new user, if no say something and exit, else send invalid answer to stderr and die
if ($accept_user -eq "y") 
{
    # New-ADUser -Name $samaccountname -NewPassword $temppassword
}
elseif ($accept_user -eq "n")
{
    throw "No action taken, exiting script"
}
else
{
    throw "Invalid selection, please rerun script"
}

