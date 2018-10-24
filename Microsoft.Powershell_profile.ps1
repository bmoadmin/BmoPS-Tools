$Host.UI.RawUI.WindowTitle = "THUG CASTLE"

Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "   `"Aint nothin but a gangsta party`" - Tupac   " -ForegroundColor Magenta
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host $null
Write-Host "Today is $(Get-Date)" -ForegroundColor Green
Write-Host $null

$env:PATH += ";$HOME\Documents\WindowsPowerShell\bin"

function Send-SelfEmail {
    [CmdletBinding()]
    Param([string]$Subject,[string]$Body)
    Send-MailMessage -To bmorgan@mitcs.com -From bmorgan@mitcs.com -Subject $Subject -Body $Body -SmtpServer smtp.office365.com -UseSsl `
    -Credential $(Get-Credential) -Port 587
}

function Get-Uptime {
    [CmdletBinding()]
    Param([string]$ComputerName)
    if($ComputerName) {
        $(Get-Date) - $((Get-CimInstance -ClassName Win32_OperatingSystem -Property * -ComputerName $ComputerName).LastBootUpTime) | `
        Select Days,Hours,Minutes,Seconds
    }
    else {
        $(Get-Date) - $((Get-CimInstance -ClassName Win32_OperatingSystem -Property *).LastBootUpTime) | `
        Select Days,Hours,Minutes,Seconds
    }
}
