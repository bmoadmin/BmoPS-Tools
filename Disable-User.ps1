<#
#  Author  : BMO
#  Purpose : Automate the disabling of AD Users.
#  Created : September 22, 2018
#  Updated : December 9, 2018
#  Status  : Unfinished
#>

<#
    .SYNOPSIS
      Disable-User.ps1 is a script intended to automate a large portion of the user offboarding process
    .EXAMPLE
      .\Disable-User.ps1 -Identity jdoe -DomainName bigcompany.local -DisabledOU "Terminated Users"
#>

# Parameters to be passed to the script.
[CmdletBinding()]
Param
(
    [Parameter(
        Mandatory=$True
    )]
    [string]$Users,
    [string]$DisabledPassword,
    [string]$DomainName,
    [string]$DisabledUserGroup,
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

# Required modules to run the cmdlets in the script.
Import-Module ActiveDirectory


######### VARIABLES ##########

$disabled_password = ConvertTo-SecureString -String $DisabledPassword -AsPlainText -Force
$disabled_ou_dn = (Get-ADOrganizationalUnit -Filter * | ?{ $_.Name -eq $DisabledOU }).DistinguishedName


########### MAIN ############

# Loop through each element of the Users array which is passed to the script as an argument. 
ForEach($user in $Users)
{
    # Get the distinguished name of the user, this will be needed to operate on later in the script.
    $user_distinguishedname = (Get-ADUser $user).DistinguishedName

    # Reset the user's password to the disabled password passed to the script by the DisabledPassword argument 
    Set-ADAccountPassword -Identity $user -NewPassword $disabled_password -Reset


    # Add the user to the Disabled user group passed to the script by the DisabledUserGroup argument. Get the sid of the disabled 
    # user group, grab the last 4 numbers in the sid and then set disabled user group as the user's primary group. 
    Add-ADGroupMember -Identity $DisabledUserGroup -Members $user
    $primary_group_sid = (Get-ADGroup $DisabledUserGroup).Sid
    [int]$primary_group_id = $primary_group_sid.Substring($primary_group_sid.LastIndexOf("-")+1)
    Set-ADObject -Identity $(Get-ADUser $user | Select -ExpandProperty DistinguishedName) -Replace `
    @{primaryGroupID="$primary_group_id"}


    # Get all the groups a user is in besides the disabled user group and then remove them for all those other groups.
    $groups = Get-ADUser $user -Properties * | Select -ExpandProperty MemberOf | `
    Where{ 
        $_ -notmatch $DisabledUserGroup
    }
    ForEach($group in $groups)
    {
        Remove-ADGroupMember -Identity $group -Members $user -Confirm:$False
    }


    # Finally disable the user and move them to the disabled user OU.
    Disable-ADAccount -Identity $user
    Move-ADObject -Identity $user_distinguishedname -TargetPath $disabled_ou_dn

}
