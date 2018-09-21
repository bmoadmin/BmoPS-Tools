<#
#  Author  : BMO
#  Purpose : List the quotas for all exchange mailboxes
#  Created : September 21, 2018
#  Status  : Unfinished
#>

<#
    .SYNOPSIS
      Get-MailboxQuotas.ps1 is a script to grab the configured quota information for all users { useful for environments where mail quotas are configured manually for specific groups of users }
    .EXAMPLE
      .\Get-MailboxQuotas.ps1 
#>

[CmdletBinding()]
Param
(
  
)

$mailboxes = Get-Mailbox -Filter * -ErrorAction SilentlyContinue

$mailboxes | Select-Object `
    @{
        Expression={
            $_.Alias
        };
        Label="Email"
    },
    @{
        Expression={
            $_.IssueWarningQuota
        };
        Label="Warning"
    },
    @{
        Expression={
            $_.ProhibitSendQuota
        };
        Label="Send Limit"
    },
    @{
        Expression={
            $_.ProhibitSendReceiveQuota
        };
        Label="Receive Limit"
    } | Format-Table

