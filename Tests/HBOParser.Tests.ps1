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


Describe 'Gets 3 days data without errors' {

    It "Gets 3 days data properly" {
        #{ Get-HBOSchedule -DaysAhead 2 } | Should -Not -Throw
        $Items3 = (Get-HBOSchedule -DaysAhead 2).Count
        $Items3 -gt $Items1 | Should -Be $true "one day ($Items1) should have less items than three days ($Items3)"
    }
    
}

Describe 'Gets data for each country without errors'  -Tag 'LongRunning' {

    foreach ($Country in @('cz', 'rs', 'hu', 'pl', 'hr', 'ba', 'ro', 'bg', 'mk', 'me', 'si')) {

        It "Gets data for country $Country properly" {
            { Get-HBOSchedule -CountryCode $Country } | Should -Not -Throw  # long running!
        }
    
    }

}

Describe 'Gets movie info for first three scifi movies' {

    It "Gets movie info for first three scifi movies properly" {
        #{ Get-HBOSchedule | ? type -eq movie | ? scfi | Select -First 2 | Get-HBOMovieInfo } | Should -Not -Throw
        $TwoItems = (Get-HBOSchedule | ? type -eq movie | ? scifi | Select -First 2 | Get-HBOMovieInfo).titleLocal.Count
        $TwoItems | Should -Be 2 -Because "Two movies cannot have $TwoItems titles"
    }
    
}
