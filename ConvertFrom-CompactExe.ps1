# ConvertFrom-CompactExe.ps1
# 
# Converts list output from compact.exe (run without /C or /U switches) to
# a series of custom PSObjects, each including a file's full name, size
# before compression, and size after compression.
# 
# Created  2008-08-23
# Modified 2016-03-09
# Version 0.1.3.0
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

BEGIN {
    [String] $strCurrentLine = ""
    [String] $strName        = ""
    [String] $strDirectory   = ""
             $objOut         = New-Object "System.Management.Automation.PSObject"
    Add-Member -MemberType NoteProperty -Name "Name"             -Value ""     -InputObject $objOut
    Add-Member -MemberType NoteProperty -Name "Extension"        -Value ""     -InputObject $objOut
    Add-Member -MemberType NoteProperty -Name "DirectoryName"    -Value ""     -InputObject $objOut
    Add-Member -MemberType NoteProperty -Name "FullName"         -Value ""     -InputObject $objOut
    Add-Member -MemberType NoteProperty -Name "Compressed"       -Value $False -InputObject $objOut
    Add-Member -MemberType NoteProperty -Name "Length"           -Value -1     -InputObject $objOut
    Add-Member -MemberType NoteProperty -Name "CompressedLength" -Value -1     -InputObject $objOut
    Add-Member -MemberType NoteProperty -Name "CompressionRatio" -Value  0.0   -InputObject $objOut
}

PROCESS {
    $strCurrentLine = $_
    if ($strCurrentLine -match "^\s*Listing\s+(?<DirectoryName>.*)$") {
        $strDirectory            = $Matches["DirectoryName"]
        if ($strDirectory -ne [System.IO.Path]::GetPathRoot($strDirectory)) {
            $strDirectory        = $strDirectory.TrimEnd("\")
        }
    } elseif ($strCurrentLine -match "^\s*(?<Length>\d+)\s+\:\s*(?<CompressedLength>\d+)\s+\=\s+(?<CompressionRatio>\d+\.\d+)\s+to\s+1\s+(?<Compressed>C?)\s+(?<Name>.*)$") {
        $objOut.Name             = $Matches["Name"]
        $objOut.Extension        = [System.IO.Path]::GetExtension($objOut.Name)
        $objOut.DirectoryName    = $strDirectory
        $objOut.FullName         = [System.IO.Path]::Combine($objOut.DirectoryName, $objOut.Name)
        if ($Matches["Compressed"]) {
            $objOut.Compressed   = $True
        } else {
            $objOut.Compressed   = $False
        }
        $objOut.Length           = ([Int64]  $Matches["Length"])
        $objOut.CompressedLength = ([Int64]  $Matches["CompressedLength"])
        $objOut.CompressionRatio = ([Single] $Matches["CompressionRatio"])
        if ([System.IO.File]::Exists($objOut.FullName)) {
            $objOut                                                               # Output result
        }
        $objOut                  = New-Object "System.Management.Automation.PSObject"
        Add-Member -MemberType NoteProperty -Name "Name"             -Value ""     -InputObject $objOut
        Add-Member -MemberType NoteProperty -Name "Extension"        -Value ""     -InputObject $objOut
        Add-Member -MemberType NoteProperty -Name "DirectoryName"    -Value ""     -InputObject $objOut
        Add-Member -MemberType NoteProperty -Name "FullName"         -Value ""     -InputObject $objOut
        Add-Member -MemberType NoteProperty -Name "Compressed"       -Value $False -InputObject $objOut
        Add-Member -MemberType NoteProperty -Name "Length"           -Value -1     -InputObject $objOut
        Add-Member -MemberType NoteProperty -Name "CompressedLength" -Value -1     -InputObject $objOut
        Add-Member -MemberType NoteProperty -Name "CompressionRatio" -Value  0.0   -InputObject $objOut
    } else {
    }
}

END {
}