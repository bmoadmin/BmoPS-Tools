#<
#
#
#
#>



$EmailFrom = "emailaddress"
$EmailTo = "emailaddress"
$Subject = "Test Email"
$Body = "This is a test email sent from powershell"
$SMTPServer = "smtp.office365.com"

$user_credential = Get-Credential
Send-MailMessage -To $EmailTo -From $EmailFrom -Subject $Subject -Body $Body -SmtpServer $SMTPServer -UseSsl -Credential `
$user_credential -Port 587

