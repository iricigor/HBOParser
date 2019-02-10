# HBO Parser

Parse TV schedule for HBO European channels. Results are exported as PowerShell object which can be easily viewed as CSV or Excel document.
Supported countries are: 'cz', 'rs', 'hu', 'pl', 'hr', 'ba', 'ro', 'bg', 'mk', 'me' and 'si', as per available HBO web sites.

## Disclaimer

This script is my own work. It is not an official HBO application, and it is not in any way endorsed by HBO. 
HBO web page structure may change anytime and it might break completely this script.
This script has no control over content on HBO site, use given links with carefully.

## Installation

Clone the repository and import the module
```PowerShell
git clone https://github.com/iricigor/HBOParser.git
Import-Module ./HBOParser -Force
```

## Examples

```PowerShell
PS C:\> Get-HBOSchedule
```

Gets program from HBO Czech republic for tomorrow and displays it on the screen.

```PowerShell
PS C:\> Get-HBOSchedule | ? Type -eq 'movie' | Format-Table
```

Lists all movies and displays them as a table.

```PowerShell
PS C:\> Get-HBOSchedule -Date '02/14' -CountryCode 'rs' -Verbose | Export-Excel -now
```

Gets program from Serbian HBO for February 14th and opens them in Excel (needs [ImportExcel module](https://github.com/dfinke/ImportExcel)).

```PowerShell
PS C:\> Get-HBOSchedule -DaysAhead 3 -Verbose | Export-Excel -now
```

Gets program for tomorrow (default date) and for three more days after that day.
