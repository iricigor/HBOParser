function Get-HBOSchedule {

    <#
    .SYNOPSIS
    Converts HBO schedule to PowerShell objects
    
    .DESCRIPTION
    Function reads HBO schedule from a web page and converts it to PowerShell objects.
    You can specify programme for one out of 11 supported countries.
    It can process arbitrary numbers of days, subject to availability on HBO web site.
    
    .PARAMETER Date
    Specifies date in format MM/dd for which to retrieve programme.
    Default value is tomorrow's date.

    .PARAMETER CountryCode
    Specifies country for which programme should be retrieved.
    Use two character country TLD, as per HBO web sites listed at hbo-europe.com

    .PARAMETER DaysAhead
    Specifies how many additional days to include in result.
    Default value is zero, which means only to include days specified in Date parameter.

    .PARAMETER InvokeAs
    Saves results to temporary file and opens it with default application.
    Supported formats are: 'csv','html','json' and 'txt'.
    
    .EXAMPLE
    PS C:\> Get-HBOSchedule
    Gets program from HBO Czech Republic (hbo.cz) for tomorrow and displays it on the screen.

    .EXAMPLE
    PS C:\> Get-HBOSchedule | ? Type -eq 'movie' | Format-Table
    Lists all movies and displays them as a table.

    .EXAMPLE
    PS C:\> Get-HBOSchedule -Date '02/14' -CountryCode 'rs' -Verbose
    Gets program from Serbian HBO (hbo.rs) for February 14th. It shows verbose output also.

    .EXAMPLE
    PS C:\> Get-HBOSchedule -DaysAhead 3 -InvokeAs csv -Verbose
    Gets program for tomorrow (default date) and for three more days after that day. It will save results to temporary .csv file and open it.

    .NOTES
    Version:        1.0
    Author:         iricigor@gmail.com

    #>

    [CmdletBinding()]
    param (
        [ValidatePattern('[0|1][0-9]\/[0-3][0-9]')]
        [string]$Date = (Get-Date -Date ((Get-Date).AddDays(1)) -Format 'MM\/dd'),

        [ValidatePattern('\w{2}')]
        [ValidateSet('cz', 'rs', 'hu', 'pl', 'hr', 'ba', 'ro', 'bg', 'mk', 'me', 'si')]
        [Alias('cc')]
        [string]$CountryCode = 'cz',

        [int]$DaysAhead =0,

        [parameter(Mandatory=$false,ValueFromPipeline=$false)]
        [validateset('csv','html','json','txt')]
        [string]$InvokeAs

    )

    Write-Verbose "$(Get-Date -Format F) Get-HBOSchedule starting"
    $RetValues = @()

    for ($i=0; $i -le $DaysAhead; $i++) {

        Write-Verbose "$(Get-Date -Format T)  Processing date $date"
        $uri = "https://www.hbo.$countrycode/schedule/vertical_view/$date"
        Write-Verbose "$(Get-Date -Format T)  Obtaining $uri"
        $page = Invoke-WebRequest $uri -verbose:$false -ea Stop

        Write-verbose "$(Get-Date -Format T)  Parsing HTML"
        $divs = $page.AllElements | ? TagName -eq 'DIV'
        $class = [regex]::Escape('<DIV class=channel>')
        $channels = $divs | ? OuterHTML -match "^\s*$class"

        Write-verbose "$(Get-Date -Format T)  Parsing details for $($channels.Count) channels"
        foreach ($Channel1 in $channels) {
            Parse1Channel $Channel1.innerHTML | Tee-Object -Variable RetValue
            $RetValues += $RetValue
        }

        # calculate next date
        $CurrentDate = Get-Date -Day ($date.Substring(3,2)) -Month ($date.Substring(0,2))
        $NextDate = $CurrentDate.AddDays(1)
        $date = Get-Date $NextDate -Format 'MM\/dd'
    }

    if ($InvokeAs) {$RetValues | InvokeTempItem $InvokeAs -Encoding utf8}
    Write-Verbose "$(Get-Date -Format F) Get-HBOSchedule finished"

}

Set-Alias -Name gHBO -Value Get-HBOSchedule