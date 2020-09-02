Start-Transcript -Path $(Join-Path $env:temp "DriveMapping.log")

$driveMappingConfig=@()

######################################################################
#                section script configuration                        #
######################################################################

<#
   Add your internal Active Directory Domain name and custom network drives below
#>

$dnsDomainName= "perks.local"

$driveMappingConfig+= [PSCUSTOMOBJECT]@{
    DriveLetter = "V"
    UNCPath= "\\DataStr01\CLIENT DATA"
    Description="Pool"
}

$driveMappingConfig+=  [PSCUSTOMOBJECT]@{
    DriveLetter = "N"
    UNCPath= "\\PERKSACC\PADATA"
    Description="Software"
}

$driveMappingConfig+=  [PSCUSTOMOBJECT]@{
    DriveLetter = "T"
    UNCPath= "\\datastr01\Perks Data"
    Description="Archiv"
}

$driveMappingConfig+=  [PSCUSTOMOBJECT]@{
    DriveLetter = "S"
    UNCPath= "\\PERKSINFO\SCANS"
    Description="Archiv"
}

######################################################################
#               end section script configuration                     #
######################################################################

$connected=$false
$retries=0
$maxRetries=3

Write-Output "Starting script..."
do {
    
    if (Resolve-DnsName $dnsDomainName -ErrorAction SilentlyContinue){
    
        $connected=$true

    } else{
 
        $retries++
        
        Write-Warning "Cannot resolve: $dnsDomainName, assuming no connection to fileserver"
 
        Start-Sleep -Seconds 3
 
        if ($retries -eq $maxRetries){
            
            Throw "Exceeded maximum numbers of retries ($maxRetries) to resolve dns name ($dnsDomainName)"
        }
    }
 
}while( -not ($Connected))

#Map drives
    $driveMappingConfig.GetEnumerator() | ForEach-Object {

        Write-Output "Mapping network drive $($PSItem.UNCPath)"

        New-PSDrive -PSProvider FileSystem -Name $PSItem.DriveLetter -Root $PSItem.UNCPath -Description $PSItem.Description -Persist -Scope global

        (New-Object -ComObject Shell.Application).NameSpace("$($PSItem.DriveLetter):").Self.Name=$PSItem.Description
}

Stop-Transcript
