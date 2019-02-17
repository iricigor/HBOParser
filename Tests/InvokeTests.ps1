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
    $SAReport | Sort-Object Severity | Group-Object Severity,RuleName | Select-Object Count, Name
}