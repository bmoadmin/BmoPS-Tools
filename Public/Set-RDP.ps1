Function Set-RDP
{
    <#
        .SYNOPSIS
          Disables or enables RDP on a remote or local computer.

        .DESCRIPTION
          Disables or enables RDP on a remote or local computer. By default the script will change values on the local computer unless the ComputerName parameter is specified. In order to run you must have administrative access to make registry changes on the computer in question. If the computer is a remote computer the remote registry service must be enabled on that computer.

        .PARAMETER ComputerName
          Specify the a remote computer or computers.

        .PARAMETER Enable
          Specify whether to enable or disable the RDP by setting this value to true or false. This parameter is required.

        .EXAMPLE
          Set-RDP -Enable $True

          Enables RDP on the local computer.

        .EXAMPLE
          Set-RDP -Enable $False

          Disables RDP on the local computer.

        .EXAMPLE
          Set-RDP -Enable $True -ComputerName desktop01

          Enables RDP on the remote computer desktop01.

        .EXAMPLE
          Set-RDP -Enable $False -ComputerName desktop01,desktop02,desktop03

          Disables RDP on the remote computers desktop01, desktop02, and desktop03.

        .NOTES
          NAME    : Set-RDP 
          AUTHOR  : BMO
          EMAIL   : brandonseahorse@gmail.com
          GITHUB  : github.com/Bmo1992
          CREATED : April 5, 2019
    #>
    [CmdletBinding()]
    Param
    (
        [Parameter(
            Mandatory=$False
        )]
        [String[]]$ComputerName,
        [Parameter(
            Mandatory=$True
        )]
        [Boolean]$Enable
    )

    # If computer name is specified for a remote computer loop through and set the value on each remote computer. Else set the 
    # local machine's RDP
    if($ComputerName)
    {
        ForEach($computer in $ComputerName)
        {
            Try
            {
                # Open the registry key of the remote computer
                $regKey = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, $computer)
                $regKey = $regKey.OpenSubKey("SYSTEM\\CurrentControlSet\\Control\\Terminal Server", $True)

                # If enable is true set the UAC key to 1 if false then set to 0
                if($Enable)
                {
                    $regKey.SetValue("fDenyTSConnections", 0)
                }
                else
                {
                    $regKey.SetValue("fDenyTSConnections", 1)
                }
               
                # flush and close the remote registry
                $regKey.flush()
                $regKey.Close()
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
            if($Enable)
            {
                Set-ItemProperty -Path 'Registry::HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server' -name fDenyTSConnections `
                -Value 0 -Force
            }
            else
            {
                Set-ItemProperty -Path 'Registry::HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server' -name fDenyTSConnections `
                -Value 1 -Force
            }
        }
        Catch
        {
            Throw "Couldn't set registry value, please make sure you're in an elevated command prompt and run again."
        }
    }
}
