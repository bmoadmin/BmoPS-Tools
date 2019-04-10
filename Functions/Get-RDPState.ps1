Function Get-RDPState
{
    <#
        .SYNOPSIS
          Get the status of the RDP on the local computer or remote computer / computers.

        .DESCRIPTION
          Get the status of the RDP on the local computer or remote computer / computers. This function only returns whether or not it's enabled or disabled. If enabled it does not state at what level.

        .PARAMETER ComputerName
          Specify one or more remote computers to pull the status of the RDP from.

        .EXAMPLE
          Get-RDPState 

          Determine whether or not the RDP is enabled on the local computer.

        .EXAMPLE
          Get-RDPState -ComputerName desktop01

          Returns whether or not the RDP is enabled on the computer dekstop01.

        .EXAMPLE
          Get-RDPState -ComputerName desktop01,desktop02,desktop03

          Returns whether or not the RDP is enabled on the computers desktop01, desktop02, and desktop03. 

        .NOTES
          NAME    : Get-RDPState
          AUTHOR  : BMO
          EMAIL   : brandonseahorse@gmail.com
          GITHUB  : github.com/Bmo1992
          CREATED : April 9, 2019
    #>
    [CmdletBinding()]
    Param
    (
        [Parameter(
            Mandatory=$False
        )]
        [string[]]$ComputerName    
    )
    
    if($ComputerName)
    {
        ForEach($computer in $ComputerName)
        {
            Try
            {
                $regKey = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, $computer)
                $regKey = $regKey.OpenSubKey("SYSTEM\\CurrentControlSet\\Control\\Terminal Server", $True)

                $regValue = $regKey.GetValue("fDenyTSConnections")
                if($regValue -eq 1)
                {
                    Write-Host "RDP is disabled on $computer"
                }
                else
                {
                    Write-Host "RDP is enabled on $computer"
                }

                $regKey.flush()
                $regKey.Close()

                Clear-Variable -Name "regValue"
            }
            Catch
            {
                $Error[0].Exception.Message
            }
        }
    }
    else
    {
        Try
        {
            $regValue = Get-ItemProperty 'Registry::HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server' | `
                        Select -ExpandProperty fDenyTSConnections

            if($regValue -eq 1)
            {
                Write-Host "RDP is disabled on the local computer"
            }
            else
            {
                Write-Host "RDP is enabled on the local computer"
            }   
        }
        Catch
        {
            Throw "Couldn't connect to the local machine registry. Please confirm you're running an elevated PS session and try again."
        }
    }
}
