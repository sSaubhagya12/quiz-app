# Setup Android SDK script for Flutter
Write-Host "Starting Android SDK setup..." -ForegroundColor Green

$tempZip = "$env:TEMP\cmdline-tools.zip"
$sdkRoot = "C:\Android_SDK"
$cmdlineToolsDir = "$sdkRoot\cmdline-tools"
$latestDir = "$cmdlineToolsDir\latest"

# 1. Create target directories if they don't exist
if (!(Test-Path $sdkRoot)) {
    New-Item -Path $sdkRoot -ItemType Directory | Out-Null
    Write-Host "Created SDK root directory: $sdkRoot" -ForegroundColor Cyan
}

if (Test-Path $cmdlineToolsDir) {
    Write-Host "Cleaning up old cmdline-tools directory..." -ForegroundColor Yellow
    Remove-Item -Path $cmdlineToolsDir -Recurse -Force -ErrorAction SilentlyContinue
}

New-Item -Path $latestDir -ItemType Directory -Force | Out-Null
Write-Host "Created latest cmdline-tools directory: $latestDir" -ForegroundColor Cyan

# 2. Wait for download to finish if it's still running
$expectedSize = 153583359
Write-Host "Waiting for download to finish..." -ForegroundColor Yellow
while (25) {
    if (Test-Path $tempZip) {
        $currentSize = (Get-Item $tempZip).Length
        Write-Host "Current zip size: [$(($currentSize/1MB).ToString('F2')) MB / $(($expectedSize/1MB).ToString('F2')) MB]" -ForegroundColor Cyan
        if ($currentSize -ge $expectedSize) {
            Write-Host "Download finished!" -ForegroundColor Green
            break
        }
    } else {
        Write-Host "Zip file not found yet..." -ForegroundColor Red
    }
    Start-Sleep -Seconds 10
}

# 3. Extract the ZIP
$extractTemp = "$env:TEMP\cmdline-tools-extracted"
if (Test-Path $extractTemp) {
    Remove-Item -Path $extractTemp -Recurse -Force -ErrorAction SilentlyContinue
}
New-Item -Path $extractTemp -ItemType Directory | Out-Null

Write-Host "Extracting Command Line Tools..." -ForegroundColor Yellow
Expand-Archive -Path $tempZip -DestinationPath $extractTemp -Force
Write-Host "Extraction complete!" -ForegroundColor Green

# 4. Move files to the correct structure
# The zip contains a folder called 'cmdline-tools' at the root. Inside it are 'bin', 'lib', etc.
$extractedCmdlineTools = "$extractTemp\cmdline-tools"
Write-Host "Moving extracted files to $latestDir..." -ForegroundColor Yellow
Get-ChildItem -Path $extractedCmdlineTools | ForEach-Object {
    Move-Item -Path $_.FullName -Destination $latestDir -Force
}
Write-Host "Moved files successfully!" -ForegroundColor Green

# 5. Clean up temp extraction folder
Remove-Item -Path $extractTemp -Recurse -Force -ErrorAction SilentlyContinue
Write-Host "Cleaned up temporary extraction files." -ForegroundColor Green

# 6. Configure Flutter's Android SDK path
Write-Host "Configuring Flutter to use the new Android SDK path..." -ForegroundColor Yellow
flutter config --android-sdk $sdkRoot
Write-Host "Flutter configured successfully!" -ForegroundColor Green

# 7. Use sdkmanager to install platform-tools, build-tools, and platforms
Write-Host "Installing Android SDK Platform Tools, Build Tools, and Platform 34..." -ForegroundColor Yellow
$sdkManager = "$latestDir\bin\sdkmanager.bat"

# Run sdkmanager to install required packages
# We pass SDK root explicitly to ensure it installs in the right place
& $sdkManager --sdk_root=$sdkRoot "platform-tools" "build-tools;34.0.0" "platforms;android-34"

Write-Host "Android packages installed successfully!" -ForegroundColor Green

# 8. Accept Android licenses
Write-Host "Accepting Android licenses..." -ForegroundColor Yellow
# We can pipe 'y' to accept all licenses
$licensesProcess = Start-Process -FilePath "flutter" -ArgumentList "doctor --android-licenses" -RedirectStandardInput "$PSScriptRoot\licenses_input.txt" -NoNewWindow -PassThru -Wait
if ($licensesProcess.ExitCode -eq 0) {
    Write-Host "Android licenses accepted successfully!" -ForegroundColor Green
} else {
    Write-Host "Please run 'flutter doctor --android-licenses' manually in your terminal to accept licenses." -ForegroundColor Yellow
}

# 9. Verify with flutter doctor
Write-Host "Running flutter doctor..." -ForegroundColor Yellow
flutter doctor

Write-Host "All done! Android SDK is fully configured and ready." -ForegroundColor Green
