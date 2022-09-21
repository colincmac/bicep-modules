param(
  [string] $secretName,
  [string] $vaultName,
  [ValidateSet(“rsa”, ”ec”)][string] $secretType,
  [string] $keyOption,
  [string] $tagString
)

Write-Host $tagString
$tags = @{}
($tagString | ConvertFrom-Json).psobject.properties | ForEach-Object { $tags[$_.Name] = $_.Value }

$existing = @{
  privateKeyRef = $null
  publicKeyRef  = $null
}


$existing.publicKeyRef = Get-AzKeyVaultSecret -VaultName $vaultName -Name "${secretName}PublicKey"
$existing.privateKeyRef = Get-AzKeyVaultSecret -VaultName $vaultName -Name "${secretName}PrivateKey"
$exists = $($existing.publicKeyRef -and $existing.privateKeyRef)

if (!$exists) {
  Write-Host "Creating ${secretType} key pair"

  switch ($secretType) {
    'ssh-rsa' { ssh-keygen -t rsa -b $keyOption -f $secretName -N '""' }
    'ec' { ssh-keygen -t ed25519 -f $secretName -N '""' -b $keyOption }
  }

  $secretValue = @{
    privateKey = $(Get-Content $secretName -Raw | ConvertTo-SecureString -AsPlainText -Force)
    publicKey  = $(Get-Content "${secretName}.pub" -Raw | ConvertTo-SecureString -AsPlainText -Force)
  }

  $existing.privateKeyRef = $(Set-AzKeyVaultSecret -VaultName $vaultName -Name "${secretName}PrivateKey" -SecretValue $secretValue.privateKey -ContentType "${secretType}-privateKey" -Tags $tags)
  $existing.publicKeyRef = $(Set-AzKeyVaultSecret -VaultName $vaultName -Name "${secretName}PublicKey" -SecretValue $secretValue.publicKey  -ContentType "${secretType}-publicKey"  -Tags $tags)
}


$DeploymentScriptOutputs['secrets'] = $existing