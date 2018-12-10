<#
#  Author  : BMO
#  Purpose : Automate the disabling of AD Users.
#  Created : September 22, 2018
#  Updated : December 10, 2018
#  Status  : Functional
#>
<#
    .SYNOPSIS
      Automatically disable one or more users.  

    .DESCRIPTION
      Automatically handle disabling one or mutliple active directory user account by removing them from all security groups except a 
      single approved group for disabled accounts, resetting their password, and moving them to a disabled user organizational unit. 

    .PARAMETER Users
      Specifies all the users to be disabled by the script.
      Will only accept the SamAccountName of a user. 

    .PARAMETER DisabledPassword
      Specified the password to be given to the diabled users. Will only accept type System.String

    .PARAMETER DisabledUserGroup
      Specifies the group to place the disabled users in and set as their primary group.

    .PARAMETER DisabledOU
      Specified the active directory organizational unit to move all the disabled user accounts to.

    .EXAMPLE
      .\Disable-User.ps1 -Users "jdoe" -DiabledPassword "Disabled-P@55" -DisabledUserGroup "Terminated-Users" -DisabledOU "Terminated Users"
    
      Disable a single user with a samaccount name of jdoe, reset his password to Disabled-P@55, place him in the Terminated-Users 
      security group and set it as the primary group, and move him to the "Terminated Users" organizational unit. 

    .EXAMPLE
      .\Disable-User.ps1 -Users "jdoe","hjohnson","kcrawford" -DisabledPassword "Disabled-P@55" -DisabledUserGroup "Disabled" -DisabledOU "Disabled"

      Disable users jdoe, hjohnson, and kcrawford.  Reset all their passwords to Disabled-P@55, place them all in the Disabled group and
      set it as the primary group for all, and move every user to the Disabled organizational unit. 

    .NOTES
        github.com/Bmo1992
#>

# Parameters to be passed to the script.
[CmdletBinding()]
Param
(
    [Parameter(
        Mandatory=$True
    )]
    [string[]]$Users,
    [string]$DisabledPassword,
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
Import-Module ActiveDirectory -ErrorAction SilentlyContinue


######### GLOBAL VARIABLES ##########

$ErrorActionPreference = "SilentlyContinue"
$disabled_password = ConvertTo-SecureString -String $DisabledPassword -AsPlainText -Force
$disabled_ou_dn = (Get-ADOrganizationalUnit -Filter * | ?{ $_.Name -eq $DisabledOU }).DistinguishedName

############### MAIN ################

# Before running the main portion of the script, check that all arguments passed to the script exist in active directory.
# Check to verify that the organizational unit specified by the DisabledOU argument exists in active directory. If not exit the script.
if(-Not $(Get-ADOrganizationalUnit -Identity $disabled_ou_dn))
{
    Write-Error "Organizational Unit $DisabledOU not found, confirm that you've spelled the OU name correctly.  Check by using the Get-ADOrganizationalUnit cmdlet or reviewing ADUC then run the script again." -ErrorAction Stop
}

# Check to verify that the group specified by the DisabledUserGroup argument exists in active directory. If not exit the script.
if(-Not $(Get-ADGroup $DisabledUserGroup))
{
    Write-Error "Group $DisabledUserGroup not found, confirm that you've spelled the group name correctly. Check by using Get-ADGroup cmdlet or reviewing the group properties in ADUC then run the script again." -ErrorAction Stop
}

# Check to verify that each user exists in active directory, if not exit the script.
ForEach($user in $Users)
{
    if(-Not $(Get-ADUser -Identity $user))
    {
        Write-Error "Account $Users not found, confirm that you've spelled the SamAccountName correctly. Check by using the Get-ADUser cmdlet or reviewing the account properties in ADUC then run the script again." -ErrorAction Stop
    }
}

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

    # Implemented bug fix for powershell remoting. When remoting, primary_group_sid will return as .NET type System.String 
    # whereas when run locally it returns as System.Security.Principal.SecurityIdentifier; Created a check to confirm 
    # what type is returned by primary_group_sid to fix the errors caused by this.
    $group_type_name = ($primary_group_sid | Get-Member).TypeName | Get-Unique
    if($group_type_name -eq "System.String")
    {
        [int]$primary_group_id = $primary_group_sid.Substring($primary_group_sid.LastIndexOf("-")+1)
    }
    else
    {
        [int]$primary_group_id = $primary_group_sid.Value.Substring($primary_group_sid.Value.LastIndexOf("-")+1)
    }
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
