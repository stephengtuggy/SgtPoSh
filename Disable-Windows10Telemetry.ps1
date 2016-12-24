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
# Modified 2016-12-24
# Version 0.2.0
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

trap [System.Exception] {
    Write-Warning "Trapped exception: $_"
}

$badServices = @(
    'DiagTrack',                                    # Connected User Experiences and Telemetry
    'diagnosticshub.standardcollector.service',     # Microsoft (R) Diagnostics Hub Standard Collector Service
    'dmwappushservice',                             # (No further description given, but I'm pretty sure I don't want it)
    'CDPSvc',                                       # Connected Devices Platform Service
    'AJRouter',                                     # AllJoyn Router Service
    'ALG',                                          # Application Layer Gateway
    'PeerDistSvc',                                  # BranchCache
    'WerSvc',                                       # Windows Error Reporting Service
    'DcpSvc',                                       # DataCollectionPublishingService
    'DoSvc',                                        # Delivery Optimization
    'DeviceAssociationService',                     # Device Association Service
    'DmEnrollmentSvc',                              # Device Management Enrollment Service
    'DevQueryBroker',                               # DevQuery Background Discovery Broker
    'DPS',                                          # Diagnostic Policy Service
    ''
)

foreach ($svc in $badServices) {
    Get-Service $svc | Stop-Service -Force
    Get-Service $svc | Set-Service -StartupType Disabled
}

reg add HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection\ /v AllowTelemetry /t REG_DWORD /d 0 /f
