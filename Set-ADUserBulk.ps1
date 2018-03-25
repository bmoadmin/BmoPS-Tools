<#
#  Author  : BMO
#  Purpose : To mass update user emails by uploading a CSV file and
#            comparing it to current users. This requires the ActiveDirectory
#            Powershell module. 
#  Notes   : Right now the server name is specified for a specific problem at EA.
#            in the future it may be a mandatory parameter to prevent errors.
#  Updated : 3/24/18
#>
<#
    .SYNOPSIS
      Mass update AD users with a csv file that contains the users and changes to be made
    .EXAMPLE
      Set-ADUserBulk .\example.csv
#>
# File to be used to update is passed to the script as a parameter 
Param(
    [string]$inputFile
)

Import-Module ActiveDirectory

# Create a file to Output users not found in AD, overwrite if an identicle file exists
Write-Output "No Match for the following users, please check spelling and try again" > ~/Downloads/noMatchAD.txt

Import-CSV $inputFile | ForEach{

    $user = $_.lastName + $_.firstName
    $mail = $_.mail

 
    # Test to see if the users exists. If not send the name to a text file in the user's downloads folder 
    Try {
       $testedUser = Get-ADUser -Server DC01 -Identity $user
    } 
	# Transform the stderr from user not found to stdout and send the ldap to ~/Downloads/noMatchAD.txt
	Catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException] {
        Write-Output $_ > $null
	    Write-Output $user >> ~/Downloads/noMatchAD.txt
	}
    
    # Take the results from the testedUser var and use it to set the email. Discard user not found errors.  
    if($testedUser) {
        Try {
           Set-ADUser -Server DC01 -Identity $testedUser -EmailAddress $mail 
        } 
	    Catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException] {
            Write-Output $_ > $null
	    }
    } 


}

Write-Host "Command complete, check you downloads folder for the noMatchAD.txt error report" -ForegroundColor Magenta
#Write-Host "To confirm user's are "
