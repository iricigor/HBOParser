#
# Fake test
#

Describe "Fake-Test" {
    It "Should be fixed by developer" {
        $true | Should -Be $true
    }
}

#
# Import commandlet
#

$ModuleName = 'HBOParser'
$here = Split-Path -Parent $MyInvocation.MyCommand.Path # test folder
$root = (get-item $here).Parent.FullName                # module root folder
Import-Module (Join-Path $root "$ModuleName.psm1") -Force

#
# Declaration tests
#
Describe 'Proper Declaration' {

    It 'Checks for existence of functions' {
        Get-Command NonExistingCommand -ea 0 | Should -Be $Null
        Get-Command 'Get-HBOSchedule' -ea 0 | Should -Not -Be $Null
        Get-Command 'Get-HBOMovieInfo' -ea 0 | Should -Not -Be $Null
    }
}

Describe 'Function should run without errors' {

    It 'Runs function without errors' {
        #{ Get-HBOSchedule } | Should -Not -Throw 
        $Items1 = (Get-HBOSchedule).Count
        $Items1 -gt 1 | Should -Be $true
    }

}


Describe 'Gets 2 days data without errors' {

    It "Gets 2 days data properly" {
        #{ Get-HBOSchedule -DaysAhead 2 } | Should -Not -Throw
        $Items2 = (Get-HBOSchedule -DaysAhead 1).Count
        $Items2 -gt $Items1 | Should -Be $true -Because "one day ($Items1) should have less items than three days ($Items2)"
    }
    
}

Describe 'Gets data for each country without errors'  -Tag 'LongRunning' {

    foreach ($Country in @('cz', 'rs', 'hu', 'pl', 'hr', 'ba', 'ro', 'bg', 'mk', 'me', 'si')) {

        It "Gets data for country $Country properly" {
            { Get-HBOSchedule -CountryCode $Country } | Should -Not -Throw  # long running!
        }    
    }
}

Describe 'Gets movie info for first two scifi movies' {

    It "Gets movie info for first two scifi movies properly" {
        #{ Get-HBOSchedule | ? type -eq movie | ? scfi | Select -First 2 | Get-HBOMovieInfo } | Should -Not -Throw
        $TwoItems = (Get-HBOSchedule | ? type -eq movie | ? scifi | Select -First 2 | Get-HBOMovieInfo).titleLocal.Count
        $TwoItems | Should -Be 2 -Because "Two movies cannot have $TwoItems titles"
    }    
}

Describe 'Invoking item should work without errors' {
    
    $sampleURL = 'https://www.hbo.cz/movie/x-men-prvni-třida_-72006'

    It "Invoking schedule as txt should work without errors" {
        { Get-HBOSchedule -InvokeAs txt } | Should -Not -Throw
    }    
    It "Invoking movie info as csv should work without errors" {
        { Get-HBOMovieInfo $sampleURL -InvokeAs csv } | Should -Not -Throw
    }    
    It "Invoking schedule as html should work without errors" {
        { Get-HBOSchedule -InvokeAs html } | Should -Not -Throw
    }    
    It "Invoking movie info as json should work without errors" {
        { Get-HBOMovieInfo $sampleURL -InvokeAs json } | Should -Not -Throw
    }    
}

Describe 'Proper Documentation' {

	It 'Updates documentation and does git diff' {
		# install PlatyPS
        if (!(Get-Module platyPS -List -ea 0)) {Install-Module platyPS -Force -Scope CurrentUser}
		Import-Module platyPS
		# update documentation
		Push-Location -Path $root
        New-MarkdownHelp -Module $ModuleName -OutputFolder .\docs -Force
        $diff = git diff .\Docs .\en-US
        Pop-Location
		$diff | Should -Be $null
	}
}

Describe 'Error Handling' -Tag Mock {

    Mock -ModuleName $ModuleName Invoke-WebRequest {return $null}
    It 'Does not throw an error for wrong data' {
        { Get-HBOSchedule } | Should -Not -Throw
    }

    It 'It returns no schedule rows for empty data' {
        @(Get-HBOSchedule).Count | Should -Be 0
    }

    It 'returns no movie info for empty data' {
        (Get-HBOMovieInfo 'fakeurl').parseStatus | Should -Be 'failed'
    }
    It 'returns no movie info for empty data, even if page exists' {
        (Get-HBOMovieInfo 'www.bing.com').parseStatus | Should -Be 'failed'
    }

}