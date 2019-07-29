Function Get-PowerPlan
{
    <#
        .SYNOPSIS
          Retrieve the power plans on the current computer.

        .DESCRIPTION
          Retrieve the power plans on the current computer. Use the Active argument to specify whether or not to only pull the active power plan. Commands require administrative priviledges. 

        .PARAMETER Active
          Specify to only pull the active power plan on the current machine.

        .EXAMPLE
          Get-PowerPlan

          Retrieves all power plans on the current computer.

        .EXAMPLE
          Get-PowerPlan -Active $True

          Retrieves only the active power plans on the current computer.

        .NOTES
          NAME    : Get-PowerPlan
          AUTHOR  : BMO
          EMAIL   : brandonseahorse@gmail.com
          GITHUB  : github.com/Bmo1992
          CREATED : April 15, 2019 
    #>
    [CmdletBinding()]
    Param
    (
        [Parameter(
            Mandatory=$False
        )]
        [bool]$Active
    )

    if($Active)
    {
        Get-CimInstance -Namespace "root\cimv2\power" -ClassName Win32_PowerPlan | Where{ `
            $_.IsActive -eq $True
            }
    }
    else
    {
        Get-CimInstance -Namespace "root\cimv2\power" -ClassName Win32_PowerPlan
    }
}
