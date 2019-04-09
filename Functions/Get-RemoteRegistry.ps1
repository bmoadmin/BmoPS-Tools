Function Get-RemoteRegistry
{
    <#
        .SYNOPSIS

        .DESCRIPTION

        .EXAMPLE

        .NOTES
          NAME    : Get-RenoteRegistry
          AUTHOR  : BMO
          EMAIL   : brandonseahorse@gmail.com
          GITHUB  : github.com/Bmo1992
          CREATED : 
    #>
    [CmdletBinding()]
    Param
    (
        [Parameter(
            Mandatory=$True
        )]
    )

    $remoteReg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('', $Computer)


}
