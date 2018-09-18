<#
#  Author  : BMO
#  Purpose : This script was developed to meet the needs of an increasingly complex
#            environment with dozens of GPOs and hundreds of group, user, and computer objects.
#            While the group policy results wizard is great I found that I needed a way to 
#            search which GPO's were being filtered through a specific security group across
#	     the entire domain forest.
#  Created : 6/23/2018		 
#  Updated : 6/24/2018
#  Status  : Functional
#>

<#
    .SYNOPSIS
      Search-GPO is 
    .EXAMPLE
      Search-Gpo.ps1 -DomainName companydomain.local -SecurityGroup "Sales Users"
#>

# Pass the name of the security group to the script as an argument
[CmdletBinding()]
Param
(
    [Parameter(ValueFromRemainingArguments=$true, Position = 0)]
    [string] $DomainName,
    [string] $SecurityGroup
)

# The cmdlets used require you run from an elevated PS session, this tests if that's true and if not the script will exit.
$identity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$principal = [System.Security.Principal.WindowsPrincipal] $identity
$role = [System.Security.Principal.WindowsBuiltInRole] "Administrator"

if(-not $principal.IsInRole($role))
{
    throw "This script requires elevated priviledges, please rerunt from elevated powershell prompt"
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
        if ($sec.Trustee.Name -eq $SecurityGroup)
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
