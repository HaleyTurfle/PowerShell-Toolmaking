function LabC {

<#
.SYNOPSIS
Retrieves Running System Services from one to ten computers.
.DESCRIPTION
LabB uses Get-Service to retrieve running services from one or 
more computers. Specify computers by name or by IP address.
.PARAMETER ComputerName
One or more computer names or IP addresses, up to a maximum
of 10.
.PARAMETER LogErrors
Specify this switch to create a text log file of computers
that could not be queried.
.PARAMETER ErrorLog
When used with -LogErrors, specifies the file path and name
to which failed computer names will be written. Defaults to
C:\Retry.txt.
.EXAMPLE
LabC -ComputerName SERVER1,SERVER2
#>

    [CmdletBinding()]
    param(
        [Parameter(mandatory=$true,ValueFromPipeline=$true)]

        [ValidateCount(1,10)]
        [Alias('hostname')]
        [string[]]$ComputerName,

        [string]$ErrorFile = 'C:\Errors.txt',

        [switch]$LogErrors
    )
    BEGIN {
    }
    PROCESS {
        Write-Verbose "Beginning PROCESS block..."
        foreach ($computer in $computername){
            Write-Verbose "Querying $computer ..."

            if($LogErrors){
                $ErrorFile.Remove()
            }

            try{
                $everythingok = $true
                $serv = Get-Service | Where-Object -filter {$_.status -eq 'Running'}
            }

            catch{
                $everythingok = $false
                Write-Warning "COMPUTER FAILED"
                if($LogErrors){
                    $computer | Out-File $ErrorLog -Append
                    Write-Warning "Errors logged to output file"
                }
            }

            if($everythingok){
                $props = @{'ComputerName'=$computer;
                'Service'=$serv.ServiceName;
                'DisplayName'= $serv.DisplayName;
                'ProcessName'=$serv.ServiceName;
                'VMSize'=$serv.MachineName;
                'ThreadCount'=$serv.CanPauseAndContinue;
                'PeakPageFile'=$serv.Container}
                $obj = New-Object -TypeName psobject -Property $props
                $obj.PSObject.TypeNames.Insert(0,'MOL.ServiceProcessInfo')
                Write-Output $obj
                Write-Verbose "Service queries complete"
            }
        }
    }
    END {}
}
Update-FormatData -PrependPath c:\CustomViewC.format.ps1xml
LabC -ComputerName localhost
LabC -ComputerName localhost | Format-List