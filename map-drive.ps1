param(
    [string]$DriveLetter = "Z:",
    [string]$SharePath   = "\\mystorageaccount.file.core.windows.net\myshare",
    [string]$UserName    = "Azure\mystorageaccount",
    [string]$Password    = "paste_your_access_key_here"
)

# Log file path
$LogFile = "C:\Temp\RemapDrive.log"
New-Item -Path (Split-Path $LogFile) -ItemType Directory -Force | Out-Null
Start-Transcript -Path $LogFile -Append

# Function to test drive access
function Test-Drive {
    try {
        if (Test-Path "$DriveLetter\") {
            Write-Output "Drive $DriveLetter is accessible."
            return $true
        }
    } catch {
        return $false
    }
    return $false
}

# Function to map drive
function Map-Drive {
    Write-Output "Mapping $DriveLetter to $SharePath ..."
    net use $DriveLetter /delete /y | Out-Null
    net use $DriveLetter $SharePath /user:$UserName $Password /persistent:no | Out-Null
    Write-Output "Drive $DriveLetter mapped successfully."
}

# Main logic
if (-not (Test-Drive)) {
    Write-Output "Drive $DriveLetter not accessible. Remapping..."
    Map-Drive
} else {
    Write-Output "Drive $DriveLetter is already working."
}

# Setup Scheduled Task to run this script at logon
$TaskName = "RemapNetworkDrive"
$TaskPath = "\CustomScripts"
$ScriptPath = "C:\Scripts\RemapDrive.ps1"  # <-- script will be saved here locally

if (-not (Test-Path (Split-Path $ScriptPath))) {
    New-Item -Path (Split-Path $ScriptPath) -ItemType Directory -Force | Out-Null
}

# Save this script content locally so Task Scheduler can call it later
$ThisScript = @"
param(
    [string]`$DriveLetter = "$DriveLetter",
    [string]`$SharePath   = "$SharePath",
    [string]`$UserName    = "$UserName",
    [string]`$Password    = "$Password"
)

`$LogFile = "C:\Temp\RemapDrive.log"
New-Item -Path (Split-Path `$LogFile) -ItemType Directory -Force | Out-Null
Start-Transcript -Path `$LogFile -Append

if (-not (Test-Path "`$DriveLetter\")) {
    net use `$DriveLetter /delete /y | Out-Null
    net use `$DriveLetter `$SharePath /user:`$UserName `$Password /persistent:no | Out-Null
    Write-Output "Remapped `$DriveLetter successfully on $(Get-Date)"
} else {
    Write-Output "Drive `$DriveLetter already available on $(Get-Date)"
}
Stop-Transcript
"@

$ThisScript | Out-File -FilePath $ScriptPath -Encoding utf8 -Force

if (-not (Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue)) {
    Write-Output "Creating Scheduled Task $TaskName..."
    $Action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -File `"$ScriptPath`""
    $Trigger = New-ScheduledTaskTrigger -AtLogOn
    Register-ScheduledTask -Action $Action -Trigger $Trigger -TaskName $TaskName -TaskPath $TaskPath -Description "Remap network drive on logon" -User $env:USERNAME -RunLevel Highest -Force
    Write-Output "Scheduled Task created."
} else {
    Write-Output "Scheduled Task $TaskName already exists."
}

Stop-Transcript