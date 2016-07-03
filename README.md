# SgtPoSh
A collection of several of my most useful PowerShell scripts

## ConvertFrom-CompactExe.ps1
This script takes as input the output from compact.exe, run without /C or /U switches, which simply reports the on-disk size of each file in the set of files you specify. To run this script, pipe the output from compact.exe to ConvertFrom-CompactExe.ps1. For example:

```
compact.exe /s:E:\ /a /i | E:\Dev\Repos\GitHub\SgtPoSh\ConvertFrom-CompactExe.ps1
```

This will display the CompressedLength, or actual size on disk, of each file on drive E:.

The advantage of using ConvertFrom-CompactExe.ps1 is that it converts compact.exe's output to a series of PowerShell objects. You can then do things like filter them; sort them; format them as a table or as a list; and sum total file size by extension or by directory. For example:

```
compact.exe /s:E:\ /a /i | E:\Dev\Repos\GitHub\SgtPoSh\ConvertFrom-CompactExe.ps1 | Group-Object -Property Extension |% {
    $objOut         = New-Object "System.Management.Automation.PSObject"
    Add-Member -NotePropertyName Extension              -NotePropertyValue $_.Name                                                                                  -InputObject $objOut
    Add-Member -NotePropertyName FileCount              -NotePropertyValue $_.Count                                                                                 -InputObject $objOut
    Add-Member -NotePropertyName CompressedLengthSum    -NotePropertyValue ($_.Group | Measure-Object -Property CompressedLength -Sum |% {$_.Sum / 1000000000.0})   -InputObject $objOut
    $objOut
} | Sort-Object CompressedLengthSum | Format-Table -Auto > E:\CompressedLengthSumByExtension.txt
```

This groups all the files on drive E by extension, then reports the total size on disk of the files with each extension (such as .txt or .exe), in GB. It sends its output to a plain-text file, E:\CompressedLengthSumByExtension.txt, which you can then view in any text editor. Or, you can run:

```
Get-Content E:\CompressedLengthSumByExtension.txt | more
```

to output the file's contents to your PowerShell window.

## Get-FileSystemAndOtherEvent.ps1
This script will gather all the Windows Event Log events and filesystem events on your computer from a specified period of time, and output them in one long table, sorted by the time each event occurred. For instance, to list all the events that have taken place since 9:00 AM on March 10, 2016 (local time), run:

```
.\Get-FileSystemAndOtherEvent.ps1 -StartTime "2016-03-10T09:00:00" -EndTime ([DateTime]::Now) | more
```

It is best to run this script in an Administrator instance of PowerShell, so that you can get information on as much of the local filesystem as possible. (The script will search all local drives and directories that it can access).

Even when running as Administrator, you will probably see some error messages at the beginning of the output, stating that access to certain directories was denied. E.g.:

```
Get-ChildItem : Access to the path 'E:\System Volume Information' is denied.
At E:\Dev\Repos\GitHub\SgtPoSh\Get-FileSystemAndOtherEvent.ps1:46 char:5
+     Get-ChildItem -Path $aPaths -Force -Recurse | ForEach-Object {
+     ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : PermissionDenied: (E:\System Volume Information:String) [Get-ChildItem], UnauthorizedAccessException
    + FullyQualifiedErrorId : DirUnauthorizedAccessError,Microsoft.PowerShell.Commands.GetChildItemCommand
```

This is **normal**. All modern versions of Windows, Vista and up, have a number of directories that they prevent command-line programs from accessing. Many of these directories are hardlinks, such as "C:\Documents and Settings" to "C:\Users". The inability to access these directories should not significantly affect the script's functionality.

The only time you should be concerned is if you see more than a few dozen of these errors, or if the specific directories listed include **all** the top-level directories on one or more drives that should be accessible.

After the initial error output, you will see something like the following:

```
Time                 EventType         Item
----                 ---------         ----
3/10/2016 9:00:00 AM File Written      E:\.git\objects\60\ae90cfde3bd7d858bf778c70c285e029a2bd99
3/10/2016 9:00:00 AM File Created      E:\.git\objects\58\33ca815b406e1cf58b59f301de39ed84ca270e
3/10/2016 9:00:01 AM File Written      E:\.git\objects\58\33ca815b406e1cf58b59f301de39ed84ca270e
.
.
.
3/10/2016 9:06:00 AM File Created      E:\Dev\Repos\GitHub\SgtPoSh\.git\objects\08\b8fbecf75fe3d808454730d6f8ef832e425a85
3/10/2016 9:06:00 AM Directory Created E:\Dev\Repos\GitHub\SgtPoSh\.git\objects\08
3/10/2016 9:06:00 AM File Written      E:\Dev\Repos\GitHub\SgtPoSh\.git\objects\08\b8fbecf75fe3d808454730d6f8ef832e425a85
3/10/2016 9:06:00 AM Directory Created E:\Dev\Repos\GitHub\SgtPoSh\.git\objects\65
3/10/2016 9:06:00 AM File Created      E:\Dev\Repos\GitHub\SgtPoSh\.git\objects\65\af3d62d5097ea3b05d1c773dfd3500af3aa4fc
3/10/2016 9:06:00 AM Directory Written E:\Dev\Repos\GitHub\SgtPoSh\.git\objects\65
3/10/2016 9:06:00 AM File Written      E:\Dev\Repos\GitHub\SgtPoSh\.git\objects\65\af3d62d5097ea3b05d1c773dfd3500af3aa4fc
.
.
.
```

(Specific events and filesystem paths will vary.)

## MatchFilesFromTwoDirectoryTrees.ps1

This script is useful for comparing the contents of two different directories, recursively. Depending on the parameters you pass in, you can see only the files that are the same, or only the files that are different, between the two locations. I find this useful when I have a directory that is an old backup copy of another directory, and I'm trying to figure out what I can delete from the backup copy.

Parameters:

-PathToDelete The old backup directory, or whatever you're thinking of deleting and want to see if you can safely delete it or not.
-PathToKeep The reference directory to compare against.
-IgnoreTimestamp Switch parameter. Normally, MatchFilesFromTwoDirectoryTrees will treat two files as different if their timestamps are different by more than 2 seconds -- regardless of file sizes or contents. Passing -IgnoreTimestamp tells MatchFilesFromTwoDirectoryTrees to ignore the last modified times of two files in the same subdirectory, with the same name, between PathToDelete and PathToKeep; to go ahead and compare the files by file size and contents; and to treat the two files as equivalent if the file size and contents match.
-OutputNonMatches Switch parameter. Normally, MatchFilesFromTwoDirectoryTrees will output only files that match between PathToDelete and PathToKeep. -OutputNonMatches inverts the logic, so that the script will only output non-matches.
