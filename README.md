# SgtPoSh
A collection of several of my most useful PowerShell scripts

## ConvertFrom-CompactExe.ps1
This script takes as input the output from compact.exe, run without /C or /U switches, which simply reports the on-disk size of each file in the set of files you specify. To run this script, pipe the output from compact.exe to ConvertFrom-CompactExe.ps1. For example: 

`compact.exe /s:E:\ /a /i | E:\Dev\Repos\GitHub\SgtPoSh\ConvertFrom-CompactExe.ps1`

This will display the CompressedLength, or actual size on disk, of each file on drive E:.

The advantage of using ConvertFrom-CompactExe.ps1 is that it converts compact.exe's output to a series of PowerShell objects. You can then do things like filter them; sort them; format them as a table or as a list; and sum total file size by extension or by directory. For example:

`compact.exe /s:E:\ /a /i | E:\Dev\Repos\GitHub\SgtPoSh\ConvertFrom-CompactExe.ps1 | Group-Object -Property Extension |% {
    $objOut         = New-Object "System.Management.Automation.PSObject"
    Add-Member -NotePropertyName Extension              -NotePropertyValue $_.Name                                                                                  -InputObject $objOut
    Add-Member -NotePropertyName FileCount              -NotePropertyValue $_.Count                                                                                 -InputObject $objOut
    Add-Member -NotePropertyName CompressedLengthSum    -NotePropertyValue ($_.Group | Measure-Object -Property CompressedLength -Sum |% {$_.Sum / 1000000000.0})   -InputObject $objOut
    $objOut
} | Sort-Object CompressedLengthSum | Format-Table -Auto > E:\CompressedLengthSumByExtension.txt`

This groups all the files on drive E by extension, then reports the total size on disk of the files with each extension (such as .txt or .exe), in GB.
