$ErrorActionPreference = 'Stop'

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator
)
if (-not $isAdmin) {
    Write-Host ''
    Write-Host 'Esta operacao requer permissao de administrador.' -ForegroundColor Yellow
    Write-Host 'Uma janela de UAC vai aparecer -- clique em SIM para continuar.' -ForegroundColor Yellow
    Write-Host ''
    $scriptPath = $MyInvocation.MyCommand.Path
    if (-not $scriptPath) { $scriptPath = $PSCommandPath }
    Start-Process powershell -Verb RunAs -Wait -ArgumentList ('-ExecutionPolicy Bypass -File "' + $scriptPath + '"')
    exit
}

$EXTENSION_ID = 'chjppnjbcimagfgoimogjojchfjlnifl'
$UPDATE_URL   = 'https://clients2.google.com/service/update2/crx'

Write-Host ''
Write-Host 'Instalando IDR Debugger via policy...' -ForegroundColor Cyan
Write-Host ''

$browsers = @(
    @{ Name = 'Google Chrome';  Path = 'HKLM:\Software\Policies\Google\Chrome\ExtensionInstallForcelist' },
    @{ Name = 'Microsoft Edge'; Path = 'HKLM:\Software\Policies\Microsoft\Edge\ExtensionInstallForcelist' },
    @{ Name = 'Brave';          Path = 'HKLM:\Software\Policies\BraveSoftware\Brave\ExtensionInstallForcelist' },
    @{ Name = 'Opera';          Path = 'HKLM:\Software\Policies\Opera Software\Opera Stable\ExtensionInstallForcelist' }
)

foreach ($b in $browsers) {
    try {
        if (-not (Test-Path $b.Path)) { New-Item -Path $b.Path -Force | Out-Null }
        Set-ItemProperty -Path $b.Path -Name '1' -Value ($EXTENSION_ID + ';' + $UPDATE_URL) -Type String
        Write-Host ('  [OK] ' + $b.Name) -ForegroundColor Green
    } catch {
        Write-Host ('  [SKIP] ' + $b.Name + ' - ' + $_.Exception.Message) -ForegroundColor Yellow
    }
}

Write-Host ''
Write-Host 'Pronto! Feche e reabra o navegador.' -ForegroundColor Green
Write-Host 'A extensao sera instalada automaticamente em alguns instantes.' -ForegroundColor White
Write-Host ''
Read-Host 'Pressione Enter para fechar'
