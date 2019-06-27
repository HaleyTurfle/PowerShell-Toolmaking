function LabB {

<#
.SYNOPSIS
Retrieves Drive, Free Space and Size from one to ten computers.
.DESCRIPTION
LabB uses Windows Management Instrumentation
(WMI) to retrieve information from one or more computers.
Specify computers by name or by IP address.
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
Get-Content names.txt | LabB
.EXAMPLE
LabB -ComputerName SERVER1,SERVER2
#>

    [CmdletBinding()]
    param(
        [Parameter(mandatory=$true,ValueFromPipeline=$true)]

        [ValidateCount(1,10)]
        [Alias('hostname')]
        [string[]]$ComputerName,

        [string]$ErrorLog = 'C:\Error.txt'
    )
    BEGIN {
    }
    PROCESS {
        Write-Verbose "Beginning PROCESS block..."
        foreach ($computer in $computername){
            Write-Verbose "Querying $computer ..."

            try{
                $everythingok = $true
                $vol = Get-WmiObject -class Win32_Volume -computerName $computer
            }

            catch{
                $everythingok = $false
                Write-Warning "COMPUTER FAILED"
                $computer | Out-File $ErrorLog 
                Write-Warning "Errors logged to output file"
            }

            if($everythingok){
                $props = @{'ComputerName'=$computer;
                'Drive'=$vol.driveletter;
                'FreeSpace'= $vol.freespace;
                'Size'=$vol.blocksize}
                Write-Verbose "WMI queries complete"
                $obj = New-Object -TypeName psobject -Property $props
                $obj.PSObject.TypeNames.Insert(0,'MOL.DiskInfo')
                Write-Output $obj | Format-Table
            }
        }
    }
    END {}
}
Update-FormatData -PrependPath C:\CustomViewB.format.ps1xml
LabB -ComputerName localhost