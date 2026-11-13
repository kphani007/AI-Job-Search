<#
.SYNOPSIS
    Downloads and launches the official Jenkins LTS Windows installer.

.DESCRIPTION
    This script does NOT silently install Jenkins. It downloads the official
    .msi installer from Jenkins' own download server and launches it, so you
    still walk through the standard Jenkins setup UI (install directory,
    service account, port, etc.) and can cancel at any point.

    Run this on the Windows machine where you want Jenkins installed, from
    an elevated ("Run as Administrator") PowerShell prompt.

    Prerequisites: a supported Java runtime should be installed first. See
    docs/JENKINS_WINDOWS_INSTALL.md in this repo for details and links to
    verify current requirements, since Jenkins' required Java version has
    changed across releases.

.NOTES
    The download URL below is Jenkins' documented stable redirect
    (https://www.jenkins.io/doc/book/installing/windows/). If it ever stops
    working, get the current link from https://www.jenkins.io/download/
    instead.
#>

[CmdletBinding()]
param(
    [string]$DownloadUrl = "https://get.jenkins.io/windows-stable/jenkins.msi",
    [string]$DestinationPath = "$env:TEMP\jenkins.msi"
)

$ErrorActionPreference = "Stop"

$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning "This script should be run as Administrator so the Jenkins installer can register a Windows service. Re-launch PowerShell with 'Run as Administrator' and try again."
}

Write-Host "Downloading Jenkins installer from $DownloadUrl ..."
Invoke-WebRequest -Uri $DownloadUrl -OutFile $DestinationPath

Write-Host "Download complete: $DestinationPath"
Write-Host "Launching the Jenkins installer. Follow the on-screen setup wizard."
Start-Process -FilePath "msiexec.exe" -ArgumentList "/i `"$DestinationPath`"" -Wait

Write-Host ""
Write-Host "Installer finished. Once setup completes, open http://localhost:8080 in a browser to continue the Jenkins first-run wizard (unlock with the initial admin password, install suggested plugins, create an admin user)."
Write-Host "See docs/JENKINS_WINDOWS_INSTALL.md for the full walkthrough and troubleshooting tips."
