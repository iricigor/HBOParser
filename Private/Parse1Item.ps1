function Parse1Item ($I1) {

    #
    # Example of received object
    #
    # <A class="show hasGoLink type_f type_a future   " href="/movie/sucker-punch_-70878">
    # <SPAN class=time>04:05</SPAN> <SPAN class=title>Sucker Punch</SPAN>
    # <SPAN id=gourl___http://www.hbogo.cz/redirect/-70878 title="Sledujte nyní na HBO GO" class=showgourl></SPAN>
    # <SPAN id=info_4113536 class=showinfo></SPAN>
    # <DIV class=clear></DIV></A>

    $Text = $I1.InnerText
    $HTML = $I1.OuterHTML -join ''

    if ($Text.Length -eq 0) {
        Write-Warning "No inner text for $I1"
        continue
    }

    # Parse classes
    if ($HTML -match '^(<A class=")([^"]+)"') {
        $Classes = ($Matches[2] -split ' ') | where {$_ -match '\w'}
        # future,hasGoLink,premier,prime,show
        # type_a,b,c,d,e,f,x
        # TODO: Add class explanations
    } else {
        Write-Error "Classes not identified for '$Text'`n$HTML"
    }

    # Parse link
    if ($HTML -match '(href=")([^"]+)"') {
        $Link = $Matches[2]  # full link should be preappended with https://www.hbo.cz
        $Type = ($Link -split '/')[1]
    } else {
        Write-Error "Link not identified for '$Text'`n$HTML"
    }

    # Add time and title from SPAN time/title
    if ($HTML -match '(<SPAN class=time>)([\d|:]+)(</SPAN> <SPAN class=title>)([^<]+)(</SPAN>)') {
        $Time = $Matches[2]
        $Title = $Matches[4]
    } else {
        Write-Error "Time and title not identified for '$Text'`n$HTML"
    }

    # Add HBOGO link
    if ($HTML -match '(<SPAN id=gourl___)([^\s]+)( title=)') {
        $HBOGOLink = $Matches[2]
    } elseif ('hasGoLink' -notin $Classes) {
        $HBOGOLink = ''
    } else {
        Write-Error "HBOGO link not identified for '$Text'`n$HTML"
    }

    # Return Object
    [pscustomobject]@{
        Date = $date            # not in current scope
        Channel = $ChannelName  # not in current scope
        Time = $Time
        Title = $Title
        Type = $Type  # movie or series
        # movie links
        Link = "https://www.hbo.$countrycode$Link" # not in current scope
        HBOGOLink = $HBOGOLink
        # some class information available on the page
        # Classes = $Classes -join ','
        # type_future = 'future' -in $Classes # all?
        # type_hasGoLink = 'hasGoLink' -in $Classes
        # type_premier = 'premier' -in $Classes
        premiere = 'prime' -in $Classes # this is premiere, and not the one above!
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