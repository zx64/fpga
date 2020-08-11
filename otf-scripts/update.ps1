$OTFDate = Get-Date -UFormat "%Y%m%d"
$OTFVer = "nightly-$OTFDate"
$OTFArchive = "fpga-toolchain-windows_amd64-$OTFVer.7z"
$OTFURL = "https://github.com/open-tool-forge/fpga-toolchain/releases/download/$OTFVer/$OTFArchive"

Write-Progress "Downloading $OTFArchive..."
curl.exe -LO $OTFURL
if (!$?) {
    Write-Error Download failed.
    Exit 1
}

if (Test-Path fpga-toolchain) {
    Rename-Item fpga-toolchain fpga-toolchain.old
}

Write-Progress "Unpacking $OTFArchive"

7z.exe -bso0 -bsp0 x $OTFArchive
if (!$?) {
    Write-Error Unpack failed.
    Exit 1
}

if (Test-Path fpga-toolchain.old) {
    Write-Progress "Removing old version"
    Remove-Item -Recurse fpga-toolchain.old
}

Remove-Item $OTFArchive
