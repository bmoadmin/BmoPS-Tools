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
      Create-AutoUser
    .EXAMPLE
      .\Create-AutoUser.ps1
#>

# required modules to run the cmdlets in the script
Import-Module ActiveDirectory

Param
(
    [Parameter(Mandatory=$True)]$FirstName,
    [Parameter(Mandatory=$True)]$LastName,
    [Parameter(Mandatory=$True)]$TemplateUser
)

$displayname = "$FirstName $LastName"
$samaccountname = "$($FirstName[0])$LastName"
$temppassword = ConvertTo-SecureString -String "ABcd1234*" -AsPlainText -Force
$template = Get-ADUser -Identity $TemplateUser

New-ADUser -Name $samaccountname -NewPassword $temppassword



