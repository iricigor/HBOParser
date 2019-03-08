---
external help file: HBOParser-help.xml
Module Name: HBOParser
online version:
schema: 2.0.0
---

# Get-HBOMovieInfo

## SYNOPSIS
Gets movie information from HBO web site

## SYNTAX

```
Get-HBOMovieInfo [-Link] <String[]> [[-InvokeAs] <String>] [<CommonParameters>]
```

## DESCRIPTION
Function reads movie information from HBO web site based on given URL(s). 
It converts it to PowerShell objects which can be further processed and displayed for example in Excel.
URL can be given directly or as output from Get-HBOSchedule command.

## EXAMPLES

### EXAMPLE 1
```
Get-HBOMovieInfo 'https://www.hbo.cz/movie/x-men-prvni-třida_-72006'
```

Parses given URL for movie information

### EXAMPLE 2
```
Get-HBOSchedule | ? type -eq movie | ? scifi | Select -First 2 | Get-HBOMovieInfo
```

Obtains information for first two scifi movies from tomorrow and then gets their details.

## PARAMETERS

### -Link
Mandatory.
Specifies link(s) which will be parsed.
Links can be given directly or as output from Get-HBOSchedule command.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -InvokeAs
Saves results to temporary file and opens it with default application.
Supported formats are: 'csv','html','json' and 'txt'.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Version:        1.0
Author:         iricigor@gmail.com

## RELATED LINKS
