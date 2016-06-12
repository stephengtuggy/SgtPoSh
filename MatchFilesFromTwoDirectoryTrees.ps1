# MatchFilesFromTwoDirectoryTrees.ps1
# 
# Compares files from two specified directories, including their
# subdirectories. Can be configured either to output all matches or to output
# any non-matches.
# 
# Created  2010-06-23 by Stephen Tuggy
# Modified 2016-06-12 by Stephen Tuggy
# Version 0.3.0
# Based on existing code from "PowerShell Scratchpad.ps1"
# Runs with Windows PowerShell 1.0
# 
# The MIT License (MIT)
# 
# Copyright (c) 2016 Stephen G Tuggy
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.


param ([String] $PathToDelete, [String] $PathToKeep, [Switch] $IgnoreTimestamp, [Switch] $OutputNonMatches)

New-Variable -Name "tmscFileTimeMargin" -Value ([TimeSpan] "00:00:02") -Option Constant

# Retrieves MD5 checksum for given file. Assumes file exists.
function GetFileChecksum([System.IO.FileInfo] $fil) {
    [System.IO.FileStream] $fs = $fil.OpenRead()
    [System.Security.Cryptography.MD5] $md5calc = [System.Security.Cryptography.MD5]::Create()
    [Byte[]] $abytResult = $md5calc.ComputeHash($fs)
    $fs.Close()
    foreach ($byt in $abytResult) {
        $strResult += $byt.ToString("x2").ToLower()
    }
    $strResult
}

# Compares two files by size, date last modified, and contents. Assumes both 
# files exist. Returns $True if they are equal, $False if not.
function CompareFiles([System.IO.FileInfo] $fileA, [System.IO.FileInfo] $fileB, [Boolean] $blnIgnoreFileTime) {
    if ($fileA.Length -ne $fileB.Length) {
        Write-Verbose ('File "' + $fileA.FullName + '" and "' + $fileB.FullName + '" are not the same length.')
        $False
    } elseif (($blnIgnoreFileTime -eq $False) -and ([Math]::Abs(($fileA.LastWriteTime - $fileB.LastWriteTime).Ticks) -gt ($tmscFileTimeMargin.Ticks))) {
        Write-Verbose ('File "' + $fileA.FullName + '" and "' + $fileB.FullName + '" were modified at different times.')
        $False
    } elseif ((GetFileChecksum($fileA)) -ne (GetFileChecksum($fileB))) {
        Write-Verbose ('File "' + $fileA.FullName + '" and "' + $fileB.FullName + '" differ in contents.')
        $False
    } else {
        $True
    }
}

filter MatchFilesFromTwoDirectoryTrees ([String] $strPathToDelete, [String] $strPathToKeep, [Boolean] $blnIgnoreFileTime, [Boolean] $blnOutputNonMatches = $False) {
    $tmp = $_
    if ($tmp -is [System.IO.FileInfo]) {
        [System.IO.FileInfo] $file1 = $tmp
    } else {
        [System.IO.FileInfo] $file1 = New-Object "System.IO.FileInfo" ($tmp -as [String])
    }
    [String] $strRelativePath = ""
    if ($file1.FullName.StartsWith($strPathToDelete)) {
        $strRelativePath = $file1.FullName.SubString($strPathToDelete.Length) 
        if ($strRelativePath.StartsWith("\")) {
            $strRelativePath = $strRelativePath.SubString("\".Length)
        }
        [System.IO.FileInfo] $file2 = New-Object "System.IO.FileInfo" ([System.IO.Path]::Combine($strPathToKeep, $strRelativePath))
        if ($file2.Exists) {
            [Boolean] $blnResult = CompareFiles $file1 $file2 $blnIgnoreFileTime
            if (($blnOutputNonMatches -eq $True) -and ($blnResult -eq $False)) {
                $strRelativePath                            # Output
            } elseif (($blnOutputNonMatches -eq $False) -and ($blnResult -eq $True)) {
                $strRelativePath                            # Output
            }
        } elseif ($blnOutputNonMatches -eq $True) {
            $strRelativePath                                # Output
        }
    } else {
        $strRelativePath = $file1.FullName 
        Write-Warning ("File '" + $strRelativePath + "' is not in directory tree '" + $strPathToDelete + "'.")
    }
}

Get-ChildItem $PathToDelete -Recurse -Force | Where-Object {$_ -is [System.IO.FileInfo]} | MatchFilesFromTwoDirectoryTrees $PathToDelete $PathToKeep $IgnoreTimestamp $OutputNonMatches | ForEach-Object {[System.IO.Path]::Combine($PathToDelete, $_)}
