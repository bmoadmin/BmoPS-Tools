Function Search-Gpo
{
    <#
        .SYNOPSIS
          Search-Gpo is a script to quickly audit all GPOs that apply to a speicific security group.

        .DESCRIPTION
          Check all group policy objects in a domain to see which ones could potentially apply to a specific security group because of the GPOs security filtering rules.  Both the domain name and the security group must be specified in order for the function to work correctly.

        .PARAMETER DomainName
          Specify the domain name of the active directory forest to search for group policy objects in.

        .PARAMETER SecurityGroup
          Specify the name of the security group you plan to search each group policy object for.

        .EXAMPLE
          Search-Gpo -DomainName bigcorp.local -SecurityGroup "Sales Users"

          Search the domain bigcorp.local for all group policy objects with the Sales Users security group in its security filtering as well as any GPOs being applied to any other security groups the Sales Users group may be a member of.

        .NOTES
          NAME    : Seach-Gpo
          AUTHOR  : BMO
          EMAIL   : brandonseahorse@gmail.com
          GITHUB  : github.com/Bmo1992
          CREATED : June 24, 2018
    #>

    # Pass the domain name and security group name to the function as arguments
    [CmdletBinding()]
    Param
    (
        [Parameter(
            Mandatory=$True,
            ValueFromRemainingArguments=$True, 
            Position = 0
        )]
        [string] $DomainName,
        [string] $SecurityGroup
    )

    # The cmdlets used require you run from an elevated PS session, this tests if that's true and if not the script will exit.
    $identity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [System.Security.Principal.WindowsPrincipal] $identity
    $role = [System.Security.Principal.WindowsBuiltInRole] "Administrator"

    if(-not $principal.IsInRole($role))
    {
        Throw "This script requires elevated priviledges, please rerunt from elevated powershell prompt"
    }

    # Both modules are needed, when I decide to be a better programmer I'll add terminating conditions if the modules can't be installed
    Import-Module ActiveDirectory
    Import-Module GroupPolicy

    # Search through all the GPOs in the domain 
    $gpos = Get-GPO -All -Domain $DomainName

    # Check if the security group specified is a member of any other groups that may have GPOs applying to them as well
    $ParentSecurityGroups = Get-ADGroup -Identity $SecurityGroup -Properties MemberOf | Select -ExpandProperty MemberOf | `
    Get-ADGroup | Select -ExpandProperty Name

    Write-Host "GPOs with direct security filtering"
    Write-Host 
    ForEach($gpo in $gpos)
    {
        $secinfo = $gpo.GetSecurityInfo() | Where ` 
        { 
            $_.Permission -eq "GpoApply" 
        }

        ForEach($sec in $secinfo)
        {
            if($sec.Trustee.Name -eq $SecurityGroup)
            {
                Out-Default -InputObject $gpo
            }
        }
    } 

    Write-Host 
    Write-Host "GPOs being applied from membership to parent security groups"
    Write-Host
    ForEach($gpo in $gpos)
    {
        ForEach($group in $ParentSecuityGroup)
        {
            $secinfo = $gpo.GetSecurityInfo() | Where `
	    {
	        $_.Permission -eq "GpoApply"
	    }
		
	    ForEach($sec in $secinfo)
	    {
		    if($sec.Trustee.Name -eq $group)
		    {
			    Out-Default -InputObject $gpo
		    }
	    }
        }
    }
} 
