<#
    .SYNOPSIS
      Get-ServerState is a script to proactivley monitor servers to confirm whether or not their up.
    
    .DESCRIPTION
      Get-ServerState is intended to be a scheduled task that consistently checks if a device responds to ICMP request to alert technicians whether or not the
      device may be down.

    .PARAMETER SendFrom
      Specify the email address that the email will be from.

    .PARAMETER SendSmtpServer
      Specify the smtp server that will be used to send the email notification.
    
    .PARAMETER ComputerName
      Specify the name of the computer or computers to check if theyll respond to a ICMP request.

    .PARAMETER SentTo
      Specify the email address or addresses to send the notification to in case a server is unreachable.
    
    .EXAMPLE
      Check if computer01, computer02, are up (reponding to ICMP). If not send a message from alert@bigcompany.com using the smtp server 
      exchange.bigcompany.com to the email address jdoe@othercompany.com

      Get-ServerState -SendFrom alert@bigcompany.com -SendSmtpServer exchange.bigcompany.com -ComputerName computer01,computer02 -SendTo jdoe@othercompany.com
    
    .NOTES
      NAME    : Get-ServerState
      AUTHOR  : Bmorgan
      EMAIL   : bmorgan@mitcs.com
      GITHUB  : github.com/Bmo1992
      CREATED : July 15, 2019
#>
[CmdletBinding()]
Param
(
    [Parameter(
        Mandatory = $True
    )]
    [string]$SendFrom,
    [string]$SendSmtpServer,
    [string[]]$ComputerName,
    [string[]]$SendTo
)

######################
#  GLOBAL VARIABLES  #
######################

$offline_computers = @()


##########
#  MAIN  #
##########

# Function for sending an email notification to the appropriate address.
Function Send-EmailNotification
{
    [CmdletBinding()]
    Param
    (
        [Parameter(
            Mandatory = $True
        )]
        [string]$Subject,
        [string]$Body 
    )

    $email_params = @{
        SmtpServer = $SendSmtpServer
        From = $SendFrom
        To = $SendTo
        Subject = $Subject
        Body = $Body 
    }
    
    Send-MailMessage @email_params
}


# Check each computer we've passed to the script as an argument. If we're not able to ping one of the servers pipe the server name into the
# offline_computers array.
ForEach($computer in $ComputerName)
{
    if(Test-Connection -ComputerName $computer -count 1 -Quiet)
    {
        $_ > $null
    }
    else
    {
        $offline_computers += @($computer)
    }
}

# Only send emails if there is a down server, no point in sending redundant emails.  We do this by testing if the offline_computers array is 
# has a count greater then zero.  This is also where we set the Body variable to pass to our email message where we've introduced a loop for new lines
# to improve the readability of the email message.
if($offline_computers.count -gt 0)
{
    $Subject = "The Following Servers are Down $offline_computers"
    $Body = "Unable to reach the following servers, please assign to the appropriate resource for investigation: `n `n $(ForEach($server in $offline_computers)
    {
        Write-Output "$server `n"
    })"

    Send-EmailNotification -Subject $Subject -Body $Body
}
