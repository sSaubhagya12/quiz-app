function Search-Dir-Fast($dir) {
    $excludeDirs = @(
        "Windows", "Program Files", "Program Files (x86)", "ProgramData",
        "`$Recycle.Bin", "System Volume Information", "Packages", "Microsoft",
        "Roaming", "node_modules", ".git", ".gradle", ".m2", ".metadata",
        "Android", "Cache", "AppXDeploymentServer"
    )
    
    try {
        $items = Get-ChildItem -Path $dir -ErrorAction SilentlyContinue
        foreach ($item in $items) {
            if ($item.PSIsContainer) {
                if ($excludeDirs -contains $item.Name) {
                    continue
                }
                if ($item.Name -eq "flutter") {
                    Write-Output "Found flutter directory: $($item.FullName)"
                    $batPath = Join-Path $item.FullName "bin\flutter.bat"
                    if (Test-Path $batPath) {
                        Write-Output "Found flutter.bat in: $batPath"
                    }
                }
                Search-Dir-Fast $item.FullName
            } elseif ($item.Name -eq "flutter.bat") {
                Write-Output "Found flutter.bat file: $($item.FullName)"
            }
        }
    } catch {
        # Ignore errors
    }
}

Write-Output "Starting deep fast search for Flutter on C:\..."
Search-Dir-Fast "C:\"
Write-Output "Deep search complete."
