# PFX to PEM Certificate Converter

A PowerShell utility for batch converting PFX (PKCS#12) certificates to PEM format using OpenSSL.

## Features

- Batch conversion of multiple PFX certificates to PEM format
- Automatic organization of processed certificates
- Maintains original PFX files in a separate directory
- Generates a processing list for tracking conversions
- Secure password handling for certificate decryption

## Prerequisites

- PowerShell 5.1 or higher
- OpenSSL installed and accessible from PATH
- Appropriate permissions to read/write in the specified directories

## Directory Structure

```
Certificate Script Dir/
├── PFX/            # Place PFX certificates here
├── PEM/            # Converted PEM certificates output
├── Old Files/      # Processed PFX files storage
└── PEM List.txt    # Generated list of processed certificates
```

## Usage

1. Place your PFX certificates in the `PFX` directory
2. Run the script:
   ```powershell
   .\pfx-to-pem-converter.ps1
   ```
3. Enter the password when prompted
4. The script will:
   - Create a list of PFX files to process
   - Convert each PFX to PEM format
   - Move processed PFX files to the Old Files directory
   - Output converted PEM files to the PEM directory

## Configuration

Update the following path variables in the script to match your environment:

```powershell
$PFXDir = "\\Certificate Script Dir\PFX\"
$PEMDir = "\\Certificate Script Dir\PEM\"
$OldFilesDir = "\\Certificate Script Dir\Old Files\"
$CertListFile = "\\Certificate Script Dir\PEM List.txt"
```

## Security Notes

- The script handles sensitive certificate data - ensure appropriate file system permissions
- Password is handled as plain text for OpenSSL compatibility
- Keep converted PEM files secure as they contain unencrypted private keys

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

