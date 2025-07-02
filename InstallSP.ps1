# Filename: Install-WindowsServer.ps1

# Enable Auto-Login
function Enable-AutoLogin {
    param (
        [string]$Username,
        [SecureString]$Password
    )
    $RegPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
    Set-ItemProperty -Path $RegPath -Name "AutoAdminLogon" -Value "1"
    Set-ItemProperty -Path $RegPath -Name "DefaultUsername" -Value $Username
    $PlainPassword = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password))
    Set-ItemProperty -Path $RegPath -Name "DefaultPassword" -Value $PlainPassword
}

# Install .NET Framework 4.1 (Offline)
function Install-DotNetFramework {
    param (
        [string]$SourcePath
    )
    Write-Host "Install .NET Framework 4.1..."
    Start-Process -FilePath "$SourcePath\dotNetFx41_Full_x86_x64.exe" -ArgumentList "/q /norestart" -Wait
    Write-Host ".NET Framework 4.1 installation completed."
}

# Install IIS
function Install-IIS {
    Write-Host "Install IIS..."
    Install-WindowsFeature -Name Web-Server -IncludeManagementTools
    Write-Host "IIS installation completed."
}

# Add the server to the domain
function Add-ToDomain {
    param (
        [string]$DomainName,
        [string]$DomainUser,
        [SecureString]$DomainPassword
    )
    Add-Computer -DomainName $DomainName -Credential (New-Object System.Management.Automation.PSCredential($DomainUser, $DomainPassword)) -Restart
    Write-Host "Server successfully added to the domain."
}

# Main Script
Write-Host "Starting Windows Server setup..."

# Enable Auto-Login (Replace with actual credentials)
$Username = "Administrator"
$Password = "YourSecurePassword"
Enable-AutoLogin -Username $Username -Password $Password

# Install .NET Framework 4.1 (Provide the path to the offline installer)
$DotNetSourcePath = "C:\Frameworks"
Install-DotNetFramework -SourcePath $DotNetSourcePath

# Install IIS
Install-IIS

# Add the server to the domain DEMO.Local
$DomainName = "DEMO.Domain"
$DomainUser = "DEMO\Administrator"
$DomainPassword = "YourDomainPassword"
Add-ToDomain -DomainName $DomainName -DomainUser $DomainUser -DomainPassword $DomainPassword

# Execute AutoSPInstallerMain.ps1
Write-Host "Executing AutoSPInstallerMain.ps1..."
$AutoSPInstallerPath = "C:\SharePoint\AutoSPInstallerMain.ps1"
if (Test-Path $AutoSPInstallerPath) {
    & $AutoSPInstallerPath
    Write-Host "AutoSPInstallerMain.ps1 executed successfully."
} else {
    Write-Host "Error: AutoSPInstallerMain.ps1 not found at $AutoSPInstallerPath."
}

Write-Host "Windows Server setup completed successfully."