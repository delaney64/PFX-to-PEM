<#
.SYNOPSIS
    Converts PFX certificates to PEM format using OpenSSL.

.DESCRIPTION
    This script automates the batch conversion of PFX (PKCS#12) certificates to PEM format.
    It processes all PFX files in a specified directory, converts them using OpenSSL,
    and organizes the output files into appropriate directories.
    
.EXAMPLE
    .\Convert-PfxToPem.ps1
    Runs the script and prompts for the PFX password
#>

# Enable strict mode for better error handling
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Function to write to log file
function Write-Log {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Message,
        
        [Parameter(Mandatory=$false)]
        [ValidateSet('Info','Warning','Error')]
        [string]$Level = 'Info'
    )
    
    $LogFile = Join-Path $PSScriptRoot "certificate_conversion.log"
    $TimeStamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    $LogMessage = "$TimeStamp [$Level] $Message"
    
    Add-Content -Path $LogFile -Value $LogMessage
    Write-Host $LogMessage
}

# Function to verify OpenSSL installation
function Test-OpenSSL {
    try {
        $null = & openssl version
        return $true
    }
    catch {
        Write-Log "OpenSSL is not installed or not in PATH. Please install OpenSSL and try again." -Level Error
        return $false
    }
}

# Function to ensure directory exists
function Confirm-Directory {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Path
    )
    
    if (-not (Test-Path $Path)) {
        try {
            New-Item -ItemType Directory -Path $Path -Force | Out-Null
            Write-Log "Created directory: $Path"
        }
        catch {
            Write-Log "Failed to create directory: $Path. Error: $_" -Level Error
            throw
        }
    }
}

# Define paths relative to script location for better portability
$ScriptRoot = $PSScriptRoot
$PFXDir = Join-Path $ScriptRoot "PFX"
$PEMDir = Join-Path $ScriptRoot "PEM"
$OldFilesDir = Join-Path $ScriptRoot "Old Files"
$CertListFile = Join-Path $ScriptRoot "PEM List.txt"

# Main script execution
try {
    Write-Log "Starting PFX to PEM conversion process"
    
    # Verify OpenSSL installation
    if (-not (Test-OpenSSL)) {
        exit 1
    }
    
    # Ensure all required directories exist
    @($PFXDir, $PEMDir, $OldFilesDir) | ForEach-Object {
        Confirm-Directory $_
    }
    
    # Remove existing certificate list if present
    if (Test-Path $CertListFile) {
        Remove-Item $CertListFile
        Write-Log "Removed existing certificate list"
    }
    
    # Get list of PFX files
    $PFXFiles = Get-ChildItem $PFXDir -Filter *.pfx
    if ($PFXFiles.Count -eq 0) {
        Write-Log "No PFX files found in directory: $PFXDir" -Level Warning
        exit 0
    }
    
    # Create new certificate list
    $PFXFiles | ForEach-Object {
        $_.Name | Out-File -FilePath $CertListFile -Append
    }
    Write-Log "Found $($PFXFiles.Count) PFX files to process"
    
    # Prompt for password securely
    $SecurePassword = Read-Host "Enter PFX password" -AsSecureString
    $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecurePassword)
    $Password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
    
    # Process each certificate
    $Certs = Get-Content -Path $CertListFile
    foreach ($Cert in $Certs) {
        $PFXPath = Join-Path -Path $PFXDir -ChildPath $Cert
        $PEMPath = Join-Path -Path $PEMDir -ChildPath "$($Cert.Replace('.pfx', '.pem'))"
        
        Write-Log "Processing certificate: $Cert"
        
        try {
            # Convert PFX to PEM using OpenSSL
            $process = Start-Process openssl -ArgumentList "pkcs12 -in `"$PFXPath`" -out `"$PEMPath`" -nodes -password pass:$Password" -NoNewWindow -PassThru -Wait
            
            if ($process.ExitCode -eq 0) {
                # Move processed PFX file to old files directory
                Move-Item -Path $PFXPath -Destination $OldFilesDir -Force
                Write-Log "Successfully converted and moved: $Cert"
            }
            else {
                Write-Log "OpenSSL conversion failed for: $Cert" -Level Error
            }
        }
        catch {
            Write-Log "Error processing certificate $Cert. Error: $_" -Level Error
        }
    }
    
    Write-Log "Certificate conversion process completed"
}
catch {
    Write-Log "Script execution failed. Error: $_" -Level Error
    exit 1
}
finally {
    # Clean up password from memory
    if ($BSTR) {
        [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($BSTR)
    }
    if ($Password) {
        $Password = $null
    }
    if ($SecurePassword) {
        $SecurePassword.Dispose()
    }
}
