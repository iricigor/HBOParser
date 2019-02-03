function Get-HBOSchedule {

[CmdletBinding()]
param (
    [ValidatePattern('[0|1][0-9]\/[0-3][0-9]')]
    [string]$Date = (Get-Date -Date ((Get-Date).AddDays(1)) -Format 'MM\/dd'),

    [ValidatePattern('\w{2}')]
    [string]$CountryCode = 'cz' # tested cz, rs, hu, pl, hr, ba, ro, bg, mk, me, si 
)

Write-verbose "$(Get-Date -Format F) Get-HBOSchedule starting"
$uri = "https://www.hbo.$countrycode/schedule/vertical_view/$date"
Write-verbose "$(Get-Date -Format T)  Obtaining $uri"
# TODO: Add error handling for iwr
$page = Invoke-WebRequest $uri -verbose:$false
Write-verbose "$(Get-Date -Format T)  Parsing HTML"
$divs = $page.AllElements | ? TagName -eq 'DIV'
$class = [regex]::Escape('<DIV class=channel>')
$chanells = $divs | ? OuterHTML -match "^\s*$class"

#write-host "-----`nSTART" -f Green
$ParsedSchedule = foreach ($schedule in $chanells.innerHTML) {

    $html = New-Object -ComObject "HTMLFile"
    #$html.IHTMLDocument2_write($chanells[0].innerHTML)
    $html.IHTMLDocument2_write($schedule)
    $html
}


foreach ($schedule1 in $ParsedSchedule) {
    
    $img = $schedule1.getElementsByTagName('IMG') | % OuterHTML
    $ChannelName = if ($img -match 'logo (\w+)\"') {$Matches[1]} else {'Unknown'}
    $Items = $schedule1.getElementsByTagName('A')
    Write-verbose "$(Get-Date -Format T)  Parsing channel $ChannelName with $($Items.length) items"

    foreach ($I1 in $Items) {
        $Text = $I1.InnerText
        $HTML = $I1.OuterHTML -join ''

        # <A class="show hasGoLink type_f type_a future   " href="/movie/sucker-punch_-70878">
        # <SPAN class=time>04:05</SPAN> <SPAN class=title>Sucker Punch</SPAN> 
        # <SPAN id=gourl___http://www.hbogo.cz/redirect/-70878 title="Sledujte nyní na HBO GO" class=showgourl></SPAN>
        # <SPAN id=info_4113536 class=showinfo></SPAN>
        # <DIV class=clear></DIV></A>

        if ($Text.Length -eq 0) {continue} # TODO: Add some warning here
        
        # Parse classes
        if ($HTML -match '^(<A class=")([^"]+)"') {
            $Classes = ($Matches[2] -split ' ') | where {$_ -match '\w'}
            # future,hasGoLink,premier,prime,show
            # type_a,b,c,d,e,f,x 
            # TODO: Add class explanations
        } else {write-error "Classes not identified for '$Text'`n$HTML"}
        
        # Parse link
        if ($HTML -match '(href=")([^"]+)"') {
            $Link = $Matches[2]  # full link should be preappended with https://www.hbo.cz
            $Type = ($Link -split '/')[1]
            #$Link
            #$Type
        } else {write-error "Link not identified for '$Text'`n$HTML"}

        # Add time and title from SPAN time/title
        if ($HTML -match '(<SPAN class=time>)([\d|:]+)(</SPAN> <SPAN class=title>)([^<]+)(</SPAN>)') {
            $Time = $Matches[2]
            $Title = $Matches[4]
            #Write-Host "$Time ($Type) $Title"            
        } else {write-error "Time and title not identified for '$Text'`n$HTML"}

        # Add HBOGO link
        if ($HTML -match '(<SPAN id=gourl___)([^\s]+)( title=)') {
            $HBOGOLink = $Matches[2]
            #Write-Host "$Time ($Type) $Title ($HBOGOLink)"
        } elseif ('hasGoLink' -notin $Classes) {
            $HBOGOLink = ''
            #Write-Host "$Time ($Type) $Title"
        } else {write-error "HBOGO link not identified for '$Text'`n$HTML"}

        # Return Object
        [pscustomobject]@{
            Date = $date
            Channel = $ChannelName
            Time = $Time
            Title = $Title
            Type = $Type  # movie or series
            # movie links
            Link = "https://www.hbo.$countrycode$Link"
            HBOGOLink = $HBOGOLink
            # some class information available on the page
            # Classes = $Classes -join ','
            # type_future = 'future' -in $Classes # all?
            # type_hasGoLink = 'hasGoLink' -in $Classes
            # type_premier = 'premier' -in $Classes
            type_prime = 'prime' -in $Classes # this is premiera, and not the one above!
            # type_show = 'show' -in $Classes # all?
            # add movie types
            action = 'type_a' -in $Classes # action, adventures
            comedy = 'type_b' -in $Classes # comedie, romance
            drama  = 'type_c' -in $Classes # drama, documentary
            family = 'type_d' -in $Classes # family
            horror = 'type_e' -in $Classes # thriller, horror
            scifi  = 'type_f' -in $Classes # sci-fi, fantasy
            others = 'type_x' -in $Classes # others
        }
    }
    
}
Write-verbose "$(Get-Date -Format F) Get-HBOSchedule finished"

}