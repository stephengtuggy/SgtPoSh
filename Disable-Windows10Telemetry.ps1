# Disable-Windows10Telemetry.ps1
# 
# Takes several steps to disable, for privacy reasons, various telemetry 
# components that are built into Windows 10.
# 
# Based in part on 
# http://winaero.com/blog/how-to-disable-telemetry-and-data-collection-in-windows-10/
# , especially the comments by user "Wade".
# 
# Created  2016-08-10
# Modified 2016-08-10
# Version 0.1.1
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

foreach ($svc in @("DiagTrack", "diagnosticshub.standardcollector.service", "dmwappushservice")) {
    Get-Service $svc | Set-Service -StartupType Disabled
    Get-Service $svc | Stop-Service
}

reg add HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection\ /v AllowTelemetry /t REG_DWORD /d 0 /f
