function Parse1Channel ($ScheduleHTML) {

    # Convert HTML to object
    $Schedule = New-Object -ComObject "HTMLFile" -Verbose:$false
    $Schedule.IHTMLDocument2_write($ScheduleHTML)
       
    # Extract channel name from image
    $img = $Schedule.getElementsByTagName('IMG') | % OuterHTML
    $ChannelName = if ($img -match 'logo (\w+)\"') {$Matches[1]} else {'Unknown'}

    # Extract all items for the channel
    $Items = $Schedule.getElementsByTagName('A')
    Write-verbose "$(Get-Date -Format T)  Parsing channel $ChannelName with $($Items.length) items"
    foreach ($Item1 in $Items) {Parse1Item $Item1}

}