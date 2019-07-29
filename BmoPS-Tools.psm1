<#
    .SYNOPSIS
      BmoPS-Tools is a random assortment of scripts that Ive created to make daily tasks easier.

    .DESCRIPTION
      This is the PS module file for my ps repository with a collection of assorted scripts for daily admin tasks.

    .NOTES
      NAME    : BmoPS-Tools
      AUTHOR  : BMO
      EMAIL   : brandonseahorse@gmail.com
      GITHUB  : github.com/Bmo1992
      CREATED : January 26, 2019
#>

$Public = @(Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue)

ForEach ($function in $Public)
{
    Try
    {
        . $function.fullname
    }
    Catch
    {
        Write-Error -Message "Failed to import function $($function.fullname): $_"
    }
}
