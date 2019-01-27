Function Get-OldComputer
{
    <#
        .SYNOPSIS
          Gets all computers that havn't logged into the domain in X amount of days.

        .DESCRIPTION
          Get-OldComputer is a script to help assist in AD cleanup by identifying all computer objects that either have or have not checked into the domain in X days.  The have or have not is specified by the -NewerThen or -OlderThen String. Information can be exported to csv by passing the desired path to the csv file in the ExportCSV argument.  

        .PARAMETER NumDays
          Specifies the number of days from today to perform the check from.

        .PARAMETER OlderThen
          Specifies to check for all computers whos last logon date was before the date set by NumDays.

        .PARAMETER NewerThen
          Specifies to check for all computeres whos last logon date was after the date set by NumDays.

        .PARAMETER ExportCSV
          Specifies the path to the CSV file the user would like to export the information gathered to.

        .EXAMPLE
          Get-OldComputer -NumDays 30 -OlderThen -ExportCSV C:\Users\jdoe\Documents\computer_export.csv
  
          Get all computers that havn't checked into the domain for the last 30 days and export the information to C:\Users\jdoe\Documents\computer_export.csv

        .EXAMPLE
          Get-OldComputer -NumDays 20 -NewerThen

          Get all computers that have logged in withint that last 20 days.

        .NOTES
          NAME    : Get-OldComputer
          AUTHOR  : BMO
          EMAIL   : brandonseahorse@gmail.com
          GITHUB  : github.com/Bmo1992
          CREATED : September 16, 2018
    #>

    # Parameteres to be passed to the script.
    [CmdletBinding()]
    Param
    (
        [Parameter(
            Mandatory=$True
        )]
        [int]$NumDays,
        [Parameter(
        )]
        [switch]$OlderThen,
        [switch]$NewerThen,
        [string]$ExportCSV
    )

    # The ActiveDirectory module is required to run this script. First check if its installed, if not and its available import it.  If the 
    # module is not available, check to see if the user is currently in a remote ps session that has it loaded. If neither exit the script
    # with a warning message.
    if(-Not (Get-Module ActiveDirectory))
    {
        $modules = Get-Module 

        if((Get-Module -ListAvailable).Name -match "ActiveDirectory")
        {
            Import-Module ActiveDirectory
        }
        elseif($modules.ExportedCommands.Values -match "Set-ADUser")
        {
            Write-Host "Connected to $((Get-PSSession).ComputerName), running script against the remote PC" -ForegroundColor Magenta
        }
        else
        {
            Write-Error "No local or remote computer with the ActiveDirectory powershell module found. Please run the script on a computer with the correct roles install or establish a remote PS session with that computer" -ErrorAction Stop
        }
    }

    ########## Variables ############

    $daysback = "-($NumDays)"
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
            if($computer.LastLogonDate -lt $month_old)
            {
                $computer
            }
        }
    }
    elseif($NewerThen)
    {
        $computer_list_scrubed = ForEach($computer in $all_computer_objects) 
        {
            if($computer.LastLogonDate -gt $month_old)
            {
                $computer
            }
        }
    }
    else
    {
        Throw "Please provide the NewerThen or OlderThen parameters to define what side of the timeline youre searching for last login"
    }

    # Take the computers that were selected in the above check and then use a hashtable to grab and format important information about them.
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

    # If the ExportCSV parameter was used export the information to the CSV specified in the PATH passed to that parameter.
    if($ExportCSV)
    {
        $computer_paramcheck | Export-CSV $ExportCSV
    }
    else
    {
        $computer_paramcheck | Format-Table
    }
}
