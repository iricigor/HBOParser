
Function InvokeTempItem {


[cmdletbinding()]

Param(
    [parameter(Mandatory=$true,ValueFromPipeline=$true)]
    [PSCustomObject[]]$InputObject,
  
    [parameter(Mandatory=$false,ValueFromPipeline=$false,Position=0)]
    [validateset('csv','html','json','txt')]
    [string]$OutputType='csv',

    [parameter(Mandatory=$false,ValueFromPipeline=$false)]
    [validateset('ASCII','BigEndianUnicode','Default','OEM','Unicode','UTF32','UTF7','UTF8')]
    [string]$Encoding = 'Unicode'

    
  ) #end param


BEGIN {

    $TempFile = [System.IO.Path]::GetTempFileName()+'.'+$OutputType  # yes, it will have two extensions, like tmpC551.tmp.csv
    $OutObject = @()

    $HTMLHeader = @"
<style>
BODY {font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;}
TABLE {border-width: 1px;border-style: solid;border-color: black;border-collapse: collapse;}
TH {border-width: 1px;padding: 3px;border-style: solid;border-color: black;background-color: #6495ED;}
TD {border-width: 1px;padding: 3px;border-style: solid;border-color: black;}
</style>
"@
}

PROCESS {

    foreach ($I in $InputObject) {
        $OutObject += $I
    }

} 

END {
    # function closing phase
    switch ($OutputType) {
        'csv'   { $OutObject | Export-Csv -Path $TempFile -NoTypeInformation -Encoding $Encoding }
        'html'  { $OutObject | ConvertTo-Html -Head $HTMLHeader -PostContent "<br>Generated on $(Get-Date)" | Out-File $TempFile -Encoding $Encoding }
        'json'  { $OutObject | ConvertTo-Json | Out-File $TempFile -Encoding $Encoding }
        'txt'   { $OutObject | Out-File $TempFile -Encoding $Encoding }
        Default {throw 'Unsupported type'}
    }
    
    try {Invoke-Item -Path $TempFile} catch {}
}

}
