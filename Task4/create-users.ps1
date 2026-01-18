
$ErrorActionPreference = "Stop"

$KubeConfig = "$HOME\.kube\config"

$Users = @(
    @{ Name = "viewer-user"; Group = "read-only" }
    @{ Name = "operator-user"; Group = "cluster-operator" }
    @{ Name = "admin-user"; Group = "cluster-admins" }
    @{ Name = "auditor-user"; Group = "security-auditor" }
)

kubectl config current-context --kubeconfig $KubeConfig

$UsersDir = Join-Path -Path $PWD -ChildPath "users"
if (-not (Test-Path $UsersDir)) {
    New-Item -ItemType Directory -Path $UsersDir | Out-Null
}

foreach ($u in $Users) {

    $User = $u.Name
    $Group = $u.Group
    Write-Host "Создание пользователя: $User (Group: $Group)"

    $UserCertPath = Join-Path $UsersDir "$User.crt"
    $UserKeyPath = Join-Path $UsersDir "$User.key"
    $PfxPath = Join-Path $UsersDir "$User.pfx"
    
    $cert = New-SelfSignedCertificate -Subject "CN=$User,O=$Group" `
        -KeyExportPolicy Exportable `
        -KeySpec Signature `
        -CertStoreLocation "Cert:\CurrentUser\My" `
        -NotAfter (Get-Date).AddYears(1) `
        -TextExtension @("2.5.29.37={text}1.3.6.1.5.5.7.3.2") # clientAuth
    
    $pwd = ConvertTo-SecureString -String "temp" -Force -AsPlainText
    Export-PfxCertificate -Cert $cert -FilePath $PfxPath -Password $pwd | Out-Null
    
    if (Get-Command openssl -ErrorAction SilentlyContinue) {
        & openssl pkcs12 -in $PfxPath -out $UserCertPath -clcerts -nokeys -passin pass:temp
        & openssl pkcs12 -in $PfxPath -out $UserKeyPath -nocerts -nodes -passin pass:temp
    } else {
        Write-Warning "OpenSSL не найден."
        $UserCertPath = $PfxPath
        $UserKeyPath = $PfxPath
    }
    
    kubectl config set-credentials $User `
        --client-certificate=$UserCertPath `
        --client-key=$UserKeyPath `
        --embed-certs=true `
        --kubeconfig $KubeConfig
}

Write-Host "Пользоватлеи успешно созданы"
