#!/usr/bin/env pwsh
param(
    [Parameter(Mandatory=$true,Position=0)][string]$hostName,
    [Parameter(Mandatory=$true,Position=1)][int]$port
)
if($PSVersionTable.PSVersion.Major -ge 5){
    # older versions of powershell get upset if you try to run Set-StrictMode
    Set-StrictMode -Version 5.0
}
If($PSScriptRoot -eq $null -or $PSScriptRoot -eq ""){
    # https://stackoverflow.com/questions/17461237/how-do-i-get-the-directory-of-the-powershell-script-i-execute
    $PSScriptRoot=Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
}
$DEBUG=$false
#$basedir=($pwd).Path
$basedir=$PSScriptRoot
$scriptname=[System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)
$scriptext=[System.IO.Path]::GetExtension($MyInvocation.MyCommand.Name)
If($DEBUG -eq $true){
    Write-Host "hostName:", $hostName
    Write-Host "port:", $port
    Write-Host "basedir:", $basedir
    Write-Host "scriptname:", $scriptname
    Write-Host "scriptext:", $scriptext
}
if($port -in @(443, 636, 8443)){
    $outFile="$hostName.crt"
    if((![System.IO.File]::Exists((Join-Path -Path $basedir -ChildPath $outFile))) -or `
      ([System.IO.File]::Exists((Join-Path -Path $basedir -ChildPath $outFile)) -and `
      ((Read-Host "File `"$outFile`" already exists.`nContinue? (y/N)") -eq "Y"))){
        $caughtError=$false
        try{
            $tcpClient=New-Object System.Net.Sockets.TcpClient($hostName,$port)
            $sslStream=New-Object System.Net.Security.SslStream($tcpClient.GetStream(),$false,({$True} -as [Net.Security.RemoteCertificateValidationCallback]))
            $sslStream.AuthenticateAsClient($hostName,[System.Security.Cryptography.X509Certificates.X509CertificateCollection]::new(),[System.Net.SecurityProtocolType]::Tls12,$false)
            $certificate=$sslStream.RemoteCertificate
        }catch{
            Write-Host "Error: $_"
            $caughtError=$true
        }finally{
            if($sslStream -ne $null){
                $sslStream.Dispose()
            }
            if($tcpClient -ne $null){
                $tcpClient.Dispose()
            }
        }
        if($caughtError -eq $false){
            Write-Host "Certificate Subject: $($certificate.Subject)"
            Write-Host "Certificate Issuer : $($certificate.Issuer)"
            Write-Host "Certificate Expiration Date: $($certificate.GetExpirationDateString())"
            # apparently really old versions of powershell don't even have the PublicKey property
            if('PublicKey' -in $certificate.PSobject.Properties.name){
                #if(!$IsLinux){
                #    # https://github.com/PowerShell/PowerShell/issues/17643
                #    Write-Host "Certificate Key Size : $($certificate.PublicKey.Key.KeySize)"
                #}
                if($certificate.PublicKey.Oid.FriendlyName -eq "RSA"){
                    Write-Host "Certificate Key Size: $($certificate.PublicKey.GetRSAPublicKey().KeySize)"
                }else{
                    # try GetECDsaPublicKey()
                    Write-Host "Certificate Key Size: $($certificate.PublicKey.GetECDsaPublicKey().KeySize)"
                }
            }
            $certBytes=$certificate.Export([Security.Cryptography.X509Certificates.X509ContentType]::Cert)
            $certData=@(
                '-----BEGIN CERTIFICATE-----'
                [System.Convert]::ToBase64String($certBytes) -split '(.{64})' -ne '' -join [Environment]::NewLine
                '-----END CERTIFICATE-----'
            )
            Set-Content -value $certData -encoding ascii -path (Join-Path -Path $basedir -ChildPath $outFile)
        }
    }
}else{
    $usageCmd=Join-Path -Path "." -ChildPath "$scriptname$scriptext"
    Write-Host "usage: $usageCmd <hostName> <port>"
    Write-Host "  port:"
    Write-Host "    443 - https"
    Write-Host "    636 - ldaps"
    Write-Host "    8443 - https alternate"
}
exit
