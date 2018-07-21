# Measure-ChildDirectorySizeOnDisk.ps1
# 
# For each directory that is an immediate child of the current directory,
# lists the total size on disk of that subdirectory and everything in it.
# This calculation takes into account what files and directories might be compressed,
# etc.
# 
# Created  2018-07-21
# Modified 2018-07-21
# Version 0.3.0
# Runs with Windows PowerShell
# 
# The MIT License (MIT)
# 
# Copyright (c) 2018 Stephen G Tuggy
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


filter ConvertFromCompactExe {
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
}

Get-ChildItem -Force | Where-Object {$_.PSIsContainer} | ForEach-Object {
             $objOut2     = New-Object "System.Management.Automation.PSObject"
    [String] $strFullName = $_.FullName
    Add-Member -InputObject $objOut2 -MemberType NoteProperty -Name "FullName"        -Value $strFullName
    Add-Member -InputObject $objOut2 -MemberType NoteProperty -Name "TotalSizeOnDisk" -Value (compact.exe /s:$strFullName /a /i | ConvertFromCompactExe | Measure-Object -Property CompressedLength -Sum | ForEach-Object {$_.Sum})
    $objOut2
}
