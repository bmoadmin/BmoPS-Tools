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




########## Variables ############

$Date = Get-Date -DisplayHint Date | Out-String




$time_compare = [ordered]@{
    "Day" = $Date | %{ $_.Split(' ')[2] -Replace',',''; }
    "Month" = $Date | %{ $_.Split(' ')[1]; }
    "Year" = $Date | %{ $_.Split(',')[2] -Replace' ',''; }
}

Write-Host $null
$time_compare.Keys | ForEach {
    Write-Output $time_compare.Item($_)
}
