# HBO Parser

Parse TV schedule for HBO European channels. Results are exported as PowerShell object which can be easily viewed as CSV or Excel document.

In total, 11 countries are supported: 'cz', 'rs', 'hu', 'pl', 'hr', 'ba', 'ro', 'bg', 'mk', 'me' and 'si', as per [available HBO web sites](https://www.hbo-europe.com/).

## Disclaimer

This script is my own work. It is not an official HBO application, and it is not in any way endorsed by HBO. 
HBO web page structure may change anytime and it might break completely this script.
This script has no control over content on HBO site, use given links carefully.
HBO has all the legal rights over linked content.

## Installation

Clone the repository and import the module
```PowerShell
git clone https://github.com/iricigor/HBOParser.git
Import-Module ./HBOParser -Force
```
[![Build status](https://dev.azure.com/iiric/PS1/_apis/build/status/HBO%20Parser%20CI)](https://dev.azure.com/iiric/PS1/_build/latest?definitionId=12)

Please note that this module might break anytime, due to modifications on HBO websites.
If this things happen, feel free to open an issue or use dedicated Skype support chat _(no Skype ID required)_.
If you want to contribute, please fork the code and make a new PR after!

[![chat on Skype](https://img.shields.io/badge/chat-on%20Skype-blue.svg?style=flat)](https://join.skype.com/hQMRyp7kwjd2)

![GitHub open issues](https://img.shields.io/github/issues/iricigor/HBOParser.svg?style=flat)
![GitHub closed issues](https://img.shields.io/github/issues-closed/iricigor/HBOParser.svg?style=flat)
![GitHub](https://img.shields.io/github/license/iricigor/HBOParser.svg?style=flat)
![GitHub top language](https://img.shields.io/github/languages/top/iricigor/HBOParser.svg?style=flat)

## Examples

```PowerShell
PS C:\> Get-HBOSchedule
```

Gets program from [HBO Czech Republic](https://www.hbo.cz/) for tomorrow and displays it on the screen.

```PowerShell
PS C:\> Get-HBOSchedule | ? Type -eq 'movie' | Format-Table
```

Lists all movies and displays them as a table.

```PowerShell
PS C:\> Get-HBOSchedule -Date '02/14' -CountryCode 'rs' -Verbose | Export-Excel -now
```

Gets program from [Serbian HBO](https://www.hbo.rs/) for February 14th and opens them in Excel (needs [ImportExcel module](https://github.com/dfinke/ImportExcel) by [dfinke](https://github.com/dfinke)).
```PowerShell
PS C:\> Get-HBOSchedule -DaysAhead 3 -Verbose | Export-Excel -now
```

Gets program for tomorrow (default date) and for three more days after that day.
