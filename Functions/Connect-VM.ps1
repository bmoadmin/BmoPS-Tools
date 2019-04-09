Function Connect-VM
{
    <#
        .SYNOPSIS
          Connect to one or more Hyper-V virtual machines.

        .DESCRIPTION
          Connect to one or more Hyper-V virtual machines. Can connect to a remote Hyper-V host with the Hostname argument assuming the current computer has the Hyper-V roles and features installed (for the Hyper-V powershell module).  By default it will connect to the local host. 

        .PARAMETER VMName
          Specifies one or more virtual machines to connect to. Use the vm hostname.

        .PARAMETER Hostname
          Specifies a remore Hyper-V host to connect to.

        .EXAMPLE
          Connect-VM -VMName "vmguest1","vmguest2","vmguest3"

          Connects to the virtual machines vmguest1, vmguest2, and vmguest3.

        .EXAMPLE
          Connect-VM -VMName "vmguest1","vmguest2" -Hostname "vmhost01"

          Connects to the virtual machines vmguest1 and vmguest2 that are located on the vmhost01 Hyper-V host.

        .NOTES
          NAME    : Connect-VM
          AUTHOR  : BMO
          EMAIL   : brandonseahorse@gmail.com
          GITHUB  : github.com/Bmo1992
          CREATED : December 13, 2018
    #>

    # Parameters to be passed to the script
    [CmdletBinding()]
    Param
    (
        [Parameter(
            Mandatory=$True
        )]
        [string[]]$VMName,
        [Parameter(
        )]
        [string]$Hostname
    )

    # Confirm the Hyper-V module is installed or exit the script
    if(-Not (Get-Module Hyper-V))
    {
        Write-Error "Hyper-V module not found.  Please make sure youre running this script from computer or server with the Hyper-V roles and features installed" -ErrorAction Stop
    }

    ######## MAIN ########

    # For each VM passed to the VMName arguement, connect with vmconnect. If a remote host has been specified connect to that host. By
    # default connect to the local host.
    ForEach($VM in $VMName)
    {
        if($Hostname)
        {
            Try
            {
                vmconnect.exe $Hostname $VM
            }
            Catch
            {
                Write-Error "Couldn't connect to $VM"
            }
        }
        else
        {
            Try
            {
                vmconnect.exe $(hostname) $VM
            }
            Catch
            {
                Write-Error "Couldn't connect to $VM"
            }
        }
    }
}
