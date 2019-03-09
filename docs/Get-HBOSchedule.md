---
external help file: HBOParser-help.xml
Module Name: HBOParser
online version:
schema: 2.0.0
---

# Get-HBOSchedule

## SYNOPSIS
Converts HBO schedule to PowerShell objects

## SYNTAX

```
Get-HBOSchedule [[-Date] <String>] [[-CountryCode] <String>] [[-DaysAhead] <Int32>] [[-InvokeAs] <String>]
 [<CommonParameters>]
```

## DESCRIPTION
Function reads HBO schedule from a web page and converts it to PowerShell objects.
You can specify programme for one out of 11 supported countries.
It can process arbitrary numbers of days, subject to availability on HBO web site.

## EXAMPLES

### EXAMPLE 1
```
Get-HBOSchedule
```

Gets program from HBO Czech Republic (hbo.cz) for tomorrow and displays it on the screen.

### EXAMPLE 2
```
Get-HBOSchedule | ? Type -eq 'movie' | Format-Table
```

Lists all movies and displays them as a table.

### EXAMPLE 3
```
Get-HBOSchedule -Date '02/14' -CountryCode 'rs' -Verbose
```

Gets program from Serbian HBO (hbo.rs) for February 14th.
It shows verbose output also.

### EXAMPLE 4
```
Get-HBOSchedule -DaysAhead 3 -InvokeAs csv -Verbose
```

Gets program for tomorrow (default date) and for three more days after that day.
It will save results to temporary .csv file and open it.

## PARAMETERS

### -Date
Specifies date in format MM/dd for which to retrieve programme.
Default value is tomorrow's date.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: (Get-Date -Date ((Get-Date).AddDays(1)) -Format 'MM\/dd')
Accept pipeline input: False
Accept wildcard characters: False
```

### -CountryCode
Specifies country for which programme should be retrieved.
Use two character country TLD, as per HBO web sites listed at hbo-europe.com

```yaml
Type: String
Parameter Sets: (All)
Aliases: cc

Required: False
Position: 2
Default value: Cz
Accept pipeline input: False
Accept wildcard characters: False
```

### -DaysAhead
Specifies how many additional days to include in result.
Default value is zero, which means only to include days specified in Date parameter.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: 0
Accept pipeline input: False
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
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Version:        1.0
Author:         iricigor@gmail.com

## RELATED LINKS
