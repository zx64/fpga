$OTFDate = Get-Date -UFormat "%Y%m%d"
$OTFVer = "nightly-$OTFDate"
$OTFArchive = "fpga-toolchain-windows_amd64-$OTFVer.7z"
$OTFURL = "https://github.com/open-tool-forge/fpga-toolchain/releases/download/$OTFVer/$OTFArchive"

if (Test-Path .\fpga-toolchain\VERSION) {
    $InstalledVer = Get-Content .\fpga-toolchain\VERSION
    if ($OTFVer -eq $InstalledVer) {
        Write-Host Already at version $OTFVer
        Exit 0
    }
}

Write-Progress "Downloading $OTFArchive..."
curl.exe --location --remote-name $OTFURL
if (!$?) {
    Write-Error "Download of $OTFURL failed."
    Exit 1
}

$Check = [IO.File]::OpenRead($OTFArchive)
if (($Check.ReadByte() -ne 55) -or ($Check.ReadByte() -ne 122)) {
    $Check.Close()
    Remove-Item $OTFArchive
    Write-Error "Download of $OTFURL does not look like a 7z file."
    Exit 1
}
$Check.Close()


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

Write-Host Finished updating to $OTFVer
