# Compare-DirectoryContent.ps1
# 
# Compares files by checksum from two specified directories, including their
# subdirectories.
# 
# Created  2016-12-27 by Stephen Tuggy
# Modified 2016-12-27 by Stephen Tuggy
# Version 0.4.0
# Based on prior work
# Runs with Windows PowerShell
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

param ([String]$ReferencePath, [String]$DifferencePath, [Switch]$ExcludeDifferent, [Switch]$IncludeEqual, [Switch]$IgnoreTimestamp)

# Retrieves checksum for given file. Assumes file exists.
function GetFileChecksum([System.IO.FileInfo]$fil) {
    [System.IO.FileStream] $fs = $fil.OpenRead()
    [System.Security.Cryptography.HashAlgorithm] $hashCalc = [System.Security.Cryptography.SHA256]::Create()
    [Byte[]] $abytResult = $hashCalc.ComputeHash($fs)
    $fs.Close()
    foreach ($byt in $abytResult) {
        $strResult += $byt.ToString('x2').ToLower()
    }
    return $strResult
}

function GetRelativePath([String]$fullPath, [String]$basePath) {
    [String]$strRetVal = $fullPath
    if ($strRetVal.StartsWith($basePath)) {
        $strRetVal = $strRetVal.Substring($basePath.Length)
        if ($strRetVal.StartsWith('\')) {
            $strRetVal = $strRetVal.Substring(1)
        }
    }

    return $strRetVal
}

function Get-DirectoryContent([String]$path) {
    [String]$resolvedPath = Resolve-Path $path
    if ($IgnoreTimestamp) {
        Get-ChildItem -LiteralPath $path -Recurse -Force | Where-Object {$_ -is [System.IO.FileInfo]} | Select-Object Length, @{Name='RelativePath'; Expression={GetRelativePath $_.FullName $resolvedPath}}, @{Name='Checksum'; Expression={GetFileChecksum $_}}
    }
    else {
        Get-ChildItem -LiteralPath $path -Recurse -Force | Where-Object {$_ -is [System.IO.FileInfo]} | Select-Object Length, LastWriteTimeUtc, @{Name='RelativePath'; Expression={GetRelativePath $_.FullName $resolvedPath}}, @{Name='Checksum'; Expression={GetFileChecksum $_}}
    }
}

# There ought to be a better way to do this, but I'm not sure what it is.
if ($ExcludeDifferent -and $IncludeEqual) {
    Compare-Object -ReferenceObject (Get-DirectoryContent $ReferencePath) -DifferenceObject (Get-DirectoryContent $DifferencePath) -ExcludeDifferent -IncludeEqual
}
elseif ($ExcludeDifferent -and -not $IncludeEqual) {
    Compare-Object -ReferenceObject (Get-DirectoryContent $ReferencePath) -DifferenceObject (Get-DirectoryContent $DifferencePath) -ExcludeDifferent
}
elseif (-not $ExcludeDifferent -and $IncludeEqual) {
    Compare-Object -ReferenceObject (Get-DirectoryContent $ReferencePath) -DifferenceObject (Get-DirectoryContent $DifferencePath) -IncludeEqual
}
elseif (-not $ExcludeDifferent -and -not $IncludeEqual) {
    Compare-Object -ReferenceObject (Get-DirectoryContent $ReferencePath) -DifferenceObject (Get-DirectoryContent $DifferencePath)
}
