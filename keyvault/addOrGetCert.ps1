param(
  [string] $certName,
  [string] $vaultName,
  [string] $subject,
  [string] $tagString,
  [int] $monthsValid = 12
)

Write-Host $tagString
$tags = @{}
($tagString | ConvertFrom-Json).psobject.properties | ForEach-Object { $tags[$_.Name] = $_.Value }

$existing = $null

$existing = Get-AzKeyVaultCertificate -VaultName $vaultName -Name $certName

if (!$existing) {
  Write-Host "Creating new cert with subject ${subject}"
  $policy = New-AzKeyVaultCertificatePolicy -SecretContentType "application/x-pkcs12" -SubjectName "CN=$subject" -IssuerName "Self" -ValidityInMonths $monthsValid -ReuseKeyOnRenewal
  $existing = Add-AzKeyVaultCertificate -VaultName $vaultName -Name $certName -CertificatePolicy $Policy -Tag $tags
}

$DeploymentScriptOutputs['cert'] = $existing