Function Set-UAC
{
    <#
        .SYNOPSIS
          Disables or enables the UAC of the local or remote computer.

        .DESCRIPTION
          Disable or Enable the UAC on either the local or remote computer.  Set-UAC needs to be run from an elevated command prompt.  In order to connect to a remote computers registry the remote registry service must be enabled on that computer.

        .PARAMETER ComputerName
          Specify the a remote computer or computers.

        .PARAMETER Enable
          Specify whether to enable or disable the UAC by setting this value to true or false. This parameter is required.

        .EXAMPLE
          Set-UAC -Enable $False

          Disable the UAC on the local computer.

        .EXAMPLE
          Set-UAC -Enable $True

          Enable the UAC on the local computer.

        .EXAMPLE
          Set-UAC -ComputerName desktop01 -Enable $False

          Disable the UAC on the remote computer desktop01.

        .EXAMPLE
          Set-UAC -ComputerName desktop01,desktop02,desktop03 -Enable $True

          Enable the UAC on the remote computers desktop01, desktop02, and desktop03. 

        .NOTES
          NAME    : Set-UAC 
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
    # local machine's UAC
    if($ComputerName)
    {
        ForEach($computer in $ComputerName)
        {
            Try
            {
                # Open the registry key of the remote computer
                $regKey = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, $computer)
                $regKey = $regKey.OpenSubKey("Software\\Microsoft\\Windows\\CurrentVersion\\policies\\system", $True)

                # If enable is true set the UAC key to 1 if false then set to 0
                if($Enable)
                {
                    $regKey.SetValue("EnableLUA", 1)
                }
                else
                {
                    $regKey.SetValue("EnableLUA", 0)
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
                Set-ItemProperty -Path 'Registry::HKLM\Software\Microsoft\Windows\CurrentVersion\policies\system' -name EnableLUA `
                -Value 1 -Force
            }
            else
            {
                Set-ItemProperty -Path 'Registry::HKLM\Software\Microsoft\Windows\CurrentVersion\policies\system' -name EnableLUA `
                -Value 0 -Force
            }
        }
        Catch
        {
            Throw "Couldn't set registry value, please make sure you're in an elevated command prompt and run again."
        }
    }
}
