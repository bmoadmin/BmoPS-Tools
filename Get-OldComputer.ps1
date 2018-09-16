<#
#  Author  : BMO
#  Purpose : Find all computer objects that havn't checked into Active Directory for 30 or more days to 
#            identify potentially retired computers that can be removed or disabled.
#  Created : September 16, 2018
#>

<#
    .SYNOPSIS
      Get-OldComputer.ps1 is a script to help assist in AD cleanup by identifying all computer objects that have not checked in for 30 or more days.
    .EXAMPLE
#>

[CmdletBinding()]
Param
(

)

# Required module to run the cmdlets in the script
Import-Module ActiveDirectory

########## Variables ############
$daysback = "-30"
$current_date = Get-Date
$month_old = $current_date.AddDays($daysback)
$current_date_string = Get-Date -DisplayHint Date | Out-String
$all_computer_objects = Get-ADComputer -Filter * -Properties * | Select Name,LastLogonDate


<#
$time_compare = [ordered]@{
    "Day" = $CurrentDateString | %{ $_.Split(' ')[2] -Replace',',''; }
    "Month" = $CurrentDateString | %{ $_.Split(' ')[1]; }
    "Year" = $CurrentDateString | %{ $_.Split(',')[2] -Replace' ',''; }
}
#>

ForEach( $computer in $all_computer_objects) 
{
    if( $computer.LastLogonDate -lt $month_old )
    {
        Write-Output $computer.Name
    }
}


