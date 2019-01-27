Function Create-AutoUser
{
    <#
        .SYNOPSIS
          Automate the new active directory user creation process.

        .DESCRIPTION
          Automate a large portion of the user creation process by entering the first name, last name, and template user.  The template user
          serves as a basis for the parent organizational unit, security group membership, and logon scripts.

        .PARAMETER FirstName
          Specifies the first name of the new user to create.

        .PARAMETER LastName
          Specifies the last name of the new user to create.

        .PARAMETER DomainName
          Specifies the domain name that the user is being created on.

        .PARAMETER TemplateUser
          Specifies the currently existing user on which to base the new users parent organizational unit, security group membership, and logon script.

        .PARAMETER Password
          Specifies the newly created users password. 

        .EXAMPLE
          Create-AutoUser -FirstName John -LastName Smith -DomainName bigcorp.local -TemplateUser jdoe

          Creates a new user named John Smith on the bigcorp.local domain based of the user jdoe.

        .NOTES
          NAME    : Create-AutoUser
          AUTHOR  : BMO
          EMAIL   : brandonseahorse@gmail.com
          GITHUB  : github.com/Bmo1992
          CREATED : September 10, 2018
    #>

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
        Throw "This script requires elevated permissions, please confirm youre running from an elevated powershell prompt as an administrator"
    }

    # Required modules to run the cmdlets in the script
    Import-Module ActiveDirectory

    ######### VARIABLES ##########

    $display_name = "$FirstName $LastName"
    $samaccountname = "$($FirstName[0])$LastName"
    $email = "$samaccountname@$DomainName.net"
    $temp_password = ConvertTo-SecureString -String $Password -AsPlainText -Force
    $template = Get-ADUser -Identity $TemplateUser -Properties *
    $get_ad_groups = Get-ADPrincipalGroupMembership -Identity $TemplateUser | Select -ExpandProperty name
    $i=1

    ########### MAIN ############

    # Check to confirm that the username is not already taken
    if(Get-ADUser $samaccountname)
    {
        While($i -lt $FirstName.Length)
        {
            Write-Host "It looks like the ldap $samaccountname already exists"
            $samaccountname = "$(($FirstName).Substring(0,$i))$LastName"

            $accept_new_name = Read-Host "Is $samaccountname okay instead? [y/n]?"
            if($accept_new_name -eq "y")
            {
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
        "Parent OU"=(($template).distinguishedname -replace '^.+?,(CN|OU.+)','$1')
        "AD Groups"=$get_ad_groups
        "Logon Script"=($template).ScriptPath
    }

    Write-Host "Are you sure you want to create a new user with the following properties?"
    Write-Host $null

    $final_check.Keys | `
        ForEach 
        {    
            " $_ => " + $final_check.Item($_) 
        }

    Write-Host $null
    $accept_user = Read-Host "Is this correct [y/n]?"

    # If yes create the new user, if no say something and exit, else send invalid answer to stderr and die
    if ($accept_user -eq "y") 
    {
        New-ADUser -Name $display_name -GivenName $FirstName -Surname $LastName -DisplayName $display_name -SamAccountName $samaccountname `
        -AccountPassword $temp_password -UserPrincipalName $upn_name -Path $final_check.("Parent OU") -ScriptPath `
        $final_check("Logon Script") -Enabled $True

        ForEach($group in $get_ad_groups)
        {
            Add-ADGroupMember -Identity $group -Members $samaccountname
        }
    }
    elseif ($accept_user -eq "n")
    {
        Throw "No action taken, exiting script"
    }
    else
    {
        Throw "Invalid selection, please rerun script"
    }
}
