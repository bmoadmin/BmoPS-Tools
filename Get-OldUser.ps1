<#
#  Author  : BMO
#  Purpose : Find all users that havn't logged into the Domain in 30 or more days { that arn't disabled } 
#  Created : September 17, 2018
#  Updated : October 10, 2018
#  Status  : Finished
#>
<#
    .SYNOPSIS
      See who has not logged into the domain in a certain number of days.

    .DESCRIPTION
      Get all users who have not logged into the domain in the numbers of days specified by the NumDays argument. In order to run you
      must be connected to a domain controller and have adequate permissions to view the attributes of active directory objects.

    .PARAMETER NumDays
      Specifically the number of days before the current date you want to set. Any account that has not checked in since that date
      is displayed with the last known logon date

    .PARAMETER ExportCSV
      Export the information to a csv file thats been specified by its path.

    .EXAMPLE
      .\Get-OldUser.ps1 -NumDays 30

      Gets all users who have not checked into the domain in 30 days or more and prints the info to stdout. 

    .EXAMPLE
      .\Get-OldUser.ps1 -NumDays 20 -ExportCSV C:\Users\jdoe\Documents\user_export.csv

      Gets all users who have not checked into the domain in 20 days or more and exports that information to the csv file 
      C:\Users\jdoe\Documents\user_export.csv

    .NOTES
      github.com/Bmo1992
#>

[CmdletBinding()]
Param
(
    [Parameter()]
    [int]$NumDays,
    [String]$ExportCSV
)

# Check to confirm this script is being run by an admin in an elevated powershell prompt or else exit. If run from a non-priviledged
# prompt then powershell will be unabled to read the Enabled AD property thanks to UAC
$identity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$principal = [System.Security.Principal.WindowsPrincipal] $identity
$role = [System.Security.Principal.WindowsBuiltInRole] "Administrator"

if(-not $principal.IsInRole($role))
{
    throw "This script requires elevated permissions, please confirm youre running from an elevated powershell prompt as an administrator"
}

# Required module to run the cmdlets in the script
Import-Module ActiveDirectory

######## VARIABLES ##########

$daysback = "-($NumDays)"
$current_date = Get-Date
$month_old = $current_date.AddDays($daysback)
$all_user_objects = Get-ADUser -Filter * -Properties * | ?{ $_.Enabled -eq $True }  
$csv_path = $ExportCSV

############ MAIN ############

$user_list_scrubbed = ForEach($user in $all_user_objects) 
{
    if( $user.LastLogonDate -lt $month_old )
    {
        $user
    }
} 

# Format the output into a nice readable table
$user_paramcheck = $user_list_scrubbed | Select-Object `
    @{
        Expression={
            $_.Name
        };
        Label="Name"
    },
    @{
        Expression={
            $_.LastLogonDate
        };
        Label="Last Logon"
    } 

if($ExportCSV -ne $null)
{
    $user_paramcheck | Export-CSV $csv_path
}
else
{
    $user_paramcheck | Format-Table
}
