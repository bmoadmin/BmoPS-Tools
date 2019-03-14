Function Remove-Printers
{
    <#
        .SYNOPSIS
          Remove all local or network printers.
		
        .DESCRIPTION
	        Remove-Printers removes either all local or network printers specified by passing true or false to the -Network parameter. 
          
        .PARAMETER Network
	        Specify whether to delete Network printers by stating true or local printers by stating false.
     
        .EXAMPLE
          Remove-Printers -Network $True 
	  
	        Deletes all network printers for your currently logged in user. 
		  
      .EXAMPLE
	      Remove-Printers -Network $False
	  
	      Deletes all local printers for your currently logged in user.
          
      .NOTES
        NAME    : Remove-Printers
        AUTHOR  : BMO
        EMAIL   : brandonseahorse@gmail.com
        GITHUB  : github.com/Bmo1992
        CREATED : March 14, 2019
      #>

    [CmdletBinding()]
    Param
    (
        [Parameter(
	          Mandatory=$True 
	      )]
	     [bool]$Network
    )

    if($Network)
    {
        $network_printers = Get-WmiObject Win32_Printer | Where{ $_.Network -eq $True }

	      ForEach($printer in $network_printers)
	      {
	          $printer.Delete()
        }
    }
    elseif(-not $Network)
    { 
        $local_printers = Get-WmiObject Win32_Printer | Where{ $_.Network -eq $False }
	
	      ForEach($printer in $local_printers)
	      {
	          $printer.Delete()
        }
    }
    else
    {
        Throw "Please specify whether or not to Delete local or network printers."
    }
}
