<#
#  Author  : BMO
#  Purpose : Find all computer objects that havn't checked into Active Directory for 30 or more days to 
#            identify potentially retired computers that can be removed or disabled.
#  Created : September 16, 2018
#  Updated : October 6, 2018
#  Status  : Functional
#>

<#
    .SYNOPSIS
      Get-OldComputer.ps1 is a script to help assist in AD cleanup by identifying all computer objects that either have or have not checked into the domain in 30 days.  The have or have not is specified by the -NewerThen or -OlderThen String
    .SYNTAX
      ./Get-OldComputer.ps1 [-NewerThen] [-ExportCSV <string>]

      ./Get-OldComputer.ps1 [-OlderThen] [-ExportCSV <string>]

    .EXAMPLE
      ./Get-OldComputer.ps1 -OlderThen -ExportCSV C:\Users\jdoe\Documents\computer_export.csv
#>

[CmdletBinding()]
Param
(
    [Parameter()]
    [switch]$OlderThen,
    [switch]$NewerThen,
    [string]$ExportCSV
)

# Required module to run the cmdlets in the script
Import-Module ActiveDirectory

########## Variables ############

$daysback = "-30"
$current_date = Get-Date
$month_old = $current_date.AddDays($daysback)
$current_date_string = Get-Date -DisplayHint Date | Out-String
$all_computer_objects = Get-ADComputer -Filter * -Properties * | ?{ $_.Enabled -eq $True }


############## MAIN ###############

# Check if the OlderThen or NewerThen parameters are present, use that to operate on one side of the date line, or else die if null.
if($OlderThen)
{
    $computer_list_scrubed = ForEach($computer in $all_computer_objects) 
    {
        if( $computer.LastLogonDate -lt $month_old )
        {
            $computer
        }
    }
}
elseif($NewerThen)
{
    $computer_list_scrubed = ForEach($computer in $all_computer_objects) 
    {
        if( $computer.LastLogonDate -gt $month_old )
        {
            $computer
        }
    }
}
else
{
    Throw "Please provide the NewerThen or OlderThen parameters to define what side of the timeline youre searching for last login"
}



$computer_paramcheck = $computer_list_scrubed | Select-Object `
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
    },
    @{
        Expression={
            $_.OperatingSystem
        };
        Label="Operating System"
    },
    @{
        Expression={
            $_.IPv4Address
        };
        Label="IP Address"
     }

if($ExportCSV)
{
    $computer_paramcheck | Export-CSV $ExportCSV
}
else
{
    $computer_paramcheck | Format-Table
}
