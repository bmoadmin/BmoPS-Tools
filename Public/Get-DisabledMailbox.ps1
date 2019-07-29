Function Get-DisabledMailbox
{
    <#
        .SYNOPSIS

        .DESCRIPTION

        .EXAMPLE

        .NOTES
          NAME    : Get-DisabledMailbox
          AUTHOR  : BMO
          EMAIL   : brandonseahorse@gmail.com
          GITHUB  : github.com/Bmo1992
          CREATED : April 19, 2019 
    #>
    [CmdletBinding()]
    Param
    (
        [Parameter(
            Mandatory=$False
        )]
        [string]$Database
    )

    if($Database)
    {
        $Databases = $Database
    }
    else
    {
        $Databases = (Get-MailboxDatabase).Identity
    }

    ForEach($db in $Databases)
    {
        Get-MailboxStatistics -Database $base | Where{ `
            $_.DisconnectReason -eq "Disabled"
        }
    }
}
