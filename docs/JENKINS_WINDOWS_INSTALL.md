# Installing Jenkins on Windows

I'm running this session in an isolated Linux cloud container, so I have no
access to your physical Windows machine and cannot install anything on it
for you. This guide and the accompanying script
(`scripts/install-jenkins-windows.ps1`) are meant to be **downloaded and run
on your own Windows computer** (in an elevated PowerShell prompt) to do the
install yourself.

I am not fully certain these are the current minimum requirements or
download URLs — Jenkins' Java requirement and installer packaging have
changed between LTS lines before, and my knowledge has a cutoff. Please
verify against the official docs before you install:
- https://www.jenkins.io/download/
- https://www.jenkins.io/doc/book/installing/windows/

## 1. Prerequisites

- **Windows 10/11 or Windows Server**, with administrator rights.
- **Java**: Jenkins requires a supported Java runtime (recent Jenkins LTS
  releases have required Java 17 or Java 21 — I'm not certain which is
  current as of your install date, so check the download page above and
  install the version it names). Options:
  - [Eclipse Temurin](https://adoptium.net/) (recommended distribution), or
  - `winget install EclipseAdoptium.Temurin.17.JDK` (adjust the version to
    whatever Jenkins currently requires).
- **Open port 8080** (Jenkins' default web UI port) on your firewall, or be
  ready to choose a different port during setup.

## 2. Recommended method: official Windows installer (.msi)

This is the simplest, most supported path for a single Windows machine.

1. Go to https://www.jenkins.io/download/ and download the **Windows**
   installer (`jenkins.msi`) — pick the **LTS** release unless you
   specifically need the weekly release.
2. Run the `.msi` file. The installer will:
   - Install Jenkins as a **Windows service** (so it starts automatically on
     boot).
   - Prompt you to choose an install directory and a service account.
   - Ask which port to run on (default `8080`).
3. Once installed, Jenkins starts automatically. Open a browser to:
   `http://localhost:8080`
4. The setup wizard asks for an **initial admin password**. Find it on disk
   at:
   `C:\Program Files\Jenkins\secrets\initialAdminPassword`
   (the exact path depends on where you installed Jenkins — the setup page
   itself tells you the path to check).
5. Paste that password in, then choose **"Install suggested plugins"**.
6. Create your first admin user when prompted, and finish the wizard.

## 3. Alternative: winget

If you'd rather use the Windows Package Manager:

```powershell
winget install Jenkins.Jenkins
```

I'm not fully certain of this package ID's current name/availability — verify
with `winget search jenkins` first, since package IDs on winget can change.

## 4. Alternative: run via WAR file (no service, manual control)

If you don't want Jenkins installed as a service:

```powershell
java -jar jenkins.war --httpPort=8080
```

Download `jenkins.war` from the same download page. This runs Jenkins in the
foreground of that terminal — closing the window stops Jenkins.

## 5. Managing the Jenkins service afterward

Once installed as a Windows service, standard service commands apply:

```powershell
# Check status
Get-Service Jenkins

# Stop / Start / Restart
Stop-Service Jenkins
Start-Service Jenkins
Restart-Service Jenkins
```

## 6. Troubleshooting pointers

- **Jenkins won't start**: check the Windows Event Viewer (Application log)
  and Jenkins' own log file, typically under the install directory
  (`C:\Program Files\Jenkins\jenkins.err.log` / `jenkins.out.log` — verify
  the exact path for your install).
- **Port 8080 already in use**: reconfigure the port in the service's
  Jenkins config (`C:\Program Files\Jenkins\jenkins.xml`, the `--httpPort`
  argument) then restart the service.
- **Java version mismatch errors on startup**: reinstall/point Jenkins at
  the Java version its startup log says it needs.

## 7. Script

`scripts/install-jenkins-windows.ps1` in this repo automates steps 1–3 above
(download the official `.msi` and launch it) for convenience. Review it
before running — it downloads an executable installer from the internet and
runs it, which needs your explicit consent and administrator rights.
