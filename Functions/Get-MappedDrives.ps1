Function Get-MappedDrives
{
    <#
        .SYNOPSIS
          Get's the mapped drives of a local or a remote computer.

        .DESCRIPTION
          Get information about shared folders that have been mapped to a drive letter on the local or remote computer. By default the command will pull all information however, to pull only the drive letter and UNC path of the share use the Simple parameter.

        .PARAMETER ComputerName
          Specify the name of the remote computer to pull information from.

        .PARAMETER Simple
          Specify to only pull the drive letter and share unc path instead of all share info.

        .EXAMPLE
          Get-MappedDrives

          Get all mapped drives on the local computer.

        .EXAMPLE
          Get-MappedDrives -Simple

          Get the drive letter and unc path of all mapped drives on the local computer.

        .EXAMPLE
          Get-MappedDrives -ComputerName desktop01

          Get all mapped drives on the computer desktop01.

        .EXAMPLE
          Get-MappedDrives -Simple -ComputerName desktop01,desktop02,desktop03

          Get the drive letter and unc path of all mapped drives on the computers desktop01, desktop02, and desktop03.

        .NOTES
          NAME    : Get-MappedDrives
          AUTHOR  : BMO
          EMAIL   : brandonseahorse@gmail.com
          GITHUB  : github.com/Bmo1992
          CREATED : April 8, 2019
    #>
    [CmdletBinding()]
    Param
    (
        [Parameter(
            Mandatory=$False
        )]
        [string[]]$ComputerName,
        [switch]$Simple
    )
    
    if($Simple)
    {
        if($ComputerName)
        {
            ForEach($computer in $ComputerName)
            {
                Try
                {
                    Get-WmiObject Win32_MappedLogicalDisk -ComputerName $computer | Select name,providername
                }
                Catch
                {
                    Write-Error "Couldn't connect to $computer. Please make sure the remote PC is on and try again."
                }
            }
        }
        else
        {
            Get-WmiObject Win32_MappedLogicalDisk | Select name,providername
        }
    }
    else
    {
        if($ComputerName)
        {
            ForEach($computer in $ComputerName)
            {
                Try
                {
                    Get-WmiObject Win32_MappedLogicalDisk -ComputerName $computer
                }
                Catch
                {
                    Throw "Couldn't connect to $computer. Please make sure the remote PC is on and try again."
                }
            }
        }
        else
        {
            Get-WmiObject Win32_MappedLogicalDisk
        }
    }
}
