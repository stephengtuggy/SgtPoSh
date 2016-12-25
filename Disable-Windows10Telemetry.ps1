# Disable-Windows10Telemetry.ps1
# 
# Takes several steps to disable, for privacy reasons, various telemetry 
# components that are built into Windows 10.
# 
# Based in part on 
#   * http://winaero.com/blog/how-to-disable-telemetry-and-data-collection-in-windows-10/ , especially the comments by user "Wade".
#   * http://forums.majorgeeks.com/index.php?threads/services-to-disable-or-not-to.304471/
#   * https://hideu.wordpress.com/2015/08/13/how-to-kill-windows-10-privacy-spying-forever/ (Yes, this guy may be excessively paranoid, but I found this particular item useful)
# 
# Created  2016-08-10
# Modified 2016-12-24
# Version 0.2.2
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

$servicesToDisable = @(
    'DiagTrack',                                    # Connected User Experiences and Telemetry
    'diagnosticshub.standardcollector.service',     # Microsoft (R) Diagnostics Hub Standard Collector Service
    'dmwappushservice',                             # (Based on what I've read on the Internet, this is a major part of the Windows 10 spyware infrastructure)
    'CDPSvc',                                       # Connected Devices Platform Service
    'PeerDistSvc',                                  # BranchCache
    'WerSvc',                                       # Windows Error Reporting Service
    'DcpSvc',                                       # DataCollectionPublishingService
    'DeviceAssociationService',                     # Device Association Service
    'DPS',                                          # Diagnostic Policy Service
    'lfsvc',                                        # Geolocation Service
    'MapsBroker',                                   # Downloaded Maps Manager
    'BthHFSrv',                                     # Bluetooth Handsfree Service
    'bthserv',                                      # Bluetooth Support Service -- Multiple sources say to disable this
    'DsSvc',                                        # Data Sharing Service
    ''
)

$servicesToSetToManual = @(
    'ALG',                                          # Application Layer Gateway -- This apparently IS needed
    'AJRouter',                                     # AllJoyn Router Service
    'BITS',                                         # Background Intelligent Transfer Service
    'DmEnrollmentSvc',                              # Device Management Enrollment Service
    'DevQueryBroker',                               # DevQuery Background Discovery Broker
    ''
)

$servicesToLeaveAlone = @(
    'DoSvc',                                        # Delivery Optimization -- Apparently this is needed after all
)

foreach ($svc in $servicesToDisable) {
    Get-Service $svc    | Stop-Service -Force
    Get-Service $svc    | Set-Service -StartupType Disabled
}

foreach ($svc2 in $servicesToSetToManual) {
    Get-Service $svc2   | Set-Service -StartupType Manual
}

# reg add HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection\ /v AllowTelemetry /t REG_DWORD /d 0 /f
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Type DWord -Value 0
