$ErrorActionPreference = "Stop"
$host.PrivateData.ProgressBackgroundColor = "DarkGreen"
$host.PrivateData.ProgressForegroundColor = "White"

function Get-OTFVer {
    param (
        [Parameter(Mandatory)]
        [System.DateTime]$Date
    )
    Get-Date -date $Date -UFormat "nightly-%Y%m%d"
}

function Get-InstalledVersion {
    if (Test-Path .\fpga-toolchain\VERSION) {
        Get-Content .\fpga-toolchain\VERSION
    }
    else
    {
        ""
    }
}

function Get-OTFArchive {
    param (
        [Parameter(Mandatory)]
        [System.DateTime]$Date
    )

    $version = Get-OTFVer $Date
    Write-Host Attempting to get $version
    $archive = "fpga-toolchain-windows_amd64-$version.7z"
    $url = "https://github.com/open-tool-forge/fpga-toolchain/releases/download/$version/$archive"
    $filename = "{0}\$archive" -f (Get-Location)

    Write-Progress "Downloading $archive..."
    curl.exe --location --remote-name $url
    if (!$?) {
        return ""
    }

    if (-not (Test-Path $filename)) {
        return ""
    }

    $handle = [IO.File]::OpenRead($filename)
    if (($handle.ReadByte() -ne 55) -or ($handle.ReadByte() -ne 122)) {
        $handle.Close()
        Remove-Item $archive
        return ""
    }
    $handle.Close()

    return $filename
}

$current_date = Get-Date
$installed = Get-InstalledVersion

$current_ver = Get-OTFVer $current_date
if ($current_ver -eq $installed) {
    Write-Host Already up to $current_ver
    Exit 0
}


$archive = Get-OTFArchive $current_date
while ($archive -eq "") {
    Write-Host Download failed, trying previous day...
    $current_date = $current_date.AddDays(-1)
    $current_ver = Get-OTFVer $current_date
    if ($current_ver -eq $installed) {
        Write-Host Already up to $current_ver
        Exit 0
    }
    $archive = Get-OTFArchive $current_date
}

if (Test-Path fpga-toolchain) {
    Rename-Item fpga-toolchain fpga-toolchain.old
}

Write-Progress "Unpacking $archive"

7z.exe -bso0 -bsp0 x $archive
if (!$?) {
    Write-Error Unpack failed.
    Exit 1
}

if (Test-Path fpga-toolchain.old) {
    Write-Progress "Removing old version"
    Remove-Item -Recurse fpga-toolchain.old
}

Remove-Item $archive

Write-Host Finished updating to $current_ver
