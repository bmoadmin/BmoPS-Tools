<#
#  Author  : BMO
#  Purpose : To mass update user properties in Active Direcoty by utilizing the
#            the Import-CSV cmdlet to compare a CSV file to the users in AD. 
#            This requires the ActiveDirectory Powershell module. 
#  Updated : 3/26/18
#  Status  : Functional
#>
<#
    .SYNOPSIS
      Mass update AD users with a csv file that contains the users and changes to be made
    .EXAMPLE
      Set-ADUserBulk .\example.csv
#>
# File to be used to update is passed to the script as a parameter using the -InputFile 
Param 
(
    [parameter(Mandatory=$true)]
    [string]$InputFile
)

# Required Module for AD cmdlets
Import-Module ActiveDirectory

# Create a file to Output users not found in AD, overwrite if an identicle file exists
Write-Output "No Match for the following users, please check spelling and try again" > ~/Downloads/noMatchAD.txt

Import-CSV $inputFile | ForEach 
{
    $user = $_.lastName + $_.firstName
    $mail = $_.mail

    # Test to see if the users exists. If not send the name to a text file in the user's downloads folder 
    Try 
    {
       $testedUser = Get-ADUser -Identity $user
    } 
    # Transform the stderr from user not found to stdout and send the ldap to ~/Downloads/noMatchAD.txt
    Catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException] 
    {
        Write-Output $_ > $null
        Write-Output $user >> ~/Downloads/noMatchAD.txt
    }
    
    # Take the results from the testedUser var and use it to set the email. Discard user not found errors.  
    if($testedUser) 
    {
        Try 
        {
           Set-ADUser -Identity $testedUser -EmailAddress $mail 
        } 
	Catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException] 
        {
            Write-Output $_ > $null
	}
    } 

}

Write-Host "Command complete, check you downloads folder for the noMatchAD.txt error report" -ForegroundColor Magenta

