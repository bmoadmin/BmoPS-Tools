#!/bin/pwsh
<#
#  Author  : BMO
#  Purpose : To automate a user creation process that's become increasingly time consuming
#            as more and more departments, users, and applications are added to a large
#            network. 
#  Created : September 11, 2018		 
#>

<#
    .SYNOPSIS
      Create-AutoUser.ps1
    .EXAMPLE
      .\Create-AutoUser.ps1 -FirstName John -LastName Smith -TemplateUser jdoe
#>

# Required modules to run the cmdlets in the script
Import-Module ActiveDirectory

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

######### VARIABLES ##########
$displayname = "$FirstName $LastName"
$samaccountname = "$($FirstName[0])$LastName"
$temppassword = ConvertTo-SecureString -String "ABcd1234*" -AsPlainText -Force
$template = Get-ADUser -Identity $TemplateUser

New-ADUser -Name $samaccountname -NewPassword $temppassword



