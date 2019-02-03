# HBO Parser - Work in progress

parse TV schedule for HBO european channels

## Examples

First run a script with `.\ParseHBO.ps1` to import new function `Get-HBOSchedule` into your session. Then run any of the commands below.

```PowerShell
PS C:\> Get-HBOSchedule
```

Gets program from HBO Czech republic for tomorrow and displays it on the screen.

```PowerShell
PS C:\> Get-HBOSchedule -Date '02/14' -CountryCode 'rs' -Verbose
```

Gets program from Serbian HBO for February 14th

```PowerShell
PS C:\> Get-HBOSchedule | ? Type -eq 'movies' | Export-Excel -now
```

Lists all the movies from tomorrow and opens them in Excel (needs [ImportExcel module](https://github.com/dfinke/ImportExcel)).

