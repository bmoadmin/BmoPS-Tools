<#
    .SYNOPSIS

    .DESCRIPTION

    .NOTES
      NAME    : BmoPS-Tools
      AUTHOR  : BMO
      EMAIL   : brandonseahorse@gmail.com
      GITHUB  : github.com/Bmo1992
      CREATED : January 26, 2019
#>

$Functions = @(Get-ChildItem -Path $PSScriptRoot\Functions\*.ps1 -ErrorAction SilentlyContinue)

ForEach ($script_function in $Functions)
{
    Try
    {
        . $script_function.fullname
    }
    Catch
    {
        Write-Error -Message "Failed to import function $($script_function.fullname): $_"
    }
}
