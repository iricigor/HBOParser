function Get-HBOMovieInfo {

    <#

    .SYNOPSIS
    Gets movie information from HBO web site
    
    .DESCRIPTION
    Function reads movie information from HBO web site based on given URL(s). 
    It converts it to PowerShell objects which can be further processed and displayed for example in Excel.
    URL can be given directly or as output from Get-HBOSchedule command.
    
    .PARAMETER Link
    Mandatory. Specifies link(s) which will be parsed.
    Links can be given directly or as output from Get-HBOSchedule command.

    .PARAMETER InvokeAs
    Saves results to temporary file and opens it with default application.
    Supported formats are: 'csv','html','json' and 'txt'.
    
    .EXAMPLE
    PS C:\> Get-HBOMovieInfo 'https://www.hbo.cz/movie/x-men-prvni-třida_-72006'
    Parses given URL for movie information
    
    .EXAMPLE
    PS C:\> Get-HBOSchedule | ? type -eq movie | ? scifi | Select -First 2 | Get-HBOMovieInfo 
    Obtains information for first two scifi movies from tomorrow and then gets their details.

    .NOTES
    Version:        1.0
    Author:         iricigor@gmail.com

    #>

    [CmdletBinding()]
    param (

        [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
        [string[]]$Link,

        [parameter(Mandatory=$false,ValueFromPipeline=$false)]
        [validateset('csv','html','json','txt')]
        [string]$InvokeAs

    )

    BEGIN {

        # function begin phase
        $FunctionName = $MyInvocation.MyCommand.Name
        Write-Verbose -Message "$(Get-Date -f G) $FunctionName starting"

        $RetValues = @()
        $failStatus = 'failed'

    }

    PROCESS {

        foreach ($u1 in @($Link)) {

            if (!$u1) {continue}
                
            try {
    
                Write-Verbose -Message "$(Get-Date -f T)   obtaining page $u1..."
                $status = 'OK'
                $page = Invoke-WebRequest $u1 -Verbose:$false
    
                # get title of the movie
                Write-Verbose -Message "$(Get-Date -f T)   parsing the title"
                $H1s = $page.ParsedHtml.getElementsByTagName('h1')
                $titleHTML = $H1s | % {if ($_.outerHTML -match 'show_title_text') {$_}}
                if ($titleHTML) {
                    $originalName = $titleHTML.getElementsByTagName('span') | % {$_.innerText}
                    $localName = $titleHTML.innerText -replace $originalName,'' -replace "\r\n",''
                } else {
                    $originalName = $localName = $null
                    $status = $failStatus
                }

                # get rating
                Write-Verbose -Message "$(Get-Date -f T)   parsing the rating info"
                $RatingHTML = $page.ParsedHtml.getElementById('rating_stars')
                $Rating = if ($RatingHTML.outerHTML -match 'data\-value\=\"(\d\.\d)\"') {$Matches[1]} else {$null}
    
                # movieId and image URL
                Write-Verbose -Message "$(Get-Date -f T)   parsing movieId and imageURL"
                if ($u1 -match '\d{5,}$') {
                    $MovieId = $Matches[0]
                    $ImageURL = $u1.substring(0,18) + ($page.Images | ? src -Match $MovieId | ? src -Match '_875_256.jpg$').src
                } else {
                    $MovieId = $ImageURL = $null
                    $status = $failStatus
                }
    
                # about the movie
                Write-Verbose -Message "$(Get-Date -f T)   parsing about the movie section"
                $AboutHTML = $page.ParsedHtml.getElementById('show_about')
                if ($AboutHTML.outerHTML -match 'class=pl30[^>]+>(\d+).+>(\d+)</TIME') {
                    $year = $Matches[1]
                    $duration = $Matches[2]
                } else {
                    $duration = $Year = $null
                    $status = $failStatus
                }
                $AboutText = $AboutHTML.innerText -split "`n"
                if ($AboutText) {
                    $director = (($AboutText[0] -split ':')[1] -split ' \d')[0] # example Režie:M. Night Shyamalan 2002 | 102 minut | 12
                    $actors = ($AboutText[2] -split ':')[1]
                    $category = $AboutText[1]
                    $shortDescription = $AboutText[4]
                    $fullDescription = $AboutText[5]
                } else {
                    $director = $actors = $category = $shortDescription = $fullDescription = $null
                    $status = $failStatus
                }

                # finish
                Write-Verbose -Message "$(Get-Date -f T)   parsing completed"                
            } catch {
                $status = 'failed'
            }
    
            # return value
            Write-Verbose -Message "$(Get-Date -f T)   preparing return value"
            [PSCustomObject]@{
                url = $u1
                titleLocal = $localName
                titleOriginal = $originalName
                movieId = $MovieId
                rating = $Rating
                image =  $ImageURL
                year = $year
                duration = $duration
                director = $director
                category = $category
                actors = $actors
                shortDescription = $shortDescription
                fullDescription = $fullDescription
                parseStatus = $status
            } | Tee-Object -Variable RetValue

            $RetValues += $RetValue
        }

    }

    END {

        if ($InvokeAs) {
            $RetValues | InvokeTempItem $InvokeAs -Encoding utf8
        }

        # function closing phase
        Write-Verbose -Message "$(Get-Date -f T) $FunctionName finished"

    }
}