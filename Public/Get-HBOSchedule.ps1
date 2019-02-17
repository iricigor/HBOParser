function Get-HBOSchedule {

    [CmdletBinding()]
    param (
        [ValidatePattern('[0|1][0-9]\/[0-3][0-9]')]
        [string]$Date = (Get-Date -Date ((Get-Date).AddDays(1)) -Format 'MM\/dd'),

        [ValidatePattern('\w{2}')]
        [ValidateSet('cz', 'rs', 'hu', 'pl', 'hr', 'ba', 'ro', 'bg', 'mk', 'me', 'si')]
        [string]$CountryCode = 'cz',

        [int]$DaysAhead =0
    )

    Write-Verbose "$(Get-Date -Format F) Get-HBOSchedule starting"

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
        foreach ($Channel1 in $channels) {Parse1Channel $Channel1.innerHTML}

        # calculate next date
        $CurrentDate = Get-Date -Day ($date.Substring(3,2)) -Month ($date.Substring(0,2))
        $NextDate = $CurrentDate.AddDays(1)
        $date = Get-Date $NextDate -Format 'MM\/dd'
    }
        
    Write-verbose "$(Get-Date -Format F) Get-HBOSchedule finished"

}

Set-Alias -Name gHBO -Value Get-HBOSchedule