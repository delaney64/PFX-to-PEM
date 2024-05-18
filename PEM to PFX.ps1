<#
- This script is primarily used to decrypt PFX certificate formats into the readable PEM format.
- Primarily for internal company purposes, this script can also be used for other resources.
- PFX format includes the private key, root chain, PKCS#12, and a password.
#>

# Define paths
$PFXDir = "\\Certificate Script Dir\PFX\"
$PEMDir = "\\Certificate Script Dir\PEM\"
$OldFilesDir = "\\Certificate Script Dir\Old Files\"
$CertListFile = "\\Certificate Script Dir\PEM List.txt"

# Check if the certificate list file exists and remove it
if (Test-Path $CertListFile) {
    Remove-Item $CertListFile
}

# Get list of PFX files and output their names to the certificate list file
$PFXFiles = Get-ChildItem $PFXDir -Filter *.pfx
foreach ($file in $PFXFiles) {
    $file.Name | Out-File -FilePath $CertListFile -Append
}

# Prompt user for password
$Password = Read-Host "Enter password" #-AsSecureString 

# Read certificate list file
$Certs = Get-Content -Path $CertListFile 
foreach ($Cert in $Certs) {
    $PFXPath = Join-Path -Path $PFXDir -ChildPath $Cert
    $PEMPath = Join-Path -Path $PEMDir -ChildPath "$Cert.pem"

    # Convert PFX to PEM using OpenSSL
    & openssl pkcs12 -in $PFXPath -out $PEMPath -nodes -password pass:$Password 

    # Move the processed PFX file to the old files directory
    Move-Item -Path $PFXPath -Destination $OldFilesDir
}
