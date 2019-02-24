

#
#  Display diagnostic info within VSTS
#

if ($Env:TF_BUILD -eq $True) {
    Get-ChildItem Env:\
    Get-Variable | Format-Table Name, Value
}

#
# Invoke Script Analyzer
#


if (!(Get-Module PSScriptAnalyzer -ListAvailable )) {
    Write-Output "Installing PSScriptAnalyzer"
    Install-Module PSScriptAnalyzer -Scope CurrentUser -Repository PSGallery -Force
}

$SAReport = Invoke-ScriptAnalyzer -Path (Join-path $PSScriptRoot '..') -Recurse
$Errors = $SAReport | ? Severity -eq 'Error'
if ($Errors) {
    $Errors
    Write-Error "Script Analyzer found $($Errors.Count) errors"
} elseif ($SAReport) {
    Write-Output "Script Analyzer found following issues"
    $SAReport | Sort-Object Severity,RuleName
}
#
#
#  TODO: Check documentation
#


#
#  Invoke Pester tests
#

if (!(Get-Module Pester -List | where Version -ge 4.0.0)) {
    Write-Host "`nInstalling Pester"
    Install-Module -Name Pester -Force -SkipPublisherCheck -Scope CurrentUser -Repository PSGallery
}

Write-Host "Run Pester tests"
$Result = Invoke-Pester -PassThru -OutputFile PesterTestResults.xml -CodeCoverage .\P*\*.ps1 -CodeCoverageOutputFile 'PesterCodeCoverageResults.xml'
if ($Result.failedCount -ne 0) {Write-Error "Pester returned errors"}
