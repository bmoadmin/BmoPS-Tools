<#
#  Author  : BMO
#  Purpose : To automate a user creation process that's become increasingly time consuming
#            as more and more departments, users, and applications are added to a large
#            network. 
#  Created : September 11, 2018
#  Updated : September 25, 2018		 
#  Status  : Functional
#>

<#
    .SYNOPSIS
      Create-AutoUser.ps1 is a script intended to automate a large portion of the new user creation process
    .SYNTAX
      .\Create-AutoUser.ps1 -FirstName <string> -LastName <string> -DomainName <string> -TremplateUser <string> -Password <string>
    .EXAMPLE
      .\Create-AutoUser.ps1 -FirstName John -LastName Smith -DomainName bigcompany.local -TemplateUser jdoe
#>

<###############################

    Functionality currently missing from script:
        1) Error checking to confirm the ldap is not already taken in the database and subsequent suggestions
           for corrective measures
        2) Placing the new user in the same OU as the template user
        3) Creating a mailbox for the user by connecting to onprem exchange or o365

################################>

# Parameters to be passed to the script
[CmdletBinding()]
Param
(
    [Parameter(
        Mandatory=$True
    )]
    [string]$FirstName,
    [string]$LastName,
    [string]$DomainName,
    [string]$TemplateUser,
    [string]$Password
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
$upn_name = "$samaccountname@$DomainName"
$temp_password = ConvertTo-SecureString -String $Password -AsPlainText -Force
$template = Get-ADUser -Identity $TemplateUser
$get_ad_groups = Get-ADPrincipalGroupMembership -Identity $TemplateUser | Select -ExpandProperty name
$i=1

########### MAIN ############

# Check to confirm that the username is not already taken
While($i -lt $FirstName.Length)
{
    if(Get-ADUser $samaccountname)
    {
        Write-Host "It looks like the ldap $samaccountname already exists"
        $samaccountname = "$(($FirstName).Substring(0,$i))$LastName"

        $accept_new_name = Read-Host "Is $samaccountname okay instead? [y/n]?"
        if($accept_new_name -eq "y")
        {
            $upn_name = "$samaccountname@$DomainName"
            $i = $i + $FirstName.Length + 1
        }
        elseif($accept_new_name -eq "n")
        {
            $i = $i + 1
        }
        else
        {
            Throw "Unrecognized response, exiting program"
        }
    }
}

$final_check = [ordered]@{
    "Name"=$display_name
    "SamAccountName"=$samaccountname
    "UPN"=$upn_name
    "Parent OU"=(($template).distinguishedname -replace '^.+?,(CN|OU.+)','$1')
    "AD Groups"=$get_ad_groups
}

Write-Host "Are you sure you want to create a new user with the following properties?"
Write-Host $null

$final_check.Keys | ForEach {   
        " $_ => " + $final_check.Item($_) 
    }

Write-Host $null

$accept_user = Read-Host "Is this correct [y/n]?"

# If yes create the new user, if no say something and exit, else send invalid answer to stderr and die
if ($accept_user -eq "y") 
{
    New-ADUser -Name $display_name -GivenName $FirstName -Surname $LastName -DisplayName $display_name -SamAccountName $samaccountname `
    -AccountPassword $temp_password -UserPrincipalName $upn_name -Path $final_check.("Parent OU") -Enabled $True

    ForEach($group in $get_ad_groups)
    {
        Add-ADGroupMember -Identity $group -Members $samaccountname
    }
}
elseif ($accept_user -eq "n")
{
    throw "No action taken, exiting script"
}
else
{
    throw "Invalid selection, please rerun script"
}

