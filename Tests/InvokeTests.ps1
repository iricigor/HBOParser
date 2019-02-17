#
# Invoke Script Analyzer
#


if (!(Get-Module PSScriptAnalyzer -ListAvailable )) {
    Write-Output "Importing PSScriptAnalyzer"
    Install-Module PSScriptAnalyzer -Scope CurrentUser -Repository PSGallery -Confirm -Force -Verbose
    Write-Output "Rechecking it..."
    Get-Module PSScriptAnalyzer -ListAvailable
}
Import-Module PSScriptAnalyzer

$SAReport = Invoke-ScriptAnalyzer -Path (Join-path $PSScriptRoot '..') -Recurse
$Errors = $SAReport | ? Severity -eq 'Error'
if ($Errors) {
    $Errors
    Write-Error "Script Analyzer found $($Errors.Count) errors"
} elseif ($SAReport) {
    Write-Output "Script Analyzer found following issues"
    $SAReport | Sort-Object Severity | Group-Object Severity,RuleName | Select-Object Count, Name
}