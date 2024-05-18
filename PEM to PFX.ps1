<# 
- This script is used primarly to decrypt PFX certficiate formats into the readable PEM fomat
- Primarly for internal company purpose, this script can also be used for other resources
- PFX format included the private key, root chain, PKCs #12 and a password.
#>



#Checks to see if this script has generated list of certs previously and removes the file
$FileName = "\PEM List.txt Drectory\"
if (Test-Path $FileName) {
  Remove-Item $FileName
}

$files = Get-ChildItem "\Certificate Script Dir\PFX\"
foreach($file in $files){
 $file.Name | Out-File -filepath  $FileName -Append

}


$Password = Read-Host  "Enter password" #-AsSecureString 
$certs = Get-Content -Path "\PEM List.txt" 
foreach ($cert in $certs) {

    $PFX="\\<sever>\Certificate Script Dir\PFX\$Cert"
    $PEM= "\\sever>\Certificate Script Dir\PEM\$Cert.pem" #Will be placed in the PEM folder on the directory. 

    openssl pkcs12 -in $PFX -out $PEM -nodes -password pass:$Password 
     
    Move-Item -Path $PFX -Destination "\\<server>\Certificate Script Dir\Old Files"
}



