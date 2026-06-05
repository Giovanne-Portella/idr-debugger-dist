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

$EXTENSION_ID = 'edopokmfofednhgnjdcjhgdjdgdglbdn'
$UPDATE_URL   = 'https://giovanne-portella.github.io/idr-debugger-dist/update.xml'

Write-Host ''
Write-Host 'Instalando IDR Debugger...' -ForegroundColor Cyan
Write-Host ('Extension ID: ' + $EXTENSION_ID)
Write-Host ('Update URL:   ' + $UPDATE_URL)
Write-Host ''

# --- 1. ExtensionInstallForcelist (Group Policy) ----------------------------
$browsers = @(
    @{ Name = 'Google Chrome';  Path = 'HKLM:\Software\Policies\Google\Chrome' },
    @{ Name = 'Microsoft Edge'; Path = 'HKLM:\Software\Policies\Microsoft\Edge' },
    @{ Name = 'Brave';          Path = 'HKLM:\Software\Policies\BraveSoftware\Brave' },
    @{ Name = 'Opera';          Path = 'HKLM:\Software\Policies\Opera Software\Opera Stable' }
)
$policyValue = $EXTENSION_ID + ';' + $UPDATE_URL
Write-Host '[1/2] Gravando ExtensionInstallForcelist (Group Policy)...'
foreach ($b in $browsers) {
    $forcePath = Join-Path $b.Path 'ExtensionInstallForcelist'
    try {
        if (-not (Test-Path $forcePath)) { New-Item -Path $forcePath -Force | Out-Null }
        Set-ItemProperty -Path $forcePath -Name '1' -Value $policyValue -Type String
        Write-Host ('  [OK] ' + $b.Name) -ForegroundColor Green
    } catch {
        Write-Host ('  [SKIP] ' + $b.Name + ' - ' + $_.Exception.Message) -ForegroundColor Yellow
    }
}

# --- 2. External Extensions registry (mecanismo alternativo do Chrome) ------
Write-Host ''
Write-Host '[2/2] Gravando External Extensions registry (Chrome/Edge)...'
$extPaths = @(
    'HKLM:\SOFTWARE\Google\Chrome\Extensions\' + $EXTENSION_ID,
    'HKLM:\SOFTWARE\Wow6432Node\Google\Chrome\Extensions\' + $EXTENSION_ID,
    'HKLM:\SOFTWARE\Microsoft\Edge\Extensions\' + $EXTENSION_ID,
    'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Edge\Extensions\' + $EXTENSION_ID
)
foreach ($p in $extPaths) {
    try {
        if (-not (Test-Path $p)) { New-Item -Path $p -Force | Out-Null }
        Set-ItemProperty -Path $p -Name 'update_url' -Value $UPDATE_URL -Type String
        Write-Host ('  [OK] ' + $p.Split('\')[-3] + '\...\' + $EXTENSION_ID) -ForegroundColor Green
    } catch {
        Write-Host ('  [SKIP] ' + $p + ' - ' + $_.Exception.Message) -ForegroundColor Yellow
    }
}

Write-Host ''
Write-Host 'Pronto!' -ForegroundColor Green
Write-Host ''
Write-Host 'Feche e reabra o(s) navegador(es) que voce usa.'
Write-Host 'A extensao sera instalada automaticamente em ate ~1 minuto.'
Write-Host ''
Write-Host 'Pra verificar: chrome://extensions/'
Write-Host ''
Read-Host 'Pressione Enter para fechar'
