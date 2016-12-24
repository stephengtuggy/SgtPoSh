# Get-FileSystemEvent.ps1
# 
# Return list of file / directory creation / modification events in specified time range. If no time range specified, defaults are from the .NET minimum DateTime value to Now (the time when the script starts running).
# 
# Created  2016-12-24 by Stephen Tuggy
# Based on some earlier work of mine
# Modified 2016-12-24 by Stephen Tuggy
# Version 0.1.0
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


param ([DateTime] $StartTime = [DateTime]::MinValue, [DateTime] $EndTime = [DateTime]::Now)

function FileSystemEventsBetween([DateTime] $dtmStart, [DateTime] $dtmEnd) {
    $aPaths = @()
    (Get-PSProvider FileSystem).Drives | ForEach-Object {
        $aPaths += ,$_.Root
    }
    
    [String] $strTemp = ""
    Get-ChildItem -Path $aPaths -Force -Recurse | ForEach-Object {
        if ($_ -is [System.IO.DirectoryInfo]) {
            $strTemp = "Directory"
        } elseif ($_ -is [System.IO.FileInfo]) {
            $strTemp = "File"
        } else {
            $strTemp = "Unknown File System Object"
        }
        if (($_.CreationTime -ge $dtmStart) -and ($_.CreationTime -le $dtmEnd)) {
            $obj = (New-Object "System.Management.Automation.PSObject")
            Add-Member -MemberType NoteProperty -Name "Time"      -Value ($_.CreationTime)       -InputObject $obj
            Add-Member -MemberType NoteProperty -Name "EventType" -Value ($strTemp + " Created") -InputObject $obj
            Add-Member -MemberType NoteProperty -Name "Item"      -Value ($_.FullName)           -InputObject $obj
            $obj
        }
        if (($_.LastWriteTime -ge $dtmStart) -and ($_.LastWriteTime -le $dtmEnd)) {
            $obj = (New-Object "System.Management.Automation.PSObject")
            Add-Member -MemberType NoteProperty -Name "Time"      -Value ($_.LastWriteTime)      -InputObject $obj
            Add-Member -MemberType NoteProperty -Name "EventType" -Value ($strTemp + " Written") -InputObject $obj
            Add-Member -MemberType NoteProperty -Name "Item"      -Value ($_.FullName)           -InputObject $obj
            $obj
        }
        #if (($_.LastAccessTime -ge $dtmStart) -and ($_.LastAccessTime -le $dtmEnd)) {
        #    $obj = (New-Object "System.Management.Automation.PSObject")
        #    Add-Member -MemberType NoteProperty -Name "Time"      -Value ($_.LastAccessTime)      -InputObject $obj
        #    Add-Member -MemberType NoteProperty -Name "EventType" -Value ($strTemp + " Accessed") -InputObject $obj
        #    Add-Member -MemberType NoteProperty -Name "Item"      -Value ($_.FullName)            -InputObject $obj
        #    $obj
        #}
    }
}

FileSystemEventsBetween $StartTime $EndTime | Sort-Object Time | Format-Table -AutoSize -Wrap     # | Where-Object {!($_.EventType -match ".* Accessed")} 
