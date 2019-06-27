function LabA {

<#
.SYNOPSIS
Retrieves Operating System Version, Service Pack Major Version, 
Workgroup, Administrator Password Status, and Computer Manufacturer 
and Model from one to ten computers.
.DESCRIPTION
LabA uses Windows Management Instrumentation
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
Get-Content names.txt | LabA
.EXAMPLE
LabA -ComputerName SERVER1,SERVER2
#>

    [CmdletBinding()]
    param(
        [Parameter(mandatory=$true,ValueFromPipeline=$true)]

        [ValidateCount(1,10)]
        [Alias('hostname')]
        [string[]]$ComputerName,

        [string]$ErrorLog = 'C:\Errors.txt'
    )
    BEGIN {
    }
    PROCESS {
        Write-Verbose "Beginning PROCESS block..."

        foreach ($computer in $computername){
            Write-Verbose "Querying $computer ..."

            try{
                $everythingok = $true
                $os = Get-WmiObject -class Win32_OperatingSystem -computerName $computer
            }

            catch{
                $everythingok = $false
                Write-Warning "COMPUTER FAILED"
                $computer | Out-File $ErrorLog
                Write-Warning "Errors logged to output file"
            }

            if($everythingok){
                $comp = Get-WmiObject -class Win32_ComputerSystem -computerName $computer
                $bios = Get-WmiObject -class Win32_BIOS -computerName $computer
                $props = @{'ComputerName'=$computer;
                'OSVersion'=$os.version;
                'SPVersion'=$os.servicepackmajorversion;
                'BIOSSerial'=$bios.serialnumber;
                'Workgroup'=$comp.domain;
                'AdminPasswordStatus'=$comp.pimaryownername;
                'Manufacturer'=$comp.manufacturer;
                'Model'=$comp.model}
                Write-Verbose "WMI queries complete"
                $obj = New-Object -TypeName psobject -Property $props
                $obj.PSObject.TypeNames.Insert(0,'MOL.ComputerSystemInfo')
                Write-Output $obj 
            }
        }
    }
    END {}
}
Update-FormatData -PrependPath C:\CustomViewA.format.ps1xml
LabA -ComputerName localhost