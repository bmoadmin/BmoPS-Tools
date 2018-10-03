<#
#  Author  : BMO
#  Purpose : Find all computer objects that havn't checked into Active Directory for 30 or more days to 
#            identify potentially retired computers that can be removed or disabled.
#  Created : September 16, 2018
#  Updated : September 21, 2018
#  Status  : Functional
#>

<#
    .SYNOPSIS
      Get-OldComputer.ps1 is a script to help assist in AD cleanup by identifying all computer objects that have not checked in for 30 or more days.
    .EXAMPLE
      ./Get-OldComputer.ps1
    .EXAMPLE
      ./Get-OldComputer.ps1 -ExportCSV <path>
    .EXAMPLE
      ./Get-OldComputer.ps1 -ExportCSV C:\Users\jdoe\Documents\computer_export.csv
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

function CollectInfo($comparison)
{
    $computer_list_scrubed = ForEach($computer in $all_computer_objects) 
    {
        if( $computer.LastLogonDate $comparison $month_old )
        {
            $computer
        }
    }
}

if($OlderThen)
{
    CollectInfo("-lt")
}
elseif($NewerThen)
{
    CollectInfo("-gt")
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
    }

if($ExportCSV)
{
    $computer_paramcheck | Export-CSV $ExportCSV
}
else
{
    $computer_paramcheck | Format-Table
}
